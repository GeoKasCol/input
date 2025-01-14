/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#ifdef DESKTOP_OS
#include "hotreload.h"
#endif
#include "mmstyle.h"
#include "helper.h"
#include <QFont>
#include <QFontDatabase>
#include "notificationmodel.h"
#include "merginerrortypes.h"
#include "qrcodedecoder.h"
#include "inpututils.h"
#include "scalebarkit.h"
#include "positionkit.h"
#include "relationfeaturesmodel.h"

int main( int argc, char *argv[] )
{
  QGuiApplication app( argc, argv );

  // These must be set so that QSettings work properly
  QCoreApplication::setOrganizationName( "Lutra Consulting" );
  QCoreApplication::setOrganizationDomain( "lutraconsulting.co.uk" );
  QCoreApplication::setApplicationName( "Mobile gallery" ); // used by QSettings
  QCoreApplication::setApplicationVersion( "0.1" );

  app.setFont( QFont( Helper::installFonts() ) );

  InputUtils iu;

  QQmlApplicationEngine engine;

  // Register C++ enums
  qmlRegisterUncreatableType<RegistrationError>( "lc", 1, 0, "RegistrationError", "RegistrationError Enum" );
  qmlRegisterType<QrCodeDecoder>( "lc", 1, 0, "QrCodeDecoder" );
  qmlRegisterType<ScaleBarKit>( "lc", 1, 0, "ScaleBarKit" );
  qmlRegisterType<RelationFeaturesModel>( "lc", 1, 0, "RelationFeaturesModel" );

#ifdef DESKTOP_OS
  HotReload hotReload( engine );
  engine.rootContext()->setContextProperty( "_hotReload", &hotReload );
#endif

  engine.rootContext()->setContextProperty( "__inputUtils", &iu );
  engine.rootContext()->setContextProperty( "__androidUtils", &iu );
  engine.rootContext()->setContextProperty( "__iosUtils", &iu );

  qreal dp = Helper::calculateDpRatio();

  // MMStyle must be destructed after engine
  // see https://tobiasmarciszko.github.io/qml-binding-errors/
  MMStyle *style = new MMStyle( &engine, dp );

  NotificationModel notificationModel;

  PositionKit pk;
  engine.rootContext()->setContextProperty( "__positionKit", &pk );

  engine.rootContext()->setContextProperty( "__notificationModel", &notificationModel );
  // path to local wrapper pages
  engine.rootContext()->setContextProperty( "_qmlWrapperPath", QGuiApplication::applicationDirPath() + "/HotReload/qml/pages/" );
  engine.rootContext()->setContextProperty( "__dp", dp );
  engine.rootContext()->setContextProperty( "__style", style );
  engine.rootContext()->setContextProperty( "__isMobile", Helper::isMobile() );

  QObject::connect( &engine, &QQmlApplicationEngine::objectCreationFailed,
  &app, []() { QCoreApplication::exit( -1 ); }, Qt::QueuedConnection );
  engine.loadFromModule( "gallery", "Main" );

  return app.exec();
}
