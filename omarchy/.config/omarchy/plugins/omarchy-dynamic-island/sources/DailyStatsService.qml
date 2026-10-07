import QtQuick
import Quickshell.Io

QtObject {
  id: root

  readonly property int refreshInterval: 5 * 60 * 1000
  property bool available: false
  property bool loading: false
  property int batteryNow: -1
  property double lastUpdated: 0
  property var today: ({})
  property var days: []
  property string error: ""
  property double lastAttempt: 0

  function providerScriptPath() {
    var path = String(Qt.resolvedUrl("daily-stats-provider.py"))
    if (path.indexOf("file://") === 0) path = path.substring(7)
    try {
      return decodeURIComponent(path)
    } catch (error) {
      return path
    }
  }

  function refresh(force) {
    if (loading || collectProcess.running) return
    if (!force && Date.now() - lastAttempt < 60 * 1000) return
    loading = true
    lastAttempt = Date.now()
    collectProcess.running = true
  }

  function applyOutput(output) {
    var result
    try {
      result = JSON.parse(String(output || "").trim())
    } catch (parseError) {
      setUnavailable("Could not read local stats")
      return
    }

    if (!result || result.available !== true) {
      setUnavailable(String(result && result.error || "Local stats unavailable"))
      return
    }

    available = true
    today = result.today || ({})
    days = result.days || []
    batteryNow = result.batteryNow !== null && isFinite(Number(result.batteryNow))
      ? Math.round(Number(result.batteryNow)) : -1
    lastUpdated = Number(result.lastUpdated) || Date.now()
    error = ""
    loading = false
  }

  function setUnavailable(message) {
    available = false
    batteryNow = -1
    today = ({})
    days = []
    error = message
    loading = false
  }

  property Process collectProcess: Process {
    id: collectProcess
    command: ["python3", root.providerScriptPath()]

    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.applyOutput(text)
    }

    stderr: StdioCollector {
      waitForEnd: true
    }

    onExited: function(exitCode) {
      if (root.loading && exitCode !== 0) root.setUnavailable("Local stats collection failed")
    }
  }

  property Timer refreshTimer: Timer {
    interval: root.refreshInterval
    repeat: true
    running: true
    triggeredOnStart: true
    onTriggered: root.refresh(false)
  }

  Component.onCompleted: root.refresh(true)
}
