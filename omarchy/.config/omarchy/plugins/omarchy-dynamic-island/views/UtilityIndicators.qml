import QtQuick

Item {
  id: root

  property var island: null
  property string popupKey: ""
  readonly property bool popupOpen: codex.popupOpen || stats.popupOpen

  implicitWidth: indicators.implicitWidth
  implicitHeight: indicators.implicitHeight
  width: implicitWidth
  height: implicitHeight

  function syncPopupState() {
    if (island && popupKey !== "")
      island.setUtilityPopupOpen(popupKey, popupOpen)
  }

  onPopupOpenChanged: syncPopupState()
  Component.onCompleted: syncPopupState()
  Component.onDestruction: {
    if (island && popupKey !== "") island.setUtilityPopupOpen(popupKey, false)
  }

  QtObject {
    id: popupBar
    property string position: root.island ? root.island.barPosition : "top"
    property string fontFamily: root.island ? root.island.fontFamily : "monospace"
    property var activePopout: null

    function requestPopout(popout) { activePopout = popout }
    function releasePopout(popout) {
      if (activePopout === popout) activePopout = null
    }
  }

  Row {
    id: indicators
    spacing: root.island ? root.island.s(5) : 5

    CodexView {
      id: codex
      bar: popupBar
      service: root.island ? root.island.codexUsageService : null
      foreground: root.island ? root.island.fg : "white"
      accent: root.island ? root.island.accentColor : "white"
    }

    SystemStatsView {
      id: stats
      bar: popupBar
      service: root.island ? root.island.dailyStatsService : null
      foreground: root.island ? root.island.fg : "white"
      accent: root.island ? root.island.accentColor : "white"
    }

    InboxIndicator {
      island: root.island
      visible: root.island && root.island.showInbox
        && (root.island.unreadCount === 0 || root.island.userExpanded)
    }
  }
}
