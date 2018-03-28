#include "webpage.h"
#include <QString>
#include <QVariantMap>
#include <QSharedPointer>
#include <QJsonObject>
#include <QQmlEngine>

Webpage::Webpage(QObject *parent) : QObject(parent)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
}

Webpage::Webpage(QString url)
{
    _url = url;
    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
}

Webpage::Webpage(QString url, QString title, QString html)
{
    _url = url;
    _title = title;
    _html = html;
    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
}

QString Webpage::title() const { return _title; }
QString Webpage::url() const { return _url; }
QString Webpage::storeFile() const { return _storeFile; }
QString Webpage::html() const { return _html; }

void Webpage::setTitle(QString x) { _title = x; }
void Webpage::setUrl(QString x) { _url = x; }
void Webpage::setStoreFile(QString x) { _storeFile = x; }
void Webpage::setHtml(QString x) { _html = x; }


QVariantMap Webpage::toQVariantMap()
{
    QVariantMap map;
    map.insert("title", title());
    map.insert("url", url());
    return map;
}

Webpage_ Webpage::fromQVariantMap(QVariantMap& map)
{
    Webpage_ webpage = Webpage::create(map["url"].value<QString>());
    webpage->setTitle(map["title"].value<QString>());
    return webpage;
}

QJsonObject Webpage::toQJsonObject()
{
    QJsonObject map;
    map.insert("title", title());
    map.insert("url", url());
    return map;
}

Webpage_ Webpage::fromQJsonObject(QJsonObject& map)
{
    Webpage_ webpage = QSharedPointer<Webpage>::create();
    webpage->setTitle(map["title"].toString());
    webpage->setUrl(map["url"].toString());
    return webpage;
}

Webpage_ Webpage::create(const QString& url)
{
    Webpage_ webpage = QSharedPointer<Webpage>::create(url);
    return webpage;
}
