import QtQuick
import Quickshell.Io
import "components"

Item {
  id: root

  property var bar
  property string moduleName
  property var settings

  property int cpuUsage: 0.0

  implicitWidth: pill.implicitWidth
  implicitHeight: bar ? bar.barSize : 26

  GlassPill {
    id: pill

    anchors.verticalCenter: parent.verticalCenter

    implicitHeight: Math.max(20, root.implicitHeight - 6)
    foreground: bar ? bar.foreground : "white"

    Text {
      text: "󰍛"
      color: pill.foreground
      font.family: bar ? bar.fontFamily : "monospace"
      font.pixelSize: 12
    }

    Text {
      text: root.cpuUsage + "%"
      color: pill.foreground
      font.family: bar ? bar.fontFamily : "monospace"
      font.pixelSize: 11
    }
  }

  Timer {
    interval: 2000
    repeat: true
    running: true
    triggeredOnStart: true

    onTriggered: {
      if (!cpuProcess.running)
      cpuProcess.running = true
    }
  }

  Process {
    id: cpuProcess

    command: [
      "bash",
      "-lc",
      "LANG=C top -bn1 | awk '/^%Cpu/{printf \"%.0f\\n\", 100-$8; exit}'"
    ]

    stdout: StdioCollector {
      waitForEnd: true

      onStreamFinished: {
        const value = parseInt(text.trim())
        if (!isNaN(value))
          root.cpuUsage = Math.max(0, Math.min(100, value))
      }
    }
  }
}
