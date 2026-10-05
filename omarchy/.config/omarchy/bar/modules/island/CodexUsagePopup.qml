import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Ui
import "."

PopupCard {
  id: root

  property var service: null

  triggerMode: "hover"
  contentWidth: fittedContentWidth(Style.space(280))
  contentHeight: fittedContentHeight(contentColumn.implicitHeight)

  ColumnLayout {
    id: contentColumn
    anchors.fill: parent
    spacing: Style.space(10)

    RowLayout {
      Layout.fillWidth: true
      spacing: Style.space(8)

      Text {
        Layout.fillWidth: true
        text: "Codex Usage"
        color: Color.popups.text
        font.family: Style.font.family
        font.pixelSize: Style.font.subtitle
        font.weight: Font.DemiBold
      }

      Text {
        visible: !!(root.service && root.service.planType)
        text: root.service ? root.service.planType : ""
        color: Color.popups.text
        opacity: 0.68
        font.family: Style.font.family
        font.pixelSize: Style.font.caption
      }
    }

    Rectangle {
      Layout.fillWidth: true
      height: 1
      color: Qt.rgba(Color.popups.text.r, Color.popups.text.g, Color.popups.text.b, 0.12)
    }

    ColumnLayout {
      Layout.fillWidth: true
      spacing: Style.space(8)
      visible: !!root.service && root.service.loading && !root.service.available

      Text {
        text: "Loading usage…"
        color: Color.popups.text
        opacity: 0.72
        font.family: Style.font.family
        font.pixelSize: Style.font.body
      }
    }

    ColumnLayout {
      Layout.fillWidth: true
      spacing: Style.space(5)
      visible: !root.service || (!root.service.available && !root.service.loading)

      Text {
        text: "Usage data unavailable"
        color: Color.popups.text
        font.family: Style.font.family
        font.pixelSize: Style.font.body
        font.weight: Font.Medium
      }

      Text {
        text: "Run /status in Codex CLI"
        color: Color.popups.text
        opacity: 0.68
        font.family: Style.font.family
        font.pixelSize: Style.font.caption
      }
    }

    ColumnLayout {
      Layout.fillWidth: true
      spacing: Style.space(9)
      visible: !!root.service && root.service.available

      UsageWindowView {
        Layout.fillWidth: true
        visible: root.service && root.service.fiveHourRemaining >= 0
        label: "5-hour"
        remaining: root.service ? root.service.fiveHourRemaining : -1
        resetAt: root.service ? root.service.fiveHourReset : 0
      }

      UsageWindowView {
        Layout.fillWidth: true
        visible: root.service && root.service.weeklyRemaining >= 0
        label: "Weekly"
        resetStyle: "date"
        remaining: root.service ? root.service.weeklyRemaining : -1
        resetAt: root.service ? root.service.weeklyReset : 0
      }

      Text {
        visible: root.service && root.service.fiveHourRemaining < 0
          && root.service.weeklyRemaining < 0
        text: "No usage windows reported"
        color: Color.popups.text
        opacity: 0.72
        font.family: Style.font.family
        font.pixelSize: Style.font.caption
      }

      RowLayout {
        Layout.fillWidth: true
        visible: root.service && root.service.credits !== ""
        spacing: Style.space(8)

        Text {
          Layout.fillWidth: true
          text: "Credits"
          color: Color.popups.text
          opacity: 0.72
          font.family: Style.font.family
          font.pixelSize: Style.font.caption
        }

        Text {
          text: root.service ? root.service.credits : ""
          color: Color.popups.text
          font.family: Style.font.family
          font.pixelSize: Style.font.caption
          font.weight: Font.Medium
        }
      }

      Text {
        visible: root.service && root.service.lastUpdated > 0
        text: root.service && root.service.lastUpdated > 0
          ? "Updated " + Qt.formatTime(new Date(root.service.lastUpdated), "HH:mm") : ""
        color: Color.popups.text
        opacity: 0.58
        font.family: Style.font.family
        font.pixelSize: Style.font.caption
      }
    }
  }
}
