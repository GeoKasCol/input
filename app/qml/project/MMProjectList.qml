﻿/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import lc 1.0

import "../components"
import "../"
import "."

Item {
  id: root

  property int projectModelType: ProjectsModel.EmptyProjectsModel
  property string activeProjectId: ""
  property string searchText: ""
  property int spacing: 0

  signal openProjectRequested( string projectFilePath )
  signal showLocalChangesRequested( string projectId )
  signal activeProjectDeleted()

  onSearchTextChanged: {
    if ( projectModelType !== ProjectsModel.LocalProjectsModel ) {
      controllerModel.listProjects( root.searchText )
    }
    else viewModel.searchExpression = root.searchText
  }

  function refreshProjectList() {
    controllerModel.listProjects( searchText )
  }

  ListView {
    id: listview

    Component.onCompleted: {
      // set proper footer (add project / fetch more)
      if ( root.projectModelType === ProjectsModel.LocalProjectsModel )
        listview.footer = addProjectButtonComponent
      else
        listview.footer = loadingSpinnerComponent
    }

    onAtYEndChanged: {
      if ( atYEnd ) { // user reached end of the list
        if ( controllerModel.hasMoreProjects && !controllerModel.isLoading ) {
          controllerModel.fetchAnotherPage( viewModel.searchExpression )
        }
      }
    }

    anchors.fill: parent
    clip: true
    spacing: root.spacing

    maximumFlickVelocity: __androidUtils.isAndroid ? InputStyle.scrollVelocityAndroid : maximumFlickVelocity

    // Proxy model with source projects model
    model: ProjectsProxyModel {
      id: viewModel

      projectSourceModel: ProjectsModel {
        id: controllerModel

        merginApi: __merginApi
        localProjectsManager: __localProjectsManager
        syncManager: __syncManager
        modelType: root.projectModelType
      }
    }

    // Project delegate
    delegate: MMProjectItem {
      id: projectDelegate

      width: ListView.view.width
      height: InputStyle.projectItemHeight

      projectDisplayName: root.projectModelType === ProjectsModel.CreatedProjectsModel ? model.ProjectName : model.ProjectFullName
      projectId: model.ProjectId
      projectDescription: model.ProjectDescription
      projectStatus: model.ProjectStatus ? model.ProjectStatus : ProjectStatus.NoVersion
      projectIsValid: model.ProjectIsValid
      projectIsPending: model.ProjectSyncPending ? model.ProjectSyncPending : false
      projectSyncProgress: model.ProjectSyncProgress ? model.ProjectSyncProgress : -1
      projectIsLocal: model.ProjectIsLocal
      projectIsMergin: model.ProjectIsMergin
      projectRemoteError: model.ProjectRemoteError ? model.ProjectRemoteError : ""

      highlight: model.ProjectId === root.activeProjectId

      onOpenRequested: {
        if ( model.ProjectIsLocal )
          root.openProjectRequested( model.ProjectFilePath )
        else if ( !model.ProjectIsLocal && model.ProjectIsMergin && !model.ProjectSyncPending) {
          downloadProjectDialog.relatedProjectId = model.ProjectId
          downloadProjectDialog.open()
        }
      }
      onSyncRequested: controllerModel.syncProject( projectId )
      onMigrateRequested: controllerModel.migrateProject( projectId )
      onRemoveRequested: {
        removeDialog.relatedProjectId = projectId
        removeDialog.open()
      }
      onStopSyncRequested: controllerModel.stopProjectSync( projectId )
      onShowChangesRequested: root.showLocalChangesRequested( projectId )
    }
  }

  Component {
    id: loadingSpinnerComponent

    LoadingSpinner {
      x: parent.width / 2 - width / 2
      running: controllerModel.isLoading
    }
  }

  Component {
    id: addProjectButtonComponent

    MMButton {
        width: parent.width - 2 * 20 * __dp
        // anchors.horizontalCenter: parent.horizontalCenter
        // anchors.bottom: parent.bottom
        // anchors.bottomMargin: 20 * __dp

        visible: listview.count > 0
        text: qsTr("Create project")

        onClicked: stackView.push(projectWizardComp)
      }
  }

  Item {
    id: noLocalProjectsMessageContainer

    visible: listview.count === 0 && // this check is getting longer and longer, would be good to replace with states
             projectModelType === ProjectsModel.LocalProjectsModel &&
             root.searchText === "" &&
             !controllerModel.isLoading

    anchors.fill: parent

    ColumnLayout {
      id: colayout

      anchors.fill: parent
      spacing: 0

      RichTextBlock {
        id: noLocalProjectsText

        Layout.fillHeight: true
        Layout.fillWidth: true

        text: "<style>a:link { color: " + InputStyle.fontColor + "; }</style>" +
              qsTr( "No downloaded projects found.%1Learn %2how to create projects%3 and %4download them%3 onto your device." )
        .arg("<br/>")
        .arg("<a href='"+ __inputHelp.howToCreateNewProjectLink +"'>")
        .arg("</a>")
        .arg("<a href='"+ __inputHelp.howToDownloadProjectLink +"'>")

        onLinkActivated: function( link ) {
          Qt.openUrlExternally(link)
        }
      }


      RichTextBlock {
        id: createProjectText

        Layout.fillHeight: true
        Layout.fillWidth: true

        text: qsTr( "You can also create new project by clicking button below." )
      }


      MMButton {
        id: createdProjectsWhenNone
        Layout.fillWidth: true
        // Layout.preferredHeight: InputStyle.rowHeight
        text: qsTr("Create project")

        onClicked: stackView.push(projectWizardComp)
      }
    }
  }

  Label {
    id: noMerginProjectsTexts

    anchors.fill: parent
    horizontalAlignment: Qt.AlignHCenter
    verticalAlignment: Qt.AlignVCenter
    visible: reloadList.visible || !controllerModel.isLoading && ( projectModelType !== ProjectsModel.LocalProjectsModel && listview.count === 0 )
    text: reloadList.visible ? qsTr("Unable to get the list of projects.") : qsTr("No projects found!")
    color: InputStyle.fontColor
    font.pixelSize: InputStyle.fontPixelSizeNormal
    font.bold: true
  }

  Item {
    id: reloadList

    width: parent.width
    height: InputStyle.rowHeightHeader
    visible: false
    y: root.height/3 * 2

    Connections {
      target: __merginApi

      function onListProjectsFailed() {
        reloadList.visible = root.projectModelType !== ProjectsModel.LocalProjectsModel // show reload list to all models except local
      }

      function onListProjectsFinished( merginProjects, projectCount, page, requestId ) {
        if ( projectCount > -1 )
          reloadList.visible = false
      }
    }

    Button {
      id: reloadBtn
      width: reloadList.width - 2* InputStyle.panelMargin
      height: reloadList.height
      text: qsTr("Retry")
      font.pixelSize: InputStyle.fontPixelSizeNormal
      anchors.horizontalCenter: parent.horizontalCenter
      onClicked: {
        // filters suppose to not change
        controllerModel.listProjects( root.searchText )
      }
      background: Rectangle {
        color: InputStyle.highlightColor
        radius: InputStyle.cornerRadius
      }

      contentItem: Text {
        text: reloadBtn.text
        font: reloadBtn.font
        color: InputStyle.clrPanelMain
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
      }
    }
  }

  MessageDialog {
    id: removeDialog

    property string relatedProjectId

    title: qsTr( "Remove project" )
    text: qsTr( "Any unsynchronized changes will be lost." )
    buttons: MessageDialog.Ok | MessageDialog.Cancel

    onButtonClicked: function(clickedButton) {
      if (clickedButton === MessageDialog.Ok) {
        if (relatedProjectId === "") {
          close()
          return
        }

        if ( root.activeProjectId === relatedProjectId )
          root.activeProjectDeleted()

        __inputUtils.log(
              "Delete project",
              "Project " + __localProjectsManager.projectName( relatedProjectId ) + " deleted by " +
              ( __merginApi.userAuth ? __merginApi.userAuth.username : "unknown" ) + " (" + __localProjectsManager.projectChanges( relatedProjectId ) + ")" )

        controllerModel.removeLocalProject( relatedProjectId )
      }

      removeDialog.relatedProjectId = ""
      close()
    }
  }

  MessageDialog {
    id: downloadProjectDialog

    property string relatedProjectId

    title: qsTr( "Download project" )
    text: qsTr( "Would you like to download the project\n %1 ?" ).arg( relatedProjectId )
    buttons: MessageDialog.Yes | MessageDialog.No

    onButtonClicked: function( clickedButton ) {
      if (clickedButton === MessageDialog.Yes) {
        controllerModel.syncProject( relatedProjectId )
      }

      downloadProjectDialog.close()
    }
  }
}
