#!/usr/bin/env python3
"""Collect local battery and uptime samples for the Dynamic Island."""

from __future__ import annotations

import datetime as dt
import json
import os
from pathlib import Path
import sys
import tempfile
import time


STATE_DIR = Path(os.environ.get("XDG_STATE_HOME", Path.home() / ".local/state")) / "omarchy/dynamic-island"
STATE_FILE = STATE_DIR / "daily-stats.json"
KEEP_DAYS = 14
MAX_INTERVAL_SECONDS = 36 * 60 * 60


def read_float(path: Path) -> float | None:
    try:
        return float(path.read_text(encoding="ascii").split()[0])
    except (OSError, ValueError, IndexError):
        return None


def battery_percentage() -> float | None:
    power_supplies = Path("/sys/class/power_supply")
    try:
        batteries = [p for p in power_supplies.iterdir()
                     if (p / "type").read_text(encoding="ascii").strip() == "Battery"]
    except OSError:
        return None

    if not batteries:
        return None

    energy_now = [read_float(p / "energy_now") for p in batteries]
    energy_full = [read_float(p / "energy_full") for p in batteries]
    if all(v is not None for v in energy_now + energy_full) and sum(energy_full) > 0:
        percent = 100 * sum(energy_now) / sum(energy_full)
    else:
        charge_now = [read_float(p / "charge_now") for p in batteries]
        charge_full = [read_float(p / "charge_full") for p in batteries]
        if all(v is not None for v in charge_now + charge_full) and sum(charge_full) > 0:
            percent = 100 * sum(charge_now) / sum(charge_full)
        else:
            capacities = [read_float(p / "capacity") for p in batteries]
            capacities = [v for v in capacities if v is not None]
            percent = sum(capacities) / len(capacities) if capacities else None

    return round(max(0.0, min(100.0, percent)), 1) if percent is not None else None


def local_date(timestamp: float) -> dt.date:
    return dt.datetime.fromtimestamp(timestamp).date()


def day_record(days: dict, day: dt.date) -> dict:
    key = day.isoformat()
    if key not in days:
        days[key] = {
            "uptimeSeconds": 0.0,
            "sampleCount": 0,
        }
    return days[key]


def add_uptime_interval(days: dict, start: float, end: float, uptime_delta: float) -> None:
    wall_delta = end - start
    if wall_delta <= 0 or wall_delta > MAX_INTERVAL_SECONDS or uptime_delta <= 0:
        return

    cursor = start
    while cursor < end:
        local = dt.datetime.fromtimestamp(cursor)
        next_date = local.date() + dt.timedelta(days=1)
        midnight = time.mktime((next_date.year, next_date.month, next_date.day,
                                0, 0, 0, -1, -1, -1))
        segment_end = min(end, midnight if midnight > cursor else end)
        segment = segment_end - cursor
        record = day_record(days, local.date())
        record["uptimeSeconds"] += uptime_delta * segment / wall_delta
        cursor = segment_end


def load_state() -> dict:
    try:
        value = json.loads(STATE_FILE.read_text(encoding="utf-8"))
        if isinstance(value, dict) and isinstance(value.get("days"), dict):
            return value
    except (OSError, ValueError):
        pass
    return {"days": {}, "lastSample": None}


def save_state(state: dict) -> None:
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    fd, temporary = tempfile.mkstemp(prefix="daily-stats-", suffix=".json", dir=STATE_DIR)
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as stream:
            json.dump(state, stream, separators=(",", ":"), ensure_ascii=False)
            stream.write("\n")
        os.replace(temporary, STATE_FILE)
    finally:
        try:
            os.unlink(temporary)
        except FileNotFoundError:
            pass


def sample() -> dict:
    now = time.time()
    today = local_date(now)
    uptime = read_float(Path("/proc/uptime"))
    if uptime is None:
        raise RuntimeError("System uptime is unavailable")
    boot_id = Path("/proc/sys/kernel/random/boot_id").read_text(encoding="ascii").strip()
    battery = battery_percentage()
    state = load_state()
    days = state["days"]
    previous = state.get("lastSample")

    if previous and previous.get("bootId") == boot_id:
        add_uptime_interval(days, float(previous.get("timestamp", now)), now,
                            uptime - float(previous.get("uptimeSeconds", uptime)))

    record = day_record(days, today)
    record["sampleCount"] = int(record.get("sampleCount", 0)) + 1

    state["lastSample"] = {
        "timestamp": now,
        "date": today.isoformat(),
        "bootId": boot_id,
        "uptimeSeconds": uptime,
        "batteryPercent": battery,
    }

    cutoff = today - dt.timedelta(days=KEEP_DAYS - 1)
    state["days"] = {key: value for key, value in days.items()
                      if key >= cutoff.isoformat() and key <= today.isoformat()}
    for record in state["days"].values():
        for obsolete in ("batteryStart", "batteryEnd", "batteryMin", "batteryMax",
                         "batteryUsed", "buckets"):
            record.pop(obsolete, None)
    save_state(state)
    return make_output(state, today)


def make_output(state: dict, today: dt.date) -> dict:
    last = state.get("lastSample") or {}
    def output_day(day: dt.date) -> dict:
        record = state["days"].get(day.isoformat(), {})
        return {
            "date": day.isoformat(),
            "uptimeSeconds": round(record.get("uptimeSeconds", 0)),
            "hasData": bool(record.get("uptimeSeconds", 0) > 0
                             or record.get("sampleCount", 0) > 0),
        }

    week_start = today - dt.timedelta(days=today.weekday())
    week = [output_day(week_start + dt.timedelta(days=offset)) for offset in range(7)]

    battery_now = last.get("batteryPercent")
    return {
        "available": True,
        "today": output_day(today),
        "days": week,
        "batteryNow": battery_now,
        "lastUpdated": round(float(last.get("timestamp", 0)) * 1000),
    }


if __name__ == "__main__":
    try:
        print(json.dumps(sample(), separators=(",", ":")))
    except Exception as error:  # Keep provider failures inside the optional widget.
        print(json.dumps({"available": False, "error": str(error)}, separators=(",", ":")))
        sys.exit(0)
