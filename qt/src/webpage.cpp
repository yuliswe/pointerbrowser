#include "webpage.h"
#include <QString>
#include <QVariantMap>
#include <QSharedPointer>
#include <QJsonObject>
#include <QQmlEngine>

#define WP_PROP_1 (QString, title)

Webpage::Webpage(const QString& uri)
{
    set_uri(uri);
    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
}

Webpage::Webpage(const QVariantMap& map)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
#define MAP_K(T, PROP) set_##PROP(map[#PROP].value<T>());
    MAP_K(QString, uri);
//    MAP_K(QString, title);
}

Webpage::~Webpage() {}

QVariantMap Webpage::toQVariantMap()
{
    QVariantMap map;
#define MAP_INSERT(NAME) map.insert(#NAME, NAME())
    MAP_INSERT(title);
    MAP_INSERT(uri);
    return map;
}

Webpage_ Webpage::fromQVariantMap(const QVariantMap& map)
{
    return Webpage_::create(map); // use constructor
}

//QJsonObject Webpage::toQJsonObject()
//{
//    return QJsonObject::fromVariantMap(toQVariantMap());
//}

//Webpage_ Webpage::fromQJsonObject(const QJsonObject& map)
//{
//    return Webpage::fromQVariantMap(map.toVariantMap());
//}

void Webpage::set_url(const QString& url)
{
    qDebug() << "set_url" << url;
    _url = url;
    emit url_changed(_url);
    if (_hash.length() > 0) {
        _uri = _url + "#" + _hash;
    } else {
        _uri = _url;
    }
    emit uri_changed(_uri);
}

void Webpage::set_hash(const QString& val)
{
    qDebug() << "set_hash" << val;
    _hash = val;
    while (_hash.length() > 0 && _hash[0] == "#") {
        _hash.remove(0,1);
    }
    emit hash_changed(_hash);
    if (_hash.length() > 0) {
        _uri = _url + "#" + _hash;
    } else {
        _uri = _url;
    }
    emit uri_changed(_uri);
}

void Webpage::set_uri(const QString& uri)
{
    qDebug() << "set_uri" << uri;
    _uri = uri;
    emit uri_changed(_uri);
    QStringList ls = uri.split("#", QString::SkipEmptyParts);
    if (ls.length() > 0) {
        _url = ls[0];
        ls.removeFirst();
    }
    if (ls.length() > 0) {
        _hash = ls.join("#");
    }
    emit url_changed(_url);
    emit hash_changed(_hash);
}
