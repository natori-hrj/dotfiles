#!/usr/bin/env python3
"""
RunCat Neo — Claude Code statusLine sample (+ LiteLLM spend).

Writes ~/.claude/runcat-usage.json shaped like:

    {
      "title": "Claude Code",
      "symbol": "staroflife",
      "metricsBarValue": "67%",
      "metrics": [
        {"title": "Model",   "formattedValue": "Opus 4.7"},
        {"title": "Context", "formattedValue": "67%", "normalizedValue": 0.67},
        {"title": "5h",      "formattedValue": "3%",  "normalizedValue": 0.03},
        {"title": "7d",      "formattedValue": "3%",  "normalizedValue": 0.03},
        {"title": "LiteLLM", "formattedValue": "$4.20 / $50.00", "normalizedValue": 0.084}
      ],
      "lastUpdatedDate": "2026-06-07T05:55:36Z"
    }

LiteLLM spend is polled from the proxy's /key/info endpoint, which any
virtual key can call on itself (no org admin key required). Since this
runs on every Claude Code turn, results are cached for
LITELLM_POLL_INTERVAL_SEC seconds to avoid hammering the proxy.
"""

import json
import os
import sys
import tempfile
import time
import urllib.error
import urllib.request
from datetime import datetime, timezone
from pathlib import Path

OUT = Path(os.environ.get("RUNCAT_OUT_FILE", str(Path.home() / ".claude" / "runcat-usage.json")))
LITELLM_CACHE = Path(
    os.environ.get("RUNCAT_LITELLM_CACHE_FILE", str(Path.home() / ".claude" / "runcat-litellm-cache.json"))
)

# TODO: 会社のLiteLLMプロキシの実際のベースURLに置き換える
LITELLM_BASE_URL = os.environ.get("LITELLM_BASE_URL", "https://litellm.example.com")
# Claude CodeとCodexで同じ仮想キーを使っている前提。未設定ならANTHROPIC_API_KEYを流用する
LITELLM_API_KEY = os.environ.get("LITELLM_API_KEY") or os.environ.get("ANTHROPIC_API_KEY")
LITELLM_POLL_INTERVAL_SEC = int(os.environ.get("LITELLM_POLL_INTERVAL_SEC", "300"))


def pct(title, value):
    if value is None:
        return None
    return {"title": title, "formattedValue": f"{value:g}%", "normalizedValue": round(value / 100, 4)}


def read_cache():
    try:
        return json.loads(LITELLM_CACHE.read_text())
    except Exception:
        return {}


def fetch_litellm_spend():
    if not LITELLM_API_KEY:
        return None, None

    cached = read_cache()
    if time.time() - cached.get("fetched_at", 0) < LITELLM_POLL_INTERVAL_SEC:
        return cached.get("spend"), cached.get("max_budget")

    url = f"{LITELLM_BASE_URL.rstrip('/')}/key/info?key={LITELLM_API_KEY}"
    req = urllib.request.Request(url, headers={"Authorization": f"Bearer {LITELLM_API_KEY}"})
    try:
        with urllib.request.urlopen(req, timeout=3) as resp:
            info = json.load(resp).get("info", {})
        spend, max_budget = info.get("spend"), info.get("max_budget")
        LITELLM_CACHE.write_text(json.dumps({"spend": spend, "max_budget": max_budget, "fetched_at": time.time()}))
        return spend, max_budget
    except (urllib.error.URLError, TimeoutError, ValueError, OSError):
        return cached.get("spend"), cached.get("max_budget")


def litellm_metric():
    spend, max_budget = fetch_litellm_spend()
    if spend is None:
        return None
    if max_budget:
        return {
            "title": "LiteLLM",
            "formattedValue": f"${spend:.2f} / ${max_budget:.2f}",
            "normalizedValue": round(min(spend / max_budget, 1.0), 4),
        }
    return {"title": "LiteLLM", "formattedValue": f"${spend:.2f}"}


try:
    payload = json.load(sys.stdin)
    if not isinstance(payload, dict):
        payload = {}
except Exception:
    payload = {}

model = (payload.get("model") or {}).get("display_name") or "Claude Code"
ctx = (payload.get("context_window") or {}).get("used_percentage")
rate_limits = payload.get("rate_limits") or {}
five = (rate_limits.get("five_hour") or {}).get("used_percentage")
seven = (rate_limits.get("seven_day") or {}).get("used_percentage")

snapshot = {
    "title": "Claude Code",
    "symbol": "staroflife",
    "metrics": [m for m in [
        {"title": "Model", "formattedValue": model},
        pct("Context", ctx),
        pct("5h", five),
        pct("7d", seven),
        litellm_metric(),
    ] if m is not None],
    "lastUpdatedDate": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
}
if ctx is not None:
    snapshot["metricsBarValue"] = f"{ctx:g}%"

OUT.parent.mkdir(parents=True, exist_ok=True)
fd, tmp = tempfile.mkstemp(prefix=".runcat-", dir=str(OUT.parent))
with os.fdopen(fd, "w", encoding="utf-8") as f:
    json.dump(snapshot, f, ensure_ascii=False)
os.replace(tmp, OUT)

print(model)
