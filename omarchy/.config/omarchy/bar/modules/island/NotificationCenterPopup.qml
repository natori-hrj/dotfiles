import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Ui
import "."

PopupCard {
  id: root

  property var service: null
  property bool unreadOnly: false
  readonly property var displayedEntries: {
    if (!service) return []
    return unreadOnly ? service.unreadEntries : service.entries
  }

  triggerMode: unreadOnly ? "hover" : "click"
  contentWidth: fittedContentWidth(Style.space(380))
  contentHeight: fittedContentHeight(unreadOnly ? 250 : 400)
  padding: Style.space(14)

  ColumnLayout {
    anchors.fill: parent
    spacing: Style.space(10)

    RowLayout {
      Layout.fillWidth: true
      spacing: Style.space(8)

      Text {
        text: "󰂚"
        color: Color.accent
        font.family: Style.font.family
        font.pixelSize: Style.font.icon
      }

      Text {
        Layout.fillWidth: true
        text: root.unreadOnly ? "Unread notifications" : "Notifications"
        color: Color.popups.text
        font.family: Style.font.family
        font.pixelSize: Style.font.subtitle
        font.weight: Font.DemiBold
      }

      Text {
        visible: root.displayedEntries.length > 0
        text: String(root.displayedEntries.length)
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

    ListView {
      id: historyList
      Layout.fillWidth: true
      Layout.fillHeight: true
      clip: true
      spacing: Style.space(4)
      model: root.displayedEntries
      visible: count > 0

      delegate: Rectangle {
        id: notificationRow
        required property var modelData

        width: historyList.width
        height: Math.max(58, contentRow.implicitHeight + Style.space(16))
        radius: Style.space(10)
        color: rowHover.hovered
          ? Qt.rgba(Color.popups.text.r, Color.popups.text.g, Color.popups.text.b, 0.06)
          : "transparent"
        border.width: modelData.urgency >= 2 ? 1 : 0
        border.color: Qt.rgba(Color.urgent.r, Color.urgent.g, Color.urgent.b, 0.45)

        HoverHandler { id: rowHover }

        RowLayout {
          id: contentRow
          anchors.fill: parent
          anchors.margins: Style.space(8)
          spacing: Style.space(10)

          Item {
            Layout.preferredWidth: Style.space(32)
            Layout.preferredHeight: Style.space(32)

            Rectangle {
              anchors.fill: parent
              radius: Style.space(8)
              color: Qt.rgba(Color.popups.text.r, Color.popups.text.g, Color.popups.text.b, 0.07)
            }

            Image {
              id: appIcon
              anchors.fill: parent
              anchors.margins: Style.space(5)
              source: root.iconSource(notificationRow.modelData.appIcon)
              fillMode: Image.PreserveAspectFit
              asynchronous: true
              visible: status === Image.Ready
            }

            Text {
              anchors.centerIn: parent
              visible: !appIcon.visible
              text: notificationRow.modelData.app
                ? notificationRow.modelData.app.charAt(0).toUpperCase() : "•"
              color: Color.accent
              font.family: Style.font.family
              font.pixelSize: Style.font.body
              font.weight: Font.DemiBold
            }
          }

          ColumnLayout {
            Layout.fillWidth: true
            spacing: Style.space(2)

            RowLayout {
              Layout.fillWidth: true
              spacing: Style.space(6)

              Text {
                Layout.fillWidth: true
                text: notificationRow.modelData.summary
                color: Color.popups.text
                font.family: Style.font.family
                font.pixelSize: Style.font.body
                font.weight: Font.Medium
                elide: Text.ElideRight
              }

              Text {
                text: notificationRow.modelData.timestamp > 0
                  ? Qt.formatTime(new Date(notificationRow.modelData.timestamp), "HH:mm") : ""
                color: Color.popups.text
                opacity: 0.55
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
              }
            }

            Text {
              Layout.fillWidth: true
              visible: notificationRow.modelData.app !== ""
              text: notificationRow.modelData.app
              color: Color.popups.text
              opacity: 0.56
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
              elide: Text.ElideRight
            }

            Text {
              Layout.fillWidth: true
              visible: notificationRow.modelData.body !== ""
              text: notificationRow.modelData.body
              color: Color.popups.text
              opacity: 0.82
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
              wrapMode: Text.WordWrap
              maximumLineCount: 2
              elide: Text.ElideRight
            }
          }
        }
      }
    }

    Item {
      Layout.fillWidth: true
      Layout.fillHeight: true
      visible: !historyList.visible

      ColumnLayout {
        anchors.centerIn: parent
        spacing: Style.space(8)

        Text {
          Layout.alignment: Qt.AlignHCenter
          text: root.service && root.service.loading ? "…" : "󰂜"
          color: Color.popups.text
          opacity: 0.45
          font.family: Style.font.family
          font.pixelSize: Style.font.title
        }

        Text {
          Layout.alignment: Qt.AlignHCenter
          text: root.service && root.service.loading ? "Loading notifications"
            : (root.unreadOnly ? "No unread notifications" : "No notifications yet")
          color: Color.popups.text
          opacity: 0.65
          font.family: Style.font.family
          font.pixelSize: Style.font.caption
        }
      }
    }
  }

  function iconSource(value) {
    var icon = String(value || "")
    if (!icon) return ""
    if (icon.indexOf("file://") === 0 || icon.charAt(0) === "/") return icon
    if (icon.indexOf("://") !== -1) return ""
    return Quickshell.iconPath(icon, true)
  }
}
