import QtQuick
import qs.Commons

Item {
  id: root

  property var player: null
  property var bar: null
  property color foreground: "white"
  property string fontFamily: "monospace"
  property var registeredBar: null

  readonly property bool canPlayPause: !!(player && (player.canTogglePlaying
    || player.canPlay || player.canPause))

  implicitWidth: controls.implicitWidth
  implicitHeight: 30

  function updateClickTargets() {
    if (registeredBar && registeredBar !== bar
        && typeof registeredBar.unregisterClickTarget === "function") {
      registeredBar.unregisterClickTarget(previousButton)
      registeredBar.unregisterClickTarget(playPauseButton)
      registeredBar.unregisterClickTarget(nextButton)
      registeredBar = null
    }

    if (!bar || typeof bar.registerClickTarget !== "function" || registeredBar === bar) return
    bar.registerClickTarget(previousButton)
    bar.registerClickTarget(playPauseButton)
    bar.registerClickTarget(nextButton)
    registeredBar = bar
  }

  function releaseClickTargets() {
    if (!registeredBar || typeof registeredBar.unregisterClickTarget !== "function") return
    registeredBar.unregisterClickTarget(previousButton)
    registeredBar.unregisterClickTarget(playPauseButton)
    registeredBar.unregisterClickTarget(nextButton)
    registeredBar = null
  }

  function togglePlayback() {
    if (!player) return
    if (player.isPlaying && player.canPause) player.pause()
    else if (!player.isPlaying && player.canPlay) player.play()
    else if (player.canTogglePlaying) player.togglePlaying()
  }

  onBarChanged: updateClickTargets()
  Component.onCompleted: updateClickTargets()
  Component.onDestruction: releaseClickTargets()

  Row {
    id: controls

    anchors.centerIn: parent
    spacing: 2

    Item {
      id: previousButton

      visible: root.visible
      width: 24
      height: 30
      readonly property bool interactive: !!(root.player && root.player.canGoPrevious)

      function triggerPress(button) {
        if (button === Qt.LeftButton && interactive && root.player) root.player.previous()
      }

      Text {
        anchors.centerIn: parent
        text: "󰒮"
        color: root.foreground
        opacity: previousButton.interactive ? 0.92 : 0.36
        font.family: root.fontFamily
        font.pixelSize: Style.font.icon
      }
    }

    Item {
      id: playPauseButton

      visible: root.visible
      width: 26
      height: 30
      readonly property bool interactive: root.canPlayPause

      function triggerPress(button) {
        if (button === Qt.LeftButton && interactive) root.togglePlayback()
      }

      Text {
        anchors.centerIn: parent
        text: root.player && root.player.isPlaying ? "󰏤" : "󰐊"
        color: root.foreground
        opacity: playPauseButton.interactive ? 1.0 : 0.42
        font.family: root.fontFamily
        font.pixelSize: Style.font.iconLarge
      }
    }

    Item {
      id: nextButton

      visible: root.visible
      width: 24
      height: 30
      readonly property bool interactive: !!(root.player && root.player.canGoNext)

      function triggerPress(button) {
        if (button === Qt.LeftButton && interactive && root.player) root.player.next()
      }

      Text {
        anchors.centerIn: parent
        text: "󰒭"
        color: root.foreground
        opacity: nextButton.interactive ? 0.92 : 0.36
        font.family: root.fontFamily
        font.pixelSize: Style.font.icon
      }
    }
  }
}
