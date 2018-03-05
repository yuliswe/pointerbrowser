#include "webpage.h"
#include <QString>

Webpage::Webpage(QObject *parent) : QObject(parent)
{

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

