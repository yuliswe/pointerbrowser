#include "webpage.h"
#include <QString>
#include <QUrl>

Webpage::Webpage(QObject *parent) : QObject(parent)
{

}

Webpage::Webpage(QUrl url, QString title, QString html)
{
    _url = url;
    _title = title;
    _html = html;
}

QString Webpage::title() const { return _title; }
QUrl Webpage::url() const { return _url; }
QUrl Webpage::storeFile() const { return _storeFile; }
QString Webpage::html() const { return _html; }

void Webpage::setTitle(QString x) { _title = x; }
void Webpage::setUrl(QUrl x) { _url = x; }
void Webpage::setStoreFile(QUrl x) { _storeFile = x; }
void Webpage::setHtml(QString x) { _html = x; }

