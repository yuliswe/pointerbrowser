#include "webpage.h"
#include <QString>
#include <QVariantMap>
#include <QSharedPointer>
#include <QJsonObject>
#include <QQmlEngine>

#define WP_PROP_1 (QString, title)

Webpage::Webpage(const QString& url)
{
    set_url(url);
    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
}

Webpage::Webpage(const QVariantMap& map)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
#define MAP_K(T, PROP) _##PROP = map[#PROP].value<T>();
    MAP_K(QString, url);
}

Webpage::~Webpage() {}

QVariantMap Webpage::toQVariantMap()
{
    QVariantMap map;
#define MAP_INSERT(NAME) map.insert(#NAME, NAME())
    MAP_INSERT(title);
    MAP_INSERT(url);
    return map;
}

Webpage_ Webpage::fromQVariantMap(const QVariantMap& map)
{
    return Webpage_::create(map);
}

QJsonObject Webpage::toQJsonObject()
{
    return QJsonObject::fromVariantMap(toQVariantMap());
}

Webpage_ Webpage::fromQJsonObject(const QJsonObject& map)
{
    return Webpage::fromQVariantMap(map.toVariantMap());
}

void Webpage::set_url(const QString& url)
{
    _url = url;
    emit url_changed(_url);
    if (_hash.length() > 0) {
        set_uri(_url + "#" + _hash);
    } else {
        set_uri(_url);
    }
}

void Webpage::set_hash(const QString& val)
{
    _hash = val;
    emit hash_changed(_hash);
    if (_hash.length() > 0) {
        set_uri(_url + "#" + _hash);
    } else {
        set_uri(_url);
    }
}
