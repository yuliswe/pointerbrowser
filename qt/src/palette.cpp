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
        qDebug() << "Palette::setup" << error.errorString();
    }
    _json = doc.object();
    qDebug() << "Palette::setup" << _json;

    QStringList keys = _json.keys();
    for (QString k: keys) {
        QJsonArray colors = _json[k].toArray();
        if (colors.size() < 4) {
            _normal[k] = _selected[k] = _hovered[k] = _disabled[k] = colors[0];
        } else {
            _normal[k] = colors[0];
            _selected[k] = colors[1];
            _hovered[k] = colors[2];
            _disabled[k] = colors[3];
        }
        qDebug() << "Palette::setup" << _normal[k];
    }

    emit paletteChanged();
}

ColorMap Palette::normal() const { return _normal; }
ColorMap Palette::selected() const { return _selected; }
ColorMap Palette::hovered() const { return _hovered; }
ColorMap Palette::disabled() const { return _disabled; }
QJsonObject Palette::json() const { return _json; }

