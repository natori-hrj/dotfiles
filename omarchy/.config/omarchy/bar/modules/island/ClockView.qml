import QtQuick

Text {
  id: root

  property string timeText: "00:00"
  property string fontFamily: "monospace"
  property color accentColor: "white"
  property int fontSize: 15

  text: timeText
  color: accentColor
  font.family: fontFamily
  font.pixelSize: fontSize
  font.weight: Font.DemiBold
  horizontalAlignment: Text.AlignHCenter
  verticalAlignment: Text.AlignVCenter
  renderType: Text.NativeRendering
}
