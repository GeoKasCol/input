/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic
import "."

RoundButton {
  id: control

  implicitWidth: icon.width * 2
  implicitHeight: icon.height * 2

  contentItem: MMIcon {
    id: icon

    source: __style.arrowLinkRightIcon
    color: control.enabled ? __style.forestColor : __style.mediumGreenColor
  }

  background: Rectangle {
    color: control.enabled ? control.down || control.hovered ? __style.grassColor : __style.whiteColor : __style.whiteColor
    border.color: control.enabled ? control.down || control.hovered ? __style.transparentColor : __style.forestColor : __style.mediumGreenColor

    border.width: 2 * __dp
    radius: control.implicitHeight / 2
  }
}
