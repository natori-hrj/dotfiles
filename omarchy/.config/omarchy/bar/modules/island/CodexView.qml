import QtQuick
import Quickshell
import qs.Commons
import "."

Item {
  id: root

  property var bar: null
  property var service: null
  property color foreground: "white"
  property color accent: "white"
  property string fontFamily: "monospace"
  property bool popupOpen: false

  implicitWidth: 24
  implicitHeight: 28

  readonly property int lowestRemaining: {
    if (!service || !service.available) return 100
    var values = []
    if (service.fiveHourRemaining >= 0) values.push(service.fiveHourRemaining)
    if (service.weeklyRemaining >= 0) values.push(service.weeklyRemaining)
    return values.length > 0 ? Math.min.apply(Math, values) : 100
  }

  function showPopup() {
    closeTimer.stop()
    popupOpen = true
    if (service) service.refresh()
  }

  function close() {
    closeTimer.stop()
    popupOpen = false
  }

  HoverHandler {
    id: iconHover
    onHoveredChanged: {
      if (hovered) root.showPopup()
      else closeTimer.restart()
    }
  }

  Timer {
    id: closeTimer
    interval: 240
    repeat: false
    onTriggered: {
      if (!iconHover.hovered && !usagePopup.containsMouse) root.close()
    }
  }

  Image {
    id: codexIcon
    anchors.centerIn: parent
    width: 19
    height: 19
    source: Quickshell.iconPath("chatgpt", true)
    sourceSize.width: 38
    sourceSize.height: 38
    fillMode: Image.PreserveAspectFit
    smooth: true
    visible: status === Image.Ready
    cache: true
  }

  Text {
    anchors.centerIn: parent
    text: "</>"
    color: iconHover.hovered ? root.accent : root.foreground
    font.family: root.fontFamily
    font.pixelSize: Style.font.caption
    font.weight: Font.DemiBold
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    visible: codexIcon.status !== Image.Ready
  }

  Rectangle {
    visible: root.lowestRemaining < 20
    width: 6
    height: 6
    anchors.top: parent.top
    anchors.right: parent.right
    radius: 3
    color: root.lowestRemaining < 5 ? "#df6262" : "#d7a84b"
    border.width: 1
    border.color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.8)
  }

  CodexUsagePopup {
    id: usagePopup
    anchorItem: root
    bar: root.bar
    owner: root
    service: root.service
    open: root.popupOpen
    onContainsMouseChanged: {
      if (containsMouse) closeTimer.stop()
      else if (root.popupOpen) closeTimer.restart()
    }
  }
}
