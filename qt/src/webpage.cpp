#include "webpage.h"
#include <QString>
#include <QVariantMap>
#include <QSharedPointer>
#include <QJsonObject>
#include <QQmlEngine>

#define WP_PROP_1 (QString, title)

#define QPROP_FUNC(TYPE, PROP) \
    TYPE Webpage::PROP() const { return _##PROP; } \
    void Webpage::set_##PROP(TYPE x) { _##PROP = x; emit PROP##_changed(x); }

QPROP_FUNC(QString, title)
QPROP_FUNC(QString, html)
QPROP_FUNC(QString, url)
QPROP_FUNC(QString, hash)
QPROP_FUNC(QString, symbol)
QPROP_FUNC(QString, display)
QPROP_FUNC(QString, expanded_display)
QPROP_FUNC(quint64, visited)
QPROP_FUNC(bool, open)
QPROP_FUNC(bool, preview_mode)
QPROP_FUNC(bool, url_matched)
QPROP_FUNC(bool, title_matched)
QPROP_FUNC(bool, hash_matched)
QPROP_FUNC(bool, symbol_matched)

Webpage::Webpage(const QString& url)
{
    _url = url;
    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
}

Webpage::Webpage(const QVariantMap& map)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
#define MAP_K(T, PROP) _##PROP = map[#PROP].value<T>();
    MAP_K(QString, url);
    MAP_K(bool, open);
    MAP_K(bool, preview_mode);
}

Webpage::~Webpage() {}

QVariantMap Webpage::toQVariantMap()
{
    QVariantMap map;
#define MAP_INSERT(NAME) map.insert(#NAME, NAME())
    MAP_INSERT(title);
    MAP_INSERT(url);
//    MAP_INSERT(open);
//    MAP_INSERT(html);
//    MAP_INSERT(visited);
//    MAP_INSERT(hash);
//    MAP_INSERT(symbol);
//    MAP_INSERT(display);
//    MAP_INSERT(expanded_display);
//    MAP_INSERT(url_matched);
//    MAP_INSERT(title_matched);
//    MAP_INSERT(hash_matched);
//    MAP_INSERT(symbol_matched);
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

//Webpage_ Webpage::create(const QString& url)
//{
//    Webpage_ webpage = QSharedPointer<Webpage>::create(url);
//    return webpage;
//}
