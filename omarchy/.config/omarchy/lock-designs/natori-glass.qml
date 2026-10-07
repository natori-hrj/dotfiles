import QtQuick
import qs.Commons
import "../plugins/io.github.sirjul1337.lock-explorer/designs"

DesignBase {
  id: lock
  inputItem: field.input

  Wallpaper {
    anchors.fill: parent
    lock: lock
    blur: 0.55
    dim: 0.18
    contrast: -0.04
    vignette: true
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    onClicked: { lock.wakeRequested(); lock.forcePasswordFocus() }
    onPositionChanged: lock.wakeRequested()
  }

  Rectangle {
    id: panel
    anchors.centerIn: parent
    width: Math.min(520, Math.max(280, parent.width - 48))
    height: content.implicitHeight + 72
    radius: 28
    color: lock.withAlpha(Color.lock.background, 0.72)
    border.width: 1
    border.color: lock.withAlpha(Color.lock.text, 0.18)

    Rectangle {
      x: 36
      y: 0
      width: 72
      height: 2
      radius: 1
      color: lock.withAlpha(Color.lock.text, 0.55)
    }

    Column {
      id: content
      anchors.centerIn: parent
      width: parent.width - 64
      spacing: 20

      Column {
        width: parent.width
        spacing: 8

        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          text: lock.clock("HH:mm")
          color: Color.lock.text
          font.family: Style.font.family
          font.pixelSize: Math.round(Style.font.displayLarge * 1.7)
          font.weight: Font.DemiBold
          font.letterSpacing: 2
        }

        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          text: lock.date("dddd, d MMMM").toLowerCase()
          color: lock.withAlpha(Color.lock.text, 0.58)
          font.family: Style.font.family
          font.pixelSize: Style.font.bodySmall
          font.letterSpacing: 1.5
        }
      }

      Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width * 0.42
        height: 1
        color: lock.withAlpha(Color.lock.text, 0.14)
      }

      Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 16

        Item {
          width: 58
          height: 58

          Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: "transparent"
            border.width: 1
            border.color: lock.withAlpha(Color.lock.text, 0.28)
          }

          Avatar {
            anchors.centerIn: parent
            lock: lock
            width: 50
            visible: lock.hasAvatar
            shadow: false
          }
        }

        Column {
          anchors.verticalCenter: parent.verticalCenter
          spacing: 5

          Text {
            text: String(lock.userName || "natori").toLowerCase()
            color: Color.lock.text
            font.family: Style.font.family
            font.pixelSize: Style.font.heading
            font.weight: Font.DemiBold
          }

          Text {
            text: lock.errorState ? lock.failureMessage : lock.tr("Press Enter to unlock")
            textFormat: Text.PlainText
            color: lock.errorState ? Color.lock.textError : lock.withAlpha(Color.lock.text, 0.55)
            font.family: Style.font.family
            font.pixelSize: Style.font.bodySmall
          }
        }
      }

      PasswordField {
        id: field
        lock: lock
        width: parent.width
        height: 56
        radius: 28
        showLockGlyph: false
        placeholder: lock.tr("Enter password")
        outlineThickness: 1
        color: lock.withAlpha(Color.lock.background, 0.42)
      }
    }
  }
}
