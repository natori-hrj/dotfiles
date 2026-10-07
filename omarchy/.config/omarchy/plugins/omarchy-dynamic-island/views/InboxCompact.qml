import QtQuick
import qs.Commons

// Compact notification indicator: the bell appears here while notifications
// are unread, with the unread total shown in its badge.
Item {
  id: view

  property var island: null

  HoverHandler { id: inboxHover }

  // Give the user a moment to settle over the bell before opening the list.
  Timer {
    interval: 240
    running: inboxHover.hovered && island && island.inbox.length > 0 && !island.inboxOpen
    onTriggered: island.openInbox()
  }

  Text {
    anchors.left: parent.left
    anchors.leftMargin: island.s(13)
    anchors.verticalCenter: parent.verticalCenter
    text: "󰂚"
    textFormat: Text.PlainText
    renderType: Text.NativeRendering
    font.family: island.fontFamily
    font.pixelSize: island.f(15)
    color: island.accentColor
  }

  Rectangle {
    anchors.right: parent.right
    anchors.rightMargin: island.s(9)
    anchors.verticalCenter: parent.verticalCenter
    visible: island.unreadCount > 0
    height: island.s(18)
    width: visible ? Math.max(height, count.implicitWidth + island.s(12)) : 0
    radius: height / 2
    color: Util.alpha(island.accentColor, 0.22)

    Text {
      id: count
      anchors.centerIn: parent
      text: island.unreadCount
      textFormat: Text.PlainText
      renderType: Text.NativeRendering
      font.family: island.textFamily
      font.pixelSize: island.f(11)
      font.weight: Font.DemiBold
      color: island.accentColor
    }
  }
}
