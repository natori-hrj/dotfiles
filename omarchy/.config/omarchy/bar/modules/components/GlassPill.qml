import QtQuick

Rectangle {
  id: root

  default property alias contentItem: content.data
  property color foreground: "white"

  implicitWidth: content.implicitWidth + 20
  implicitHeight: 22

  radius: implicitHeight / 2

  color: Qt.rgba(0.10, 0.11, 0.14, 0.82)

  border.width: 1
  border.color: Qt.rgba(1, 1, 1, 0.08)

  Row {
    id: content
    anchors.centerIn: parent
    spacing: 6
  }
}
