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

import lc 1.0
import "./form" as Forms
import "."

Item {
  id: root

  /*
   * FormsStackManager component is responsible for viewing feature forms, both preview and fullscreen form
   * It contains a stackview where instances of FormWrapper are pushed. Latest form is not destroyed, but reused
   * for next feature to reduce a cost of initializing form and AttributeController each time user selects feature.
   */

  property var project
  property real previewHeight

  property int activeFormIndex: formsStack.depth - 1

  property real takenVerticalSpace: {
    // let's automatically find out how much vertical space is taken
    // by opened forms / previews
    if ( root.activeFormIndex < 0 || root.activeFormIndex >= formsStack.depth )
      return 0;

    let highestOpened = "none"

    for ( let i = 0; i <= root.activeFormIndex; i++ ) {
      let form = formsStack.get( i )
      if ( form ) {
        if ( form.panelState === "form" ) {
          return root.height
        }
        else if ( form.panelState === "preview" ) {
          highestOpened = "preview"
        }
      }
    }

    if ( highestOpened === "preview" ) {
      return root.previewHeight
    }

    return 0;
  }

  signal closed()
  signal editGeometryRequested( var pair )
  signal splitGeometryRequested( var pair )
  signal redrawGeometryRequested( var pair )
  signal createLinkedFeatureRequested( var targetLayer, var parentPair )
  signal stakeoutFeature( var feature );

  function openForm( pair, formState, panelState ) {
    if ( formsStack.depth === 0 )
    {
      let props = {
        featureLayerPair: pair,
        formState: formState,
        panelState: panelState
      }

      var latest = formsStack.push( formComponent, props )
    }
    else
    {
      latest = formsStack.get( 0 )
      latest.featureLayerPair = pair
      latest.formState = formState
      latest.panelState = panelState
    }
  }

  function _getActiveForm() {
    if (formsStack.depth === 0) {
      // no active form on empty form stack
      return null
    }

    if ( root.activeFormIndex >= 0 && root.activeFormIndex < formsStack.depth ) {
      return formsStack.get( activeFormIndex )
    }
    else console.error( "FormsStackManager: Opted for invalid form index" )
    return null
  }

  function closeDrawer() {
    let form = _getActiveForm()

    if ( form )
      form.closeDrawer()
  }

  function openDrawer() {
    let form = _getActiveForm()

    if ( form )
      form.openDrawer()
  }

  function hideAll() {
    // close form drawers so that user can see map
    applyOnForms( function ( form ) {
      if ( form && typeof form.closeDrawer === "function" ) {
        form.panelState = "hidden"
        form.closeDrawer()
      }
    })
  }

  function closeAll() {
    // close permanetly all drawers (not only hide)
    let form = formsStack.get( 0 )
    formsStack.pop( form )
  }

  function reopenAll() {
    // open form drawers back
    if ( root.activeFormIndex < 0 || root.activeFormIndex >= formsStack.depth ) {
      console.error( "FormsStackManager: Invalid active index" )
      return
    }

    for ( let i = 0; i <= root.activeFormIndex; i++ ) {
      let form = formsStack.get( i )

      if ( form && typeof form.openDrawer === "function" ) {
        form.openDrawer()
      }
    }
  }

  function reload() {
    // Even after formStack.clear() is called,
    // forms in the formStack will still
    // receive and evaluate some signals
    // and most importantly in some scenarios
    // featureLayerPair could contain already
    // dangling pointer to layer and crash the app
    // https://github.com/MerginMaps/mobile/issues/2879
    for ( let i = 0; i < formsStack.depth; i++ ) {
      let form = formsStack.get( i )
      form.featureLayerPair = __inputUtils.createFeatureLayerPair()
      form.relationToApply = null
      form.controllerToApply = null
      form.project = null
      form.linkedRelation = null
      form.parentController = null
    }

    // removes all objects thanks to Qt parent system
    formsStack.clear(StackView.Immediate)
  }

  function openLinkedFeature( linkedFeature ) {
    let props = {
      featureLayerPair: linkedFeature,
      formState: "readOnly",
      panelState: "form"
    }

    let latest = formsStack.push( formComponent, props )
  }

  function addLinkedFeature( newPair, parentController, relation ) {
    let props = {
      featureLayerPair: newPair,
      formState: "add",
      panelState: "form",
      parentController: parentController,
      linkedRelation: relation
    }

    let latest = formsStack.push( formComponent, props )
  }

  function applyOnForms( func ) {
    if ( root.activeFormIndex < 0 || root.activeFormIndex >= formsStack.depth ) {
      console.error( "FormsStackManager: Invalid active index" )
      return
    }

    for ( let i = 0; i <= root.activeFormIndex; i++ ) {
      let form = formsStack.get( i )
      func( form )
    }
  }

  function geometryEditingStarted() {
    // close form drawers so that user can see map
    applyOnForms( function ( form ) {
      if ( form && typeof form.closeDrawer === "function" ) {
        form.panelState = "hidden"
        form.closeDrawer()
      }
    })
  }

  function geometryEditingFinished( pair, success = true ) {
    // open form drawers back
    if ( root.activeFormIndex < 0 || root.activeFormIndex >= formsStack.depth ) {
      console.error( "FormsStackManager: Invalid active index" )
      return
    }

    for ( let i = 0; i <= root.activeFormIndex; i++ ) {
      let form = formsStack.get( i )

      if ( form && typeof form.openDrawer === "function" ) {
        if ( success && i === root.activeFormIndex ) {
          form.featureLayerPair = pair
        }
        form.openDrawer()
      }
    }
  }

  function recordInLayerStarted() {
    // close form drawers so that user can see map
    applyOnForms( function ( form ) {
      if ( form && typeof form.closeDrawer === "function" ) {
        form.panelState = "hidden"
        form.closeDrawer()
      }
    })
  }

  function recordInLayerFinished( pair, success = true ) {
    // open form drawers back and push new form in the end
    if ( root.activeFormIndex < 0 || root.activeFormIndex >= formsStack.depth ) {
      console.error( "FormsStackManager: Invalid active index" )
      return
    }

    for ( let i = 0; i <= root.activeFormIndex; i++ ) {
      var form = formsStack.get( i )

      if ( form && typeof form.openDrawer === "function" ) {
        form.openDrawer()
      }
    }

    // now add the new feature
    if ( success ) {
      addLinkedFeature( pair, form.controllerToApply, form.relationToApply )
    }

    // remove stored properties
    form.relationToApply = null
    form.controllerToApply = null
  }

  StackView {
    id: formsStack

    function popOneOrClose() {
      formsStack.pop()

      if ( formsStack.depth <= 1 )
      {
        root.closed() // this is the top most form, we want to keep it instantiated, just invisible
      }
    }

    focus: true

    anchors.fill: parent
  }

  Component {
    id: formComponent

    Forms.MMFormWrapper {
      id: wrapper

      project: root.project

      previewHeight: root.previewHeight

      onClosed: {
        if ( panelState !== "hidden" ) {
          formsStack.popOneOrClose()
        }
      }
      onEditGeometry: function( pair ) {
        root.editGeometryRequested( pair )
      }
      onSplitGeometry: function( pair ) {
        root.splitGeometryRequested( pair )
      }
      onRedrawGeometry: function( pair ) {
        root.redrawGeometryRequested( pair )
      }
      onOpenLinkedFeature: function( linkedFeature ) {
        root.openLinkedFeature( linkedFeature )
      }
      onCreateLinkedFeature: function( targetLayer, parentPair ) {
        root.createLinkedFeatureRequested( targetLayer, parentPair )
      }
      onStakeoutFeature: function( feature ) {
        root.stakeoutFeature( feature )
      }
    }
  }
}
