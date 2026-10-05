import QtQuick
import QtQuick.Layouts
import qs.Commons
import "."

Item {
  id: root

  property var player: null
  property var bar: null
  property color foreground: "white"
  property color accent: "white"
  property string fontFamily: "monospace"
  property bool popupOpen: false

  readonly property bool hasTrack: !!(player && (player.trackTitle || player.trackArtist
    || player.trackAlbum || player.trackArtUrl))
  readonly property string titleText: !hasTrack ? "No media playing"
    : (player.trackTitle || player.trackArtist || "Unknown title")
  readonly property string artistText: hasTrack && player.trackArtist
    ? String(player.trackArtist) : ""
  readonly property string artworkUrl: hasTrack && player.trackArtUrl
    ? String(player.trackArtUrl) : ""

  implicitWidth: 220
  implicitHeight: 40

  function showCard() {
    closeTimer.stop()
    popupOpen = hasTrack
  }

  function closeCard() {
    closeTimer.stop()
    popupOpen = false
  }

  function close() {
    closeCard()
  }

  Timer {
    id: closeTimer
    interval: 220
    repeat: false
    onTriggered: {
      if (!mediaHover.hovered && !musicCard.containsMouse) root.closeCard()
    }
  }

  RowLayout {
    anchors.fill: parent
    spacing: 9

    Rectangle {
      id: artworkFrame

      Layout.preferredWidth: 38
      Layout.preferredHeight: 38
      Layout.alignment: Qt.AlignVCenter
      visible: root.hasTrack
      radius: 8
      clip: true
      color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.16)

      HoverHandler {
        id: mediaHover
        enabled: root.hasTrack
        onHoveredChanged: {
          if (hovered) root.showCard()
          else closeTimer.restart()
        }
      }

      Image {
        id: artwork

        anchors.fill: parent
        source: root.artworkUrl
        asynchronous: true
        cache: true
        fillMode: Image.PreserveAspectCrop
        visible: status === Image.Ready
      }

      Text {
        anchors.centerIn: parent
        visible: artwork.status !== Image.Ready
        text: "󰝚"
        color: root.accent
        font.family: root.fontFamily
        font.pixelSize: 18
      }
    }

    ColumnLayout {
      Layout.fillWidth: true
      Layout.fillHeight: true
      Layout.alignment: Qt.AlignVCenter
      spacing: root.artistText !== "" ? 1 : 0

      Text {
        Layout.fillWidth: true
        textFormat: Text.PlainText
        text: root.titleText
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: root.hasTrack ? Style.font.body : Style.font.subtitle
        font.weight: root.hasTrack ? Font.Medium : Font.Normal
        elide: Text.ElideRight
        maximumLineCount: 1
        verticalAlignment: Text.AlignVCenter
      }

      Text {
        Layout.fillWidth: true
        visible: root.artistText !== ""
        textFormat: Text.PlainText
        text: root.artistText
        color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.68)
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
        elide: Text.ElideRight
        maximumLineCount: 1
        verticalAlignment: Text.AlignVCenter
      }
    }
  }

  MediaCardPopup {
    id: musicCard
    anchorItem: root
    bar: root.bar
    owner: root
    player: root.player
    fontFamily: root.fontFamily
    open: root.popupOpen

    onContainsMouseChanged: {
      if (containsMouse) closeTimer.stop()
      else if (root.popupOpen && !mediaHover.hovered) closeTimer.restart()
    }
  }

  onHasTrackChanged: {
    if (!hasTrack) closeCard()
  }

  Connections {
    target: root.player
    function onPostTrackChanged() {
      root.playhead = root.player && root.player.positionSupported
        ? Number(root.player.position) || 0 : 0
    }
  }
}
