#include <QString>
#include <QObject>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QUrl>
#include <QDebug>
#include "qmlregister.h"
#include "tabsmodel.h"

TabsModel::TabsModel(QObject *parent) : QObject(parent)
{

}

QVariantList TabsModel::tabs() const
{
    QVariantList ls;
    for (Webpage_ tab : _tabs) {
        QVariant v;
        v.setValue(tab.data());
        ls << v;
    }
    return ls;
}

void TabsModel::insertTab(int i, QString url, QString title, QString html)
{
    Webpage_ page = QSharedPointer<Webpage>::create(url, title, html);
    _tabs.insert(i, page);
    emit tabsChanged();
    emit tabInserted(i, page.data());
}

int TabsModel::appendTab(QString url, QString title, QString html)
{
    Webpage_ page = QSharedPointer<Webpage>::create(url, title, html);
    _tabs.append(page);
    emit tabsChanged();
    int idx = _tabs.length() - 1;
    emit tabInserted(idx, page.data());
    return idx;
}

void TabsModel::removeTab(int idx)
{
    Webpage_ page = _tabs.at(idx);
    _tabs.removeAt(idx);
    emit tabsChanged();
    emit tabRemoved(idx, page.data());
    page.clear();
}

int TabsModel::findTab(QString url) {
    int i = 0;
    for (Webpage_ tab : _tabs) {
        if (tab->url() == url) {
            return i;
        }
        i++;
    }
    return -1;
}

void TabsModel::saveTabs(void) {
    QJsonArray tabs;
    for (Webpage_ tab : _tabs) {
        tabs << tab->toQJsonObject();
    }
    QJsonDocument doc(tabs);
    QMLRegister::fileManager->saveFile("openTabs.json", doc.toJson());
}

void TabsModel::loadTabs(void) {
    QByteArray contents = QMLRegister::fileManager->readFileB("openTabs.json");
    QJsonDocument doc = QJsonDocument::fromJson(contents);
    QJsonArray jarr = doc.array();
    qDebug() << jarr;
    _tabs.clear();
    int idx = 0;
    qDebug() << "loadTabs: " << endl;
    for (QJsonValue jval : jarr) {
        QJsonObject jobj = jval.toObject();
        Webpage_ page_ = Webpage::fromQJsonObject(jobj);
        qDebug() << "tab "
                 << page_->title()
                 << " "
                 << page_->url() << endl;
        Webpage* page = page_.data();
        _tabs << Webpage::fromQJsonObject(jobj);
        emit tabInserted(idx, page);
        idx++;
    }
    emit tabsChanged();
}

void TabsModel::syncTabs(QVariantList tabs) {
    _tabs.clear();
    int idx = 0;
    for (QVariant tab : tabs) {
        Webpage* page = tab.value<Webpage*>();
        _tabs << QSharedPointer<Webpage>(page);
        emit tabInserted(idx, page);
        idx++;
    }
    emit tabsChanged();
}
