import QtQuick
import qs.Commons
import "."

Item {
  id: root

  property var bar: null
  property var service: null
  property color foreground: "white"
  property color accent: "white"
  property string fontFamily: "monospace"
  property bool panelOpen: false
  property bool unreadPopupOpen: false
  property var registeredBar: null

  readonly property int unreadCount: service ? Number(service.unreadCount || 0) : 0
  readonly property bool keepIslandExpanded: panelOpen || unreadPopupOpen
  readonly property bool interactive: visible && enabled

  implicitWidth: 24
  implicitHeight: 28

  function updateClickTarget() {
    if (registeredBar && registeredBar !== bar
        && typeof registeredBar.unregisterClickTarget === "function") {
      registeredBar.unregisterClickTarget(root)
      registeredBar = null
    }
    if (!bar || typeof bar.registerClickTarget !== "function" || registeredBar === bar) return
    bar.registerClickTarget(root)
    registeredBar = bar
  }

  function releaseClickTarget() {
    if (!registeredBar || typeof registeredBar.unregisterClickTarget !== "function") return
    registeredBar.unregisterClickTarget(root)
    registeredBar = null
  }

  function triggerPress(button) {
    if (button === Qt.LeftButton) root.toggle()
  }

  function toggle() {
    unreadPopupOpen = false
    panelOpen = !panelOpen
    if (panelOpen && service) {
      service.refresh()
      service.markRead()
    }
  }

  function close() {
    panelOpen = false
    unreadPopupOpen = false
  }

  onBarChanged: updateClickTarget()
  Component.onCompleted: updateClickTarget()
  Component.onDestruction: releaseClickTarget()
  onUnreadCountChanged: {
    if (unreadCount === 0) unreadPopupOpen = false
    else if (iconHover.hovered) unreadPopupOpen = true
  }

  HoverHandler {
    id: iconHover
    onHoveredChanged: {
      if (hovered) {
        previewCloseTimer.stop()
        if (root.service) root.service.refresh()
        root.unreadPopupOpen = root.unreadCount > 0
      } else if (root.unreadPopupOpen) {
        previewCloseTimer.restart()
      }
    }
  }

  Timer {
    id: previewCloseTimer
    interval: 200
    repeat: false
    onTriggered: {
      if (!iconHover.hovered && !unreadPreview.containsMouse)
        root.unreadPopupOpen = false
    }
  }

  QtObject {
    id: previewOwner
    function close() { root.unreadPopupOpen = false }
  }

  Text {
    anchors.centerIn: parent
    text: "󰂚"
    color: root.panelOpen || iconHover.hovered ? root.accent : root.foreground
    font.family: root.fontFamily
    font.pixelSize: Style.font.icon
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter
  }

  Rectangle {
    visible: root.unreadCount > 0
    width: Math.max(15, unreadLabel.implicitWidth + 6)
    height: 14
    anchors.top: parent.top
    anchors.right: parent.right
    anchors.topMargin: -1
    anchors.rightMargin: -3
    radius: 7
    color: root.accent
    border.width: 1
    border.color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.8)

    Text {
      id: unreadLabel
      anchors.centerIn: parent
      text: root.unreadCount > 99 ? "99+" : String(root.unreadCount)
      color: root.foreground
      font.family: root.fontFamily
      font.pixelSize: 8
      font.weight: Font.DemiBold
    }
  }

  NotificationCenterPopup {
    id: historyPopup
    anchorItem: root
    bar: root.bar
    owner: root
    service: root.service
    open: root.panelOpen
  }

  NotificationCenterPopup {
    id: unreadPreview
    anchorItem: root
    bar: root.bar
    owner: previewOwner
    service: root.service
    unreadOnly: true
    open: root.unreadPopupOpen

    onContainsMouseChanged: {
      if (containsMouse) previewCloseTimer.stop()
      else if (root.unreadPopupOpen && !iconHover.hovered) previewCloseTimer.restart()
    }
  }
}
