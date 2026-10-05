import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Ui

PopupCard {
  id: root

  property var service: null
  property string period: "today"

  contentWidth: fittedContentWidth(Style.space(350))
  contentHeight: fittedContentHeight(
    root.period === "today" ? Style.space(150) : Style.space(380), Style.space(430))

  ColumnLayout {
    id: contentColumn
    anchors.fill: parent
    spacing: Style.space(10)

    RowLayout {
      Layout.fillWidth: true
      spacing: Style.space(8)

      Text {
        text: "󰄉"
        color: Color.accent
        font.family: Style.font.family
        font.pixelSize: Style.font.icon
      }

      Text {
        Layout.fillWidth: true
        text: "System activity"
        color: Color.popups.text
        font.family: Style.font.family
        font.pixelSize: Style.font.subtitle
        font.weight: Font.DemiBold
      }

      Text {
        text: root.service && root.service.loading ? "Updating…" : "Local"
        color: Color.popups.text
        opacity: 0.55
        font.family: Style.font.family
        font.pixelSize: Style.font.caption
      }
    }

    RowLayout {
      Layout.fillWidth: true
      spacing: Style.space(6)

      Repeater {
        model: [
          { key: "today", label: "Today" },
          { key: "week", label: "This week" }
        ]

        delegate: Rectangle {
          required property var modelData
          Layout.fillWidth: true
          height: Style.space(28)
          radius: Style.space(8)
          color: root.period === modelData.key
            ? Qt.rgba(Color.accent.r, Color.accent.g, Color.accent.b, 0.18)
            : Qt.rgba(Color.popups.text.r, Color.popups.text.g, Color.popups.text.b, 0.045)
          border.width: root.period === modelData.key ? 1 : 0
          border.color: Qt.rgba(Color.accent.r, Color.accent.g, Color.accent.b, 0.38)

          Text {
            anchors.centerIn: parent
            text: modelData.label
            color: Color.popups.text
            opacity: root.period === modelData.key ? 1 : 0.62
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            font.weight: root.period === modelData.key ? Font.DemiBold : Font.Normal
          }

          HoverHandler {
            cursorShape: Qt.PointingHandCursor
            onHoveredChanged: {
              if (hovered) root.period = modelData.key
            }
          }
        }
      }
    }

    ColumnLayout {
      Layout.fillWidth: true
      Layout.fillHeight: true
      visible: root.period === "today"
      spacing: Style.space(9)

      RowLayout {
        Layout.fillWidth: true
        spacing: Style.space(12)

        ColumnLayout {
          Layout.fillWidth: true
          spacing: Style.space(2)

          Text {
            text: "PC uptime today"
            color: Color.popups.text
            opacity: 0.62
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
          }

          Text {
            text: root.formatDuration(root.service && root.service.today
              ? root.service.today.uptimeSeconds : 0)
            color: Color.popups.text
            font.family: Style.font.family
            font.pixelSize: Style.font.title
            font.weight: Font.DemiBold
          }
        }

        Rectangle {
          width: 1
          height: Style.space(34)
          color: Qt.rgba(Color.popups.text.r, Color.popups.text.g, Color.popups.text.b, 0.12)
        }

        ColumnLayout {
          Layout.fillWidth: true
          spacing: Style.space(2)

          Text {
            text: "Battery now"
            color: Color.popups.text
            opacity: 0.62
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
          }

          Text {
            text: root.service && root.service.batteryNow >= 0
              ? root.service.batteryNow + "%" : "—"
            color: Color.popups.text
            font.family: Style.font.family
            font.pixelSize: Style.font.title
            font.weight: Font.DemiBold
          }
        }
      }
    }

    ColumnLayout {
      Layout.fillWidth: true
      Layout.fillHeight: true
      visible: root.period === "week"
      spacing: Style.space(4)

      Text {
        Layout.fillWidth: true
        text: "PC uptime per day"
        color: Color.popups.text
        opacity: 0.7
        font.family: Style.font.family
        font.pixelSize: Style.font.caption
      }

      ListView {
        id: weekList
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        spacing: Style.space(2)
        model: root.service ? root.service.days : []

        delegate: Rectangle {
          id: dayRow
          required property var modelData
          required property int index
          width: weekList.width
          height: Style.space(34)
          radius: Style.space(6)
          color: index % 2 === 0
            ? Qt.rgba(Color.popups.text.r, Color.popups.text.g, Color.popups.text.b, 0.035)
            : "transparent"

          RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Style.space(6)
            anchors.rightMargin: Style.space(6)
            spacing: Style.space(8)

            Text {
              Layout.preferredWidth: Style.space(82)
              text: dayRow.modelData.date === root.todayDate ? "Today"
                : Qt.formatDate(root.dateFromKey(dayRow.modelData.date), "ddd d")
              color: Color.popups.text
              opacity: 0.78
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
              font.weight: dayRow.modelData.date === root.todayDate ? Font.DemiBold : Font.Normal
            }

            Text {
              Layout.preferredWidth: Style.space(62)
              text: dayRow.modelData.hasData
                ? root.formatDuration(dayRow.modelData.uptimeSeconds) : "—"
              color: Color.popups.text
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
              horizontalAlignment: Text.AlignRight
            }

            Rectangle {
              Layout.fillWidth: true
              height: Style.space(5)
              radius: height / 2
              color: Qt.rgba(Color.popups.text.r, Color.popups.text.g, Color.popups.text.b, 0.1)

              Rectangle {
                width: parent.width * Math.min(1, Number(dayRow.modelData.uptimeSeconds || 0)
                  / Math.max(1, root.maxDayUptime))
                height: parent.height
                radius: parent.radius
                color: Color.accent
                opacity: 0.82
              }
          }
        }
        }
      }
    }

    Text {
      Layout.fillWidth: true
      text: root.service && root.service.lastUpdated > 0
        ? "Recorded locally · updated " + Qt.formatTime(new Date(root.service.lastUpdated), "HH:mm")
        : "Recorded locally · updates every 5 min"
      color: Color.popups.text
      opacity: 0.48
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
    }
  }

  readonly property string todayDate: Qt.formatDate(new Date(), "yyyy-MM-dd")
  readonly property real maxDayUptime: {
    let maximum = 0
    const rows = service ? service.days : []
    for (let i = 0; i < rows.length; i++)
      maximum = Math.max(maximum, Number(rows[i].uptimeSeconds || 0))
    return maximum
  }
  function formatDuration(seconds) {
    const totalMinutes = Math.max(0, Math.floor(Number(seconds || 0) / 60))
    const hours = Math.floor(totalMinutes / 60)
    const minutes = totalMinutes % 60
    if (hours === 0) return minutes + "m"
    if (minutes === 0) return hours + "h"
    return hours + "h " + minutes + "m"
  }

  function dateFromKey(key) {
    const parts = String(key || "").split("-")
    if (parts.length !== 3) return new Date()
    return new Date(Number(parts[0]), Number(parts[1]) - 1, Number(parts[2]))
  }

}
