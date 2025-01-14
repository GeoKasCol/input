/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

#ifndef HELPER_H
#define HELPER_H

#include <QObject>

class Helper : public QObject
{
    Q_OBJECT
  public:
    explicit Helper( QObject *parent = nullptr );

    // Install custom fonts
    static QString installFonts();

    // Calculates real screen DPR based on DPI
    static qreal calculateScreenDpr();

    // Calculates ratio between real DPR calculated by us with DPR calculated by QT that is later used in qml sizing
    static qreal calculateDpRatio();

    // flag, if app is running on mobile device
    static bool isMobile();
};

#endif // HELPER_H
