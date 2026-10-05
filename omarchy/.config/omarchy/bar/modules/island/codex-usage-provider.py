#!/usr/bin/env python3
"""Read Codex allowance data through Codex's documented local app-server protocol."""

import json
import os
import selectors
import signal
import shutil
import subprocess
import sys
import time


TIMEOUT_SECONDS = 12


def write_message(process, message):
    process.stdin.write((json.dumps(message, separators=(",", ":")) + "\n").encode())
    process.stdin.flush()


def read_response(process, expected_id, deadline):
    selector = selectors.DefaultSelector()
    selector.register(process.stdout, selectors.EVENT_READ)
    pending = bytearray()

    try:
        while time.monotonic() < deadline:
            events = selector.select(max(0, deadline - time.monotonic()))
            if not events:
                break

            chunk = os.read(process.stdout.fileno(), 4096)
            if not chunk:
                break
            pending.extend(chunk)

            while b"\n" in pending:
                line, _, rest = pending.partition(b"\n")
                pending = bytearray(rest)
                try:
                    message = json.loads(line)
                except (json.JSONDecodeError, UnicodeDecodeError):
                    continue
                if isinstance(message, dict) and message.get("id") == expected_id:
                    return message
    finally:
        selector.close()

    raise TimeoutError


def send_request(process, method, request_id, params=None):
    message = {"method": method, "id": request_id}
    if params is not None:
        message["params"] = params
    write_message(process, message)
    response = read_response(process, request_id, time.monotonic() + TIMEOUT_SECONDS)
    if "error" in response or not isinstance(response.get("result"), dict):
        raise RuntimeError
    return response["result"]


def codex_snapshot(result):
    buckets = result.get("rateLimitsByLimitId")
    if isinstance(buckets, dict):
        snapshot = buckets.get("codex")
        if not isinstance(snapshot, dict):
            raise RuntimeError
    else:
        snapshot = result.get("rateLimits")
    if not isinstance(snapshot, dict):
        raise RuntimeError
    if snapshot.get("limitId") not in (None, "codex"):
        raise RuntimeError

    payload = {
        "available": True,
        "fiveHourRemaining": None,
        "fiveHourReset": None,
        "weeklyRemaining": None,
        "weeklyReset": None,
        "credits": "",
        "planType": str(snapshot.get("planType") or ""),
        "lastUpdated": int(time.time() * 1000),
    }

    for window_name in ("primary", "secondary"):
        window = snapshot.get(window_name)
        if not isinstance(window, dict):
            continue
        try:
            duration = int(window.get("windowDurationMins"))
            used_percent = max(0, min(100, int(window["usedPercent"])))
        except (KeyError, TypeError, ValueError):
            continue

        if duration == 5 * 60:
            payload["fiveHourRemaining"] = 100 - used_percent
            payload["fiveHourReset"] = window.get("resetsAt")
        elif duration == 7 * 24 * 60:
            payload["weeklyRemaining"] = 100 - used_percent
            payload["weeklyReset"] = window.get("resetsAt")

    credits = snapshot.get("credits")
    if isinstance(credits, dict):
        balance = credits.get("balance")
        if credits.get("unlimited") is True:
            payload["credits"] = "Unlimited"
        elif balance is not None:
            payload["credits"] = str(balance)

    return payload


def unavailable():
    return {"available": False}


def main():
    codex = shutil.which("codex")
    if not codex:
        return unavailable()

    process = None
    try:
        process = subprocess.Popen(
            [codex, "app-server", "--listen", "stdio://"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            bufsize=0,
            start_new_session=True,
        )
        send_request(
            process,
            "initialize",
            1,
            {
                "clientInfo": {
                    "name": "omarchy_dynamic_island",
                    "title": "Omarchy Dynamic Island",
                    "version": "1.0.0",
                }
            },
        )
        write_message(process, {"method": "initialized", "params": {}})
        result = send_request(process, "account/rateLimits/read", 2)
        return codex_snapshot(result)
    except Exception:
        return unavailable()
    finally:
        if process is not None:
            try:
                process.stdin.close()
            except Exception:
                pass
            try:
                process.wait(timeout=1.0)
            except subprocess.TimeoutExpired:
                pass
            try:
                os.killpg(process.pid, signal.SIGTERM)
            except ProcessLookupError:
                pass
            try:
                process.wait(timeout=0.5)
            except subprocess.TimeoutExpired:
                pass
            try:
                os.killpg(process.pid, signal.SIGKILL)
            except ProcessLookupError:
                pass
            if process.poll() is None:
                process.wait()


if __name__ == "__main__":
    json.dump(main(), sys.stdout, separators=(",", ":"))
    sys.stdout.write("\n")
