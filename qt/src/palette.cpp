#include "palette.h"
#include "filemanager.h"
#include <QPalette>
#include <QVariantMap>
#include <QJsonObject>
#include <QJsonArray>
#include <QDebug>
#include <QMap>

Palette::Palette() {}

void Palette::setup() {

#ifdef Q_OS_IOS
    QByteArray bs = FileManager::readQrcFileB("theme/ios.json");
#endif
#ifdef Q_OS_OSX
    QByteArray bs = FileManager::readQrcFileB("theme/macos.json");
#endif
#ifdef Q_OS_WIN
    QByteArray bs = FileManager::readQrcFileB("theme/windows.json");
#endif
    QJsonParseError error;
    QJsonDocument doc = QJsonDocument::fromJson(bs, &error);
    if (doc.isNull()) {
        qCritical() << error.errorString();
        qFatal("Palette::setup failed");
    }
    _json = doc.object();
    qInfo() << "Palette::setup" << _json;

    QStringList keys = _json.keys();
    for (QString k: keys) {
        QString normal;
        QString selected;
        QString hovered;
        QString pressed;
        QString disabled;
        if (_json[k].isObject()) {
            QJsonObject colors = _json[k].toObject();
            normal = colors["normal"].toString();
            selected = colors["selected"].toString();
            hovered = colors["hovered"].toString();
            disabled = colors["disabled"].toString();
            pressed = colors["pressed"].toString();
        } else if (_json[k].isString()) {
            normal = selected
                         = hovered
                           = disabled
                             = pressed
                               = _json[k].toString();
        }
        Q_ASSERT(normal.length());
        Q_ASSERT(selected.length());
        Q_ASSERT(hovered.length());
        Q_ASSERT(disabled.length());
        Q_ASSERT(pressed.length());
        qInfo() << "Palette::setup" << k << "normal" << normal;
        _normal[k] = normal;
        qInfo() << "Palette::setup" << k << "selected" << selected;
        _selected[k] = selected;
        qInfo() << "Palette::setup" << k << "hovered" << hovered;
        _hovered[k] = hovered;
        qInfo() << "Palette::setup" << k << "disabled" << disabled;
        _disabled[k] = disabled;
        qInfo() << "Palette::setup" << k << "pressed" << pressed;
        _pressed[k] = pressed;
    }

    emit paletteChanged();
}

ColorMap Palette::normal() const { return _normal; }
ColorMap Palette::selected() const { return _selected; }
ColorMap Palette::hovered() const { return _hovered; }
ColorMap Palette::disabled() const { return _disabled; }
ColorMap Palette::pressed() const { return _pressed; }
QJsonObject Palette::json() const { return _json; }

