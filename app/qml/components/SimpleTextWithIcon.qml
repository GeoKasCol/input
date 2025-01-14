/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
import QtQuick
import Qt5Compat.GraphicalEffects
import "./.."

Rectangle {
  property color fontColor: "white"
  property color bgColor: InputStyle.fontColorBright
  property string text: ""
  property string source: ""
  property real fontPixelSize: InputStyle.fontPixelSizeNormal
  property bool fontBold: false
  property real requestedWidth
  property alias icon: icon

  id: root
  color: root.bgColor

  signal clicked

  width: requestedWidth < label.paintedWidth ? label.paintedWidth + InputStyle.buttonMinPadding : requestedWidth

  MouseArea {
    anchors.fill: parent
    onClicked: {
      root.clicked()
    }
  }

  Row {
    anchors.centerIn: parent
    height: root.height
    spacing: 0

    Symbol {
      id: icon
      height: !!source ? root.height : 0
      width: height
      iconSize: height / 2
      source: root.source
      iconColor: root.fontColor
    }

    Text {
      id: label
      height: root.height
      text: root.text
      color: root.fontColor
      font.bold: root.fontBold
      font.pixelSize: root.fontPixelSize
      verticalAlignment: Text.AlignVCenter
      horizontalAlignment: Text.AlignHCenter
    }
  }
}
