import QtQuick
import "island"

Item {
  id: root

  // Use a distinct API property so the host bar does not treat this custom
  // module as a first-party widget with direct access to its Bar object.
  property var barApi: null

  implicitWidth: island.implicitWidth
  implicitHeight: island.implicitHeight

  Island {
    id: island
    anchors.fill: parent
    bar: root.barApi
  }
}
