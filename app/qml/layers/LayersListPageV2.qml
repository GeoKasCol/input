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

import lc 1.0
import "../components" as MMComponents
import ".."

Page {
  id: root

  property var model: null
  property var parentNodeIndex: null
  property string pageTitle: qsTr("Layers")

  signal close()
  signal nodeClicked( var node, string nodeType, string nodeName )
  signal nodeVisibilityClicked( var node )
  signal searchboxClicked()

  Keys.onReleased: function( event ) {
    if (event.key === Qt.Key_Back || event.key === Qt.Key_Escape) {
      event.accepted = true
      root.close()
    }
  }

  header: MMComponents.PanelHeaderV2 {
    width: parent.width
    headerTitle: root.pageTitle
    onBackClicked: root.close()
  }

  MMComponents.SearchBoxV2 {
    id: searchbox

    anchors {
      left: parent.left
      leftMargin: InputStyle.panelMargin
      right: parent.right
      rightMargin: InputStyle.panelMargin
      top: parent.top
      topMargin: InputStyle.panelMarginV2
    }
  }

  MouseArea {
    anchors.fill: searchbox
    onClicked: root.searchboxClicked()
  }

  LayersListV2 {
    id: layers

    anchors {
      top: searchbox.bottom
      topMargin: InputStyle.panelMarginV2
      left: parent.left
      leftMargin: InputStyle.panelMargin
      right: parent.right
      rightMargin: InputStyle.panelMargin
      bottom: parent.bottom
    }

    clip: true

    model: root.model
    parentNodeIndex: root.parentNodeIndex

    imageProviderPath: "image://LayerTreeModelPixmapProvider/"

    onNodeClicked: function( node, nodeType, nodeName ) {
      root.nodeClicked( node, nodeType, nodeName )
    }

    onNodeVisibilityClicked: function( node ) {
      root.nodeVisibilityClicked( node )
    }
  }
}
