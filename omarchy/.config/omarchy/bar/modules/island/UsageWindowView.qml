import QtQuick
import QtQuick.Layouts
import qs.Commons

Item {
  id: root

  property string label: ""
  property string resetStyle: "time"
  property int remaining: -1
  property double resetAt: 0

  implicitHeight: content.implicitHeight

  function resetLabel() {
    if (!resetAt || resetAt <= 0) return ""
    var resetDate = new Date(resetAt * 1000)
    var now = new Date()
    var sameDate = resetDate.getFullYear() === now.getFullYear()
      && resetDate.getMonth() === now.getMonth()
      && resetDate.getDate() === now.getDate()
    if (resetStyle === "date") return Qt.formatDate(resetDate, "MMM dd")
    return sameDate ? Qt.formatTime(resetDate, "HH:mm")
      : Qt.formatDateTime(resetDate, "MMM dd HH:mm")
  }

  ColumnLayout {
    id: content
    anchors.left: parent.left
    anchors.right: parent.right
    spacing: Style.space(4)

    RowLayout {
      Layout.fillWidth: true
      spacing: Style.space(8)

      Text {
        Layout.fillWidth: true
        text: root.label
        color: Color.popups.text
        font.family: Style.font.family
        font.pixelSize: Style.font.body
        font.weight: Font.Medium
      }

      Text {
        text: root.remaining + "% left"
        color: Color.popups.text
        font.family: Style.font.family
        font.pixelSize: Style.font.body
        font.weight: Font.DemiBold
      }
    }

    Rectangle {
      Layout.fillWidth: true
      height: Style.space(4)
      radius: height / 2
      color: Qt.rgba(Color.popups.text.r, Color.popups.text.g, Color.popups.text.b, 0.13)

      Rectangle {
        width: parent.width * Math.max(0, Math.min(100, root.remaining)) / 100
        height: parent.height
        radius: parent.radius
        color: Color.accent
      }
    }

    Text {
      visible: root.resetAt > 0
      text: "resets " + root.resetLabel()
      color: Color.popups.text
      opacity: 0.64
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
    }
  }
}
