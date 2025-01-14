/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

import QtQuick
import ".."

Item {
  id: root

  property double maxWidth
  property alias content: contentContainer.children
  property bool withImplicitMargins: true

  signal clicked()
  signal pressAndHold()

  height: InputStyle.mapBtnHeight
  width: childrenRect.width

  Rectangle {
    id: rect

    height: parent.height

    border.width: InputStyle.borderSize
    border.color: InputStyle.darkGreen

    implicitWidth: Math.min( contentContainer.childrenRect.width, root.maxWidth ) + ( root.withImplicitMargins ? InputStyle.smallGap : 0 )

    radius: InputStyle.cornerRadius
    color: InputStyle.panelBackgroundLight

    layer.enabled: true
    layer.effect: Shadow { verticalOffset: 0; horizontalOffset: 0; radius: 7; }

    Item {
      id: contentContainer
      // component placeholder, component passed via content property will become a child of this element

      height: parent.height
      anchors.horizontalCenter: parent.horizontalCenter
    }

    Item {
      anchors.fill: parent
      
      MouseArea {
        anchors.fill: parent

        onClicked: {
          root.clicked()
        }

        onPressAndHold: {
          root.pressAndHold()
        }
      }
    }
  }
}
