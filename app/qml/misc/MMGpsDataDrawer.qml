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
import QtQuick.Layouts
import ".."
import "../components"
import lc 1.0

Drawer {
  id: root

  property var mapSettings
  property string coordinatesInDegrees: __inputUtils.degreesString( __positionKit.positionCoordinate )
  property var title
  property real rowHeight: 67 * __dp

  width: ApplicationWindow.window.width
  height: (mainColumn.height > ApplicationWindow.window.height ? ApplicationWindow.window.height : mainColumn.height) - 20 * __dp
  edge: Qt.BottomEdge

  focus: true

  Component.onCompleted: {
    forceActiveFocus()
  }

  MapPosition {
    id: mapPositioning

    positionKit: __positionKit
    mapSettings: root.mapSettings
  }

  StackView {
    id: additionalContent

    anchors.fill: parent
  }

  Component {
    id: positionProviderComponent

    PositionProviderPage {
      onClose: additionalContent.pop(null)
      stackView: additionalContent
      Component.onCompleted: forceActiveFocus()
    }
  }

  Rectangle {
    color: roundedRect.color
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    height: 2 * radius
    anchors.topMargin: -radius
    radius: 20 * __dp
  }

  Rectangle {
    id: roundedRect

    anchors.fill: parent
    color: __style.whiteColor

    ColumnLayout {

      id: mainColumn

      width: parent.width
      spacing: 40 * __dp

      MMHeader {
        id: header

        rightMarginShift: 0
        backVisible: false

        title: qsTr("GPS info")
        titleFont: __style.t2

        MMRoundButton {
          id: backBtn

          anchors.right: parent.right
          anchors.rightMargin: __style.pageMargins
          anchors.verticalCenter: parent.verticalCenter

          iconSource: __style.closeIcon
          iconColor: __style.forestColor

          bgndColor: __style.lightGreenColor
          bgndHoverColor: __style.mediumGreenColor

          onClicked: root.visible = false
        }
      }

      ScrollView {
        id: scrollView

        Layout.fillWidth: true
        Layout.leftMargin: 20 * __dp
        Layout.rightMargin: 20 * __dp
        Layout.maximumWidth: __style.maxPageWidth
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredHeight: {
          if (ApplicationWindow.window){
            var availableHeight = ApplicationWindow.window.height - header.height - mainColumn.spacing
            var totalHeight = scrollColumn.childrenRect.height + 20 * __dp

            if(totalHeight >= ApplicationWindow.window.height) {
              return availableHeight
            }
            return totalHeight
          }
          return 0
        }
        contentWidth: availableWidth
        contentHeight: scrollColumn.childrenRect.height

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AlwaysOff

        Column{
          id: scrollColumn

          width: parent.width
          spacing: 0

          Row {
            width: parent.width
            height: rowHeight

            MMGpsDataText{
              titleText: qsTr( "Source" )
              descriptionText: __positionKit.positionProvider ? __positionKit.positionProvider.name() : qsTr( "No receiver" )
            }

            MMGpsDataText{
              titleText: qsTr( "Status" )
              descriptionText: __positionKit.positionProvider ? __positionKit.positionProvider.stateMessage : ""
              alignmentRight: true
              itemVisible: __positionKit.positionProvider && __positionKit.positionProvider.type() === "external"
            }
          }

          MMLine {}

          Row {
            width: parent.width
            height: rowHeight

            MMGpsDataText{
              titleText: qsTr( "Latitude" )
              descriptionText: {
                if ( !__positionKit.hasPosition || Number.isNaN( __positionKit.latitude ) ) {
                  return qsTr( "N/A" )
                }

                let coordParts = root.coordinatesInDegrees.split(", ")
                if ( coordParts.length > 1 )
                  return coordParts[0]

                return qsTr( "N/A" )
              }
            }

            MMGpsDataText{
              titleText: qsTr( "Longitude")
              descriptionText: {
                if ( !__positionKit.hasPosition || Number.isNaN( __positionKit.longitude ) ) {
                  return qsTr( "N/A" )
                }

                let coordParts = root.coordinatesInDegrees.split(", ")
                if ( coordParts.length > 1 )
                  return coordParts[1]

                return qsTr( "N/A" )
              }
              alignmentRight: true
            }
          }

          MMLine {}

          Row {
            width: parent.width
            height: rowHeight

            MMGpsDataText{
              titleText: qsTr( "X" )
              descriptionText: {
                if ( !__positionKit.hasPosition || Number.isNaN( mapPositioning.mapPosition.x ) ) {
                  return qsTr( "N/A" )
                }

                __inputUtils.formatNumber( mapPositioning.mapPosition.x, 2 )
              }
            }

            MMGpsDataText{
              titleText: qsTr( "Y" )
              descriptionText: {
                if ( !__positionKit.hasPosition || Number.isNaN( mapPositioning.mapPosition.y ) ) {
                  return qsTr( "N/A" )
                }

                __inputUtils.formatNumber( mapPositioning.mapPosition.y, 2 )
              }
              alignmentRight: true
            }
          }

          MMLine {}

          Row {
            width: parent.width
            height: rowHeight

            MMGpsDataText{
              titleText: qsTr( "Horizontal accuracy" )
              descriptionText: {
                if ( !__positionKit.hasPosition || __positionKit.horizontalAccuracy < 0 ) {
                  return qsTr( "N/A" )
                }

                __inputUtils.formatNumber( __positionKit.horizontalAccuracy, 2 ) + " m"
              }
            }

            MMGpsDataText{
              titleText: qsTr( "Vertical accuracy" )
              descriptionText: {
                if ( !__positionKit.hasPosition || __positionKit.verticalAccuracy < 0 ) {
                  return qsTr( "N/A" )
                }

                __inputUtils.formatNumber( __positionKit.verticalAccuracy, 2 ) + " m"
              }
              alignmentRight: true
            }
          }

          MMLine {}

          Row {
            width: parent.width
            height: rowHeight

            MMGpsDataText{
              titleText: qsTr( "Altitude" )
              descriptionText: {
                if ( !__positionKit.hasPosition || Number.isNaN( __positionKit.altitude ) ) {
                  return qsTr( "N/A" )
                }
                __inputUtils.formatNumber( __positionKit.altitude, 2 ) + " m"
              }
            }

            MMGpsDataText{
              titleText: qsTr( "Satellites (in use/view)" )
              descriptionText: {
                if ( __positionKit.satellitesUsed < 0 || __positionKit.satellitesVisible < 0 )
                {
                  return qsTr( "N/A" )
                }

                __positionKit.satellitesUsed + "/" + __positionKit.satellitesVisible
              }
              alignmentRight: true
            }
          }

          MMLine {}

          Row {
            width: parent.width
            height: rowHeight

            MMGpsDataText{
              titleText: qsTr( "Speed" )
              descriptionText: {
                if ( !__positionKit.hasPosition || __positionKit.speed < 0 ) {
                  return qsTr( "N/A" )
                }

                __inputUtils.formatNumber( __positionKit.speed, 2 ) + " km/h"
              }
            }

            MMGpsDataText{
              titleText: qsTr( "Last Fix" )
              descriptionText: __positionKit.lastRead.toLocaleTimeString( Qt.locale() ) || qsTr( "N/A" )
              alignmentRight: true
            }
          }

          MMLine {}

          Row {
            width: parent.width
            height: rowHeight

            MMGpsDataText{
              titleText: qsTr( "GPS antenna height" )
              descriptionText: __appSettings.gpsAntennaHeight > 0 ? __inputUtils.formatNumber(__appSettings.gpsAntennaHeight, 3) + " m" : qsTr( "Not set" )
            }
          }

          Item {
            width: 1
            height: 20 * __dp
          }

          MMButton {
            id: primaryButton

            width: parent.width - 2 * 20 * __dp
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 20

            text: qsTr("Manage GPS receivers")

            onClicked: {
              additionalContent.push( positionProviderComponent )
            }
          }

          Item {
            width: 2
            height: 20 * __dp
          }
        }
      }
    }
  }
}

