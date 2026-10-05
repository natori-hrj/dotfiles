import QtQuick
import Quickshell
import Quickshell.Io

// Read Omarchy's existing notification queue and history. The cloned
// NotificationServer remains the only owner of org.freedesktop.Notifications.
Item {
  id: root

  width: 0
  height: 0

  readonly property string popupStateDir: Quickshell.env("HOME")
    + "/.local/state/omarchy/notifications"
  property var entries: []
  property bool loading: false
  readonly property int historyCount: entries.length
  readonly property var unreadEntries: {
    var lastRead = Number(readState.lastReadTimestamp || 0)
    return entries.filter(function(entry) {
      return Number(entry.timestamp || 0) > lastRead
    })
  }
  readonly property int unreadCount: {
    var count = 0
    var lastRead = Number(readState.lastReadTimestamp || 0)
    for (var i = 0; i < entries.length; i++) {
      if (Number(entries[i].timestamp || 0) > lastRead) count++
    }
    return count
  }

  PersistentProperties {
    id: readState
    reloadableId: "dynamic-island-notification-history"
    property double lastReadTimestamp: 0
    property bool initialized: false
  }

  function refresh() {
    if (reader.running) return
    loading = true
    reader.running = true
  }

  function markRead() {
    var newest = Number(readState.lastReadTimestamp || 0)
    for (var i = 0; i < entries.length; i++)
      newest = Math.max(newest, Number(entries[i].timestamp || 0))
    readState.lastReadTimestamp = newest
  }

  function plainText(value) {
    return String(value || "")
      .replace(/<img\b[^>]*>/gi, "")
      .replace(/<[^>]*>/g, "")
      .replace(/&nbsp;|&#160;/gi, " ")
      .replace(/&amp;/gi, "&")
      .replace(/&lt;/gi, "<")
      .replace(/&gt;/gi, ">")
      .replace(/&quot;/gi, "\"")
      .replace(/&#39;/gi, "'")
  }

  function readEntries(raw) {
    var lines = String(raw || "").split(/\r?\n/)
    var rows = []
    var seen = ({})

    for (var i = 0; i < lines.length; i++) {
      var line = lines[i].trim()
      if (!line) continue

      try {
        var record = JSON.parse(line)
        if (!record || typeof record !== "object") continue

        var timestamp = Number(record.timestamp || 0)
        var originalId = Number(record.originalId || record.id || 0)
        var key = String(timestamp) + "-" + String(originalId)
        if (seen[key]) continue
        seen[key] = true

        rows.push({
          key: key,
          app: String(record.app || ""),
          appIcon: String(record.appIcon || ""),
          summary: String(record.summary || "Notification"),
          body: plainText(record.body),
          urgency: Number(record.urgency || 1),
          timestamp: timestamp
        })
      } catch (error) {
        // Ignore an incomplete JSON file and keep valid neighboring entries.
      }
    }

    rows.sort(function(a, b) { return b.timestamp - a.timestamp })
    entries = rows
    if (!readState.initialized) {
      readState.lastReadTimestamp = rows.length ? rows[0].timestamp : Date.now()
      readState.initialized = true
    }
    loading = false
  }

  Timer {
    interval: 10000
    repeat: true
    running: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  Process {
    id: reader
    command: ["bash", "-c",
      "for f in \"$1\"/*.json \"$1\"/history/*.json; do "
        + "[ -f \"$f\" ] || continue; awk '1' \"$f\"; done; exit 0",
      "--", root.popupStateDir]
    running: false
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.readEntries(text)
    }
    onExited: root.loading = false
  }
}
