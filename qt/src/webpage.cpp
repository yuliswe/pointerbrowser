#include "webpage.h"
#include <QString>
#include <QVariantMap>
#include <QSharedPointer>
#include <QJsonObject>

Webpage::Webpage(QObject *parent) : QObject(parent)
{

}

Webpage::Webpage(QString url)
{
    _url = url;
}

Webpage::Webpage(QString url, QString title, QString html)
{
    _url = url;
    _title = title;
    _html = html;
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
    QSharedPointer<Webpage> webpage(new Webpage());
    webpage->setTitle(map["title"].value<QString>());
    webpage->setUrl(map["url"].value<QString>());
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
