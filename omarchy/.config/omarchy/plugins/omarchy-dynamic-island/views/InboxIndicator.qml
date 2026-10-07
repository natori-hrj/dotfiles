import QtQuick
import qs.Commons

// Notification history shortcut alongside Codex and daily stats in expanded
// utility rows. Unread notifications use the compact indicator while closed.
Item {
  id: root

  property var island: null

  implicitWidth: visible && island ? island.s(24) : 0
  implicitHeight: visible && island ? island.s(28) : 0
  width: implicitWidth
  height: implicitHeight

  HoverHandler { id: iconHover }

  Rectangle {
    anchors.centerIn: parent
    width: root.island ? root.island.s(24) : 24
    height: width
    radius: width / 2
    color: iconHover.hovered && root.island
      ? Util.alpha(root.island.accentColor, 0.16)
      : "transparent"
  }

  Text {
    anchors.centerIn: parent
    text: "󰂚"
    textFormat: Text.PlainText
    renderType: Text.NativeRendering
    font.family: root.island ? root.island.fontFamily : "monospace"
    font.pixelSize: root.island ? root.island.f(15) : 15
    color: root.island ? (iconHover.hovered ? root.island.accentColor : root.island.fg) : "white"
  }

  Timer {
    interval: 240
    running: root.visible && root.island && iconHover.hovered && !root.island.inboxOpen
    onTriggered: root.island.openInbox()
  }
}
