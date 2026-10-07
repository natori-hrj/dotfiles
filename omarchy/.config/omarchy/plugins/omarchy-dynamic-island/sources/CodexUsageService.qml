import Quickshell.Io
import QtQuick

QtObject {
  id: root

  readonly property int refreshInterval: 5 * 60 * 1000
  property bool available: false
  property bool loading: false
  property int fiveHourRemaining: -1
  property double fiveHourReset: 0
  property int weeklyRemaining: -1
  property double weeklyReset: 0
  property string credits: ""
  property string planType: ""
  property double lastUpdated: 0
  property string error: "Usage data unavailable"
  property double lastAttempt: 0

  function providerScriptPath() {
    var path = String(Qt.resolvedUrl("codex-usage-provider.py"))
    if (path.indexOf("file://") === 0) path = path.substring(7)
    try {
      return decodeURIComponent(path)
    } catch (error) {
      return path
    }
  }

  function refresh() {
    if (loading || fetchProcess.running) return
    if (Date.now() - lastAttempt < refreshInterval) return

    loading = true
    lastAttempt = Date.now()
    fetchProcess.running = true
  }

  function applyProviderOutput(output) {
    var result
    try {
      result = JSON.parse(String(output || "").trim())
    } catch (parseError) {
      setUnavailable()
      return
    }

    if (!result || result.available !== true) {
      setUnavailable()
      return
    }

    available = true
    fiveHourRemaining = result.fiveHourRemaining !== null
      && isFinite(Number(result.fiveHourRemaining))
      ? Math.max(0, Math.min(100, Math.round(Number(result.fiveHourRemaining)))) : -1
    fiveHourReset = Number(result.fiveHourReset) || 0
    weeklyRemaining = result.weeklyRemaining !== null
      && isFinite(Number(result.weeklyRemaining))
      ? Math.max(0, Math.min(100, Math.round(Number(result.weeklyRemaining)))) : -1
    weeklyReset = Number(result.weeklyReset) || 0
    credits = String(result.credits || "")
    planType = String(result.planType || "")
    lastUpdated = Number(result.lastUpdated) || Date.now()
    error = ""
    loading = false
  }

  function setUnavailable() {
    available = false
    fiveHourRemaining = -1
    fiveHourReset = 0
    weeklyRemaining = -1
    weeklyReset = 0
    credits = ""
    planType = ""
    error = "Usage data unavailable"
    loading = false
  }

  property Process fetchProcess: Process {
    id: fetchProcess
    command: ["python3", root.providerScriptPath()]

    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.applyProviderOutput(text)
    }

    stderr: StdioCollector {
      waitForEnd: true
    }

    onExited: function(exitCode) {
      if (root.loading && exitCode !== 0) root.setUnavailable()
    }
  }

  property Timer refreshTimer: Timer {
    interval: root.refreshInterval
    repeat: true
    running: true
    onTriggered: root.refresh()
  }

  Component.onCompleted: root.refresh()
}
