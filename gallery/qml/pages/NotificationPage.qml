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

import "../../app/qml/components"
import "../../app/qml/form/editors"
import notificationType 1.0

Page {
  id: pane

  Rectangle {
    anchors.fill: parent
    color: "white"
  }

  Column {
    width: parent.width
    spacing: 20
    anchors.centerIn: parent

    MMButtonFormEditor {
      buttonText: "Send"
      anchors.horizontalCenter: parent.horizontalCenter
      placeholderText: "Write an informative message"
      onButtonClicked: { __notificationModel.add(text, 60, NotificationType.Information, NotificationType.None); text = "" }
    }
    MMButtonFormEditor {
      buttonText: "Send"
      anchors.horizontalCenter: parent.horizontalCenter
      placeholderText: "Write a success message"
      onButtonClicked: { __notificationModel.add(text, 60, NotificationType.Success, NotificationType.Check); text = "" }
    }
    MMButtonFormEditor {
      buttonText: "Send"
      anchors.horizontalCenter: parent.horizontalCenter
      placeholderText: "Write a warning message"
      onButtonClicked: { __notificationModel.add(text, 60, NotificationType.Warning, NotificationType.Waiting); text = "" }
    }
    MMButtonFormEditor {
      buttonText: "Send"
      anchors.horizontalCenter: parent.horizontalCenter
      placeholderText: "Write an error message"
      onButtonClicked: { __notificationModel.add(text, 60, NotificationType.Error, NotificationType.None); text = "" }
    }
    MMButtonFormEditor {
      buttonText: "Send"
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Stojí, stojí mohyla, Na mohyle zlá chvíľa, Na mohyle tŕnie chrastie A v tom tŕní, chrastí rastie, Rastie, kvety rozvíja Jedna žltá ľalia. Tá ľalia smutno vzdychá: „Hlávku moju tŕnie pichá A nožičky oheň páli – Pomôžte mi v mojom žiali!“ "
      onButtonClicked: { __notificationModel.add(text, 60, NotificationType.Information, NotificationType.None); text = "" }
    }
    Text {
      text: "Note: Notification will be removed in 1 minute"
      anchors.horizontalCenter: parent.horizontalCenter
      color: "green"
    }
  }

  MMNotificationView {}
}
