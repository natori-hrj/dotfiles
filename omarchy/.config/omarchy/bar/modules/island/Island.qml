import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell.Services.Mpris
import qs.Commons
import "."

Item {
  id: root

  property var bar: null
  property string moduleName: ""
  property var settings: ({})
  property string clockText: Qt.formatTime(new Date(), "HH:mm")
  readonly property bool interactive: visible

  readonly property var players: Mpris.players ? Mpris.players.values : []
  readonly property var activePlayer: selectActivePlayer()
  readonly property bool hasMedia: !!(activePlayer && (activePlayer.trackTitle
    || activePlayer.trackArtist || activePlayer.trackAlbum || activePlayer.trackArtUrl))
  readonly property string presentationState: hasMedia ? "media" : "idle"
  readonly property color islandForeground: Color.bar.text
  readonly property color islandBackground: Color.bar.background
  readonly property color islandBorder: Qt.rgba(0.60, 0.59, 0.61, 0.22)
  readonly property real sideInset: 20
  readonly property real bottomRadius: 10
  property bool expanded: false
  readonly property int compactWidth: 58
  readonly property int expandedWidth: 530

  implicitWidth: expanded ? expandedWidth : compactWidth
  implicitHeight: 64

  function selectActivePlayer() {
    var trackCandidate = null
    var controllableCandidate = null

    for (var i = 0; i < players.length; i++) {
      var player = players[i]
      if (!player) continue

      var hasTrack = player.trackTitle || player.trackArtist
        || player.trackAlbum || player.trackArtUrl
      var canControl = player.canTogglePlaying || player.canPlay || player.canPause
        || player.canGoPrevious || player.canGoNext

      if (player.isPlaying && (hasTrack || canControl)) return player
      if (!trackCandidate && hasTrack) trackCandidate = player
      if (!controllableCandidate && canControl) controllableCandidate = player
    }

    return trackCandidate || controllableCandidate || null
  }

  function triggerPress(button) {
    // Child controls register their own click targets. This no-op consumes
    // clicks on the Island surface itself and prevents the bar gesture from
    // interpreting a double-click on the Island as a transparency toggle.
  }

  Timer {
    id: collapseTimer
    interval: 200
    repeat: false
    onTriggered: {
      if (islandHover.hovered) return
      if (mediaView.popupOpen || codexView.popupOpen || systemStatsView.popupOpen
          || notificationView.keepIslandExpanded) {
        restart()
        return
      }
      root.expanded = false
    }
  }

  Timer {
    interval: 1000
    repeat: true
    running: true
    triggeredOnStart: true
    onTriggered: root.clockText = Qt.formatTime(new Date(), "HH:mm")
  }

  CodexUsageService {
    id: codexUsage
  }

  DailyStatsService {
    id: dailyStats
  }

  NotificationHistoryService {
    id: notificationHistory
  }

  Item {
    id: islandFrame
    anchors.horizontalCenter: parent.horizontalCenter
    width: root.expanded ? root.expandedWidth : root.compactWidth
    height: parent.height

    Behavior on width {
      NumberAnimation { duration: 230; easing.type: Easing.OutCubic }
    }

    HoverHandler {
      id: islandHover
      onHoveredChanged: {
        if (hovered) {
          collapseTimer.stop()
          root.expanded = true
        } else if (root.expanded) {
          collapseTimer.restart()
        }
      }
    }

    Rectangle {
      id: compactClockPlate
      anchors.horizontalCenter: parent.horizontalCenter
      y: compactClock.y + (compactClock.height - height) / 2
      width: compactClock.width + Style.space(10)
      height: Style.space(20)
      radius: height / 2
      color: Qt.rgba(0.075, 0.075, 0.08, 0.82)
      border.width: 1
      border.color: Qt.rgba(root.islandForeground.r, root.islandForeground.g,
        root.islandForeground.b, 0.2)
      opacity: compactClock.opacity
      visible: opacity > 0

      Behavior on opacity {
        NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
      }
    }

    ClockView {
      id: compactClock
      width: 40
      height: 26
      y: {
        const rowHeight = root.bar && root.bar.barSize > 0 ? root.bar.barSize : parent.height
        const rowTop = root.bar && root.bar.position === "bottom"
          ? parent.height - rowHeight : 0
        return rowTop + (rowHeight - height) / 2
      }
      anchors.horizontalCenter: parent.horizontalCenter
      timeText: root.clockText
      fontFamily: root.bar ? root.bar.fontFamily : "monospace"
      accentColor: root.islandForeground
      fontSize: 13
      opacity: root.expanded ? 0 : 1
      visible: opacity > 0

      Behavior on opacity {
        NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
      }
    }

    Item {
    id: animatedIsland
    anchors.left: parent.left
    anchors.right: parent.right
    height: parent.height
    y: root.expanded ? 0 : -height
    opacity: root.expanded ? 1 : 0
    visible: opacity > 0

    Behavior on y {
      NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
    }

    Behavior on opacity {
      NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
    }

  // Screen-attached tab: a straight top edge continues off the screen, while
  // the sides taper inward to softly rounded lower corners.
  Shape {
    anchors.fill: parent
    antialiasing: true
    ShapePath {
      fillColor: root.islandBackground
      strokeColor: "transparent"
      startX: 0
      startY: 0

      PathLine { x: islandFrame.width; y: 0 }
      PathLine { x: islandFrame.width - root.sideInset; y: root.height - root.bottomRadius }
      PathQuad {
        controlX: islandFrame.width - root.sideInset
        controlY: root.height
        x: islandFrame.width - root.sideInset - root.bottomRadius
        y: root.height
      }
      PathLine { x: root.sideInset + root.bottomRadius; y: root.height }
      PathQuad {
        controlX: root.sideInset
        controlY: root.height
        x: root.sideInset
        y: root.height - root.bottomRadius
      }
      PathLine { x: 0; y: 0 }
    }
  }

  // Outline the angled sides and lower corners only; never draw a line along
  // the physical screen edge.
  Shape {
    anchors.fill: parent
    antialiasing: true
    ShapePath {
      fillColor: "transparent"
      strokeColor: root.islandBorder
      strokeWidth: 1
      startX: islandFrame.width
      startY: 0

      PathLine { x: islandFrame.width - root.sideInset; y: root.height - root.bottomRadius }
      PathQuad {
        controlX: islandFrame.width - root.sideInset
        controlY: root.height
        x: islandFrame.width - root.sideInset - root.bottomRadius
        y: root.height
      }
      PathLine { x: root.sideInset + root.bottomRadius; y: root.height }
      PathQuad {
        controlX: root.sideInset
        controlY: root.height
        x: root.sideInset
        y: root.height - root.bottomRadius
      }
      PathLine { x: 0; y: 0 }
    }
  }

  RowLayout {
    anchors.fill: parent
    anchors.leftMargin: 18
    anchors.rightMargin: 18
    spacing: 10
    enabled: root.expanded

    ClockView {
      Layout.preferredWidth: 46
      Layout.fillHeight: true
      timeText: root.clockText
      fontFamily: root.bar ? root.bar.fontFamily : "monospace"
      accentColor: root.islandForeground
    }

    Rectangle {
      Layout.preferredWidth: 1
      Layout.preferredHeight: 24
      Layout.alignment: Qt.AlignVCenter
      color: Qt.rgba(root.islandForeground.r, root.islandForeground.g,
        root.islandForeground.b, 0.16)
    }

    MediaView {
      id: mediaView
      Layout.fillWidth: true
      Layout.minimumWidth: 160
      Layout.preferredWidth: 220
      Layout.fillHeight: true
      player: root.activePlayer
      bar: root.bar
      foreground: root.islandForeground
      accent: Color.accent
      fontFamily: root.bar ? root.bar.fontFamily : "monospace"
    }

    MediaControls {
      visible: root.expanded
      Layout.preferredWidth: 78
      Layout.preferredHeight: 30
      player: root.activePlayer
      bar: root.bar
      foreground: root.islandForeground
      fontFamily: root.bar ? root.bar.fontFamily : "monospace"
    }

    CodexView {
      id: codexView
      Layout.preferredWidth: 24
      Layout.preferredHeight: 28
      bar: root.bar
      service: codexUsage
      foreground: root.islandForeground
      accent: Color.accent
      fontFamily: root.bar ? root.bar.fontFamily : "monospace"
    }

    SystemStatsView {
      id: systemStatsView
      visible: root.expanded
      Layout.preferredWidth: 24
      Layout.preferredHeight: 28
      bar: root.bar
      service: dailyStats
      foreground: root.islandForeground
      accent: Color.accent
    }

    NotificationView {
      id: notificationView
      visible: root.expanded
      Layout.preferredWidth: 24
      Layout.preferredHeight: 28
      bar: root.bar
      service: notificationHistory
      foreground: root.islandForeground
      accent: Color.accent
      fontFamily: root.bar ? root.bar.fontFamily : "monospace"
    }
    }
  }
  }
}
