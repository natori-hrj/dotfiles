import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Ui

PopupCard {
  id: root

  property var player: null
  property string fontFamily: Style.font.family
  property real playhead: 0

  readonly property real trackLength: player && player.lengthSupported
    ? Math.max(0, Number(player.length) || 0) : 0
  readonly property bool hasProgress: !!player && player.positionSupported
    && player.lengthSupported && trackLength > 0
  readonly property real progress: hasProgress
    ? Math.max(0, Math.min(1, playhead / trackLength)) : 0
  readonly property string titleText: player && player.trackTitle
    ? String(player.trackTitle) : "Unknown title"
  readonly property string artistText: player && player.trackArtist
    ? String(player.trackArtist) : "Unknown artist"
  readonly property string artUrl: player && player.trackArtUrl
    ? String(player.trackArtUrl) : ""
  readonly property string sourceLabel: playerLabel(player)

  triggerMode: "hover"
  padding: Style.space(12)
  contentWidth: fittedContentWidth(Style.space(388))
  contentHeight: fittedContentHeight(Style.space(136))

  function clamp(value, minValue, maxValue) {
    return Math.max(minValue, Math.min(maxValue, Number(value) || 0))
  }

  function formatTime(value) {
    var seconds = Math.max(0, Math.floor(Number(value) || 0))
    var minutes = Math.floor(seconds / 60)
    var remainder = seconds % 60
    return minutes + ":" + (remainder < 10 ? "0" : "") + remainder
  }

  function seekFromX(localX, width) {
    if (!player || !player.canSeek || !player.positionSupported || trackLength <= 0 || width <= 0) return
    var nextPosition = clamp(localX / width, 0, 1) * trackLength
    player.position = nextPosition
    playhead = nextPosition
  }

  function togglePlayback() {
    if (!player) return
    if (player.isPlaying && player.canPause) player.pause()
    else if (!player.isPlaying && player.canPlay) player.play()
    else if (player.canTogglePlaying) player.togglePlaying()
  }

  function playerLabel(value) {
    if (!value) return "NOW PLAYING"

    var identity = String(value.identity || "")
    var desktopEntry = String(value.desktopEntry || "")
    var dbusName = String(value.dbusName || "")
    var metadata = value.metadata || ({})
    var metadataUrl = ""
    try {
      metadataUrl = String(metadata["xesam:url"] || metadata["xesam:URL"]
        || metadata.url || "")
    } catch (e) {
      metadataUrl = ""
    }

    var source = (identity + " " + desktopEntry + " " + dbusName
      + " " + metadataUrl).toLowerCase()
    if (source.indexOf("music.youtube.com") !== -1
        || source.indexOf("youtube music") !== -1
        || source.indexOf("youtube-music") !== -1
        || source.indexOf("ytmusic") !== -1) {
      return "YouTube Music"
    }

    var isChromium = source.indexOf("chrome") !== -1
      || source.indexOf("chromium") !== -1
      || source.indexOf("brave") !== -1
      || source.indexOf("vivaldi") !== -1
      || source.indexOf("microsoft-edge") !== -1
    if (isChromium && value.trackArtist && value.trackArtUrl)
      return "YouTube Music"

    return identity || desktopEntry || "NOW PLAYING"
  }

  onPlayerChanged: playhead = player && player.positionSupported ? Number(player.position) || 0 : 0

  RowLayout {
    anchors.fill: parent
    spacing: Style.space(14)

    Rectangle {
      id: artFrame
      Layout.preferredWidth: Style.space(128)
      Layout.preferredHeight: Style.space(128)
      Layout.alignment: Qt.AlignVCenter
      radius: Style.space(10)
      clip: true
      color: Qt.rgba(Color.accent.r, Color.accent.g, Color.accent.b, 0.13)

      Image {
        id: artwork
        anchors.fill: parent
        source: root.artUrl
        asynchronous: true
        cache: true
        fillMode: Image.PreserveAspectCrop
        visible: status === Image.Ready
      }

      Text {
        anchors.centerIn: parent
        visible: !artwork.visible
        text: "󰝚"
        color: Color.accent
        font.family: root.fontFamily
        font.pixelSize: Style.space(38)
      }

      Timer {
        interval: 500
        repeat: true
        running: root.open && root.player && root.player.isPlaying && root.hasProgress
        onTriggered: root.playhead = Number(root.player.position) || 0
      }
    }

    ColumnLayout {
      Layout.fillWidth: true
      Layout.fillHeight: true
      spacing: Style.space(5)

      RowLayout {
        Layout.fillWidth: true

        Text {
          Layout.fillWidth: true
          text: root.sourceLabel.toUpperCase()
          color: Color.accent
          opacity: 0.9
          font.family: Style.font.family
          font.pixelSize: Style.font.caption
          font.weight: Font.DemiBold
          elide: Text.ElideRight
          maximumLineCount: 1
        }

        Text {
          visible: root.player && root.player.isPlaying
          text: "󰐊"
          color: Color.accent
          font.family: root.fontFamily
          font.pixelSize: Style.font.icon
        }
      }

      Text {
        Layout.fillWidth: true
        text: root.titleText
        color: Color.popups.text
        font.family: Style.font.family
        font.pixelSize: Style.font.subtitle
        font.weight: Font.DemiBold
        elide: Text.ElideRight
        maximumLineCount: 1
      }

      Text {
        Layout.fillWidth: true
        text: root.artistText
        color: Color.popups.text
        opacity: 0.66
        font.family: Style.font.family
        font.pixelSize: Style.font.caption
        elide: Text.ElideRight
        maximumLineCount: 1
      }

      Item { Layout.fillHeight: true; Layout.minimumHeight: 0 }

      ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.space(3)
        visible: root.hasProgress

        MouseArea {
          id: progressArea
          Layout.fillWidth: true
          Layout.preferredHeight: Style.space(12)
          enabled: root.player && root.player.canSeek
          cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
          onClicked: root.seekFromX(mouse.x, width)

          Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            height: Style.space(3)
            radius: height / 2
            color: Qt.rgba(Color.popups.text.r, Color.popups.text.g, Color.popups.text.b, 0.16)

            Rectangle {
              width: parent.width * root.progress
              height: parent.height
              radius: parent.radius
              color: Color.accent
            }
          }
        }

        RowLayout {
          Layout.fillWidth: true

          Text {
            Layout.fillWidth: true
            text: root.formatTime(root.playhead)
            color: Color.popups.text
            opacity: 0.56
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
          }

          Text {
            text: "−" + root.formatTime(Math.max(0, root.trackLength - root.playhead))
            color: Color.popups.text
            opacity: 0.56
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
          }
        }
      }

      RowLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: Style.space(12)

        Item {
          Layout.preferredWidth: Style.space(30)
          Layout.preferredHeight: Style.space(28)
          opacity: root.player && root.player.canGoPrevious ? 1 : 0.38

          Text {
            anchors.centerIn: parent
            text: "󰒮"
            color: Color.popups.text
            font.family: root.fontFamily
            font.pixelSize: Style.font.icon
          }

          MouseArea {
            anchors.fill: parent
            enabled: root.player && root.player.canGoPrevious
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: root.player.previous()
          }
        }

        Rectangle {
          Layout.preferredWidth: Style.space(34)
          Layout.preferredHeight: Style.space(34)
          radius: width / 2
          color: Qt.rgba(Color.accent.r, Color.accent.g, Color.accent.b, 0.2)
          border.width: 1
          border.color: Qt.rgba(Color.accent.r, Color.accent.g, Color.accent.b, 0.35)

          Text {
            anchors.centerIn: parent
            text: root.player && root.player.isPlaying ? "󰏤" : "󰐊"
            color: Color.popups.text
            font.family: root.fontFamily
            font.pixelSize: Style.font.iconLarge
          }

          MouseArea {
            anchors.fill: parent
            enabled: root.player && (root.player.canTogglePlaying
              || root.player.canPlay || root.player.canPause)
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: root.togglePlayback()
          }
        }

        Item {
          Layout.preferredWidth: Style.space(30)
          Layout.preferredHeight: Style.space(28)
          opacity: root.player && root.player.canGoNext ? 1 : 0.38

          Text {
            anchors.centerIn: parent
            text: "󰒭"
            color: Color.popups.text
            font.family: root.fontFamily
            font.pixelSize: Style.font.icon
          }

          MouseArea {
            anchors.fill: parent
            enabled: root.player && root.player.canGoNext
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: root.player.next()
          }
        }
      }
    }
  }
}
