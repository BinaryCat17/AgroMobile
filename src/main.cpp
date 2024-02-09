// Copyright (C) 2021 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QScreen>
#include <QtQml>

#if QT_CONFIG(ssl)
#include <QtNetwork/QSslSocket>
#endif

#include "app_environment.h"
#include "import_qml_components_plugins.h"
#include "import_qml_plugins.h"

int main(int argc, char *argv[])
{
    set_qt_environment();

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
#if QT_CONFIG(ssl)
    engine.rootContext()->setContextProperty("supportsSsl", QSslSocket::supportsSsl());
#else
    engine.rootContext()->setContextProperty("supportsSsl", false);
#endif

    const QUrl url(u"qrc:/qt/qml/Main/main.qml"_qs);
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);

    engine.addImportPath(QCoreApplication::applicationDirPath() + "/qml");
    engine.addImportPath(":/");

    engine.rootContext()->setContextProperty("applicationDirPath",
                                             QGuiApplication::applicationDirPath());
    engine.rootContext()->setContextProperty("screenSize",
                                             QGuiApplication::primaryScreen()->physicalSize());

    //qreal refDpi = 120.;
    qreal refHeight = 1080.;
    qreal refWidth = 1920.;
    QRect rect = QGuiApplication::primaryScreen()->geometry();
    qreal height = rect.height();
    qreal width = rect.width();
    qreal m_ratio = qMax(height / refHeight, width / refWidth);
    qreal m_ratioFont = qMax(height / (refHeight), width / (refWidth));
    engine.rootContext()->setContextProperty("m_ratio", m_ratio);
    engine.rootContext()->setContextProperty("m_ratioFont", m_ratioFont);

    engine.load(url);

    return app.exec();
}
