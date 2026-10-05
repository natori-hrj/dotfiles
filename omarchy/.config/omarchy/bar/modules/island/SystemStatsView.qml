import QtQuick
import qs.Commons
import "."

Item {
  id: root

  property var bar: null
  property var service: null
  property color foreground: "white"
  property color accent: "white"
  property bool popupOpen: false

  readonly property bool interactive: visible && enabled
  implicitWidth: 24
  implicitHeight: 28

  function showPopup() {
    closeTimer.stop()
    if (!popupOpen && service) service.refresh(true)
    popupOpen = true
  }

  function close() {
    closeTimer.stop()
    popupOpen = false
  }

  HoverHandler {
    id: iconHover
    cursorShape: Qt.PointingHandCursor
    onHoveredChanged: {
      if (hovered) root.showPopup()
      else closeTimer.restart()
    }
  }

  Timer {
    id: closeTimer
    interval: 220
    repeat: false
    onTriggered: {
      if (!iconHover.hovered && !statsPopup.containsMouse) root.close()
    }
  }

  Text {
    anchors.centerIn: parent
    text: "󰄉"
    color: root.popupOpen || iconHover.hovered ? root.accent : root.foreground
    font.family: root.bar ? root.bar.fontFamily : "monospace"
    font.pixelSize: Style.font.icon
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter
  }

  DailyStatsPopup {
    id: statsPopup
    anchorItem: root
    bar: root.bar
    owner: root
    service: root.service
    open: root.popupOpen
    period: "today"
    triggerMode: "hover"

    onContainsMouseChanged: {
      if (containsMouse) closeTimer.stop()
      else if (root.popupOpen && !iconHover.hovered) closeTimer.restart()
    }
  }
}
