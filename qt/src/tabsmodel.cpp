#include "tabsmodel.h"
#include <QUrl>
#include <QObject>

TabsModel::TabsModel(QObject *parent) : QObject(parent)
{

}

QVariantList TabsModel::tabs() const
{
    QVariantList ls;
    for (Webpage* tab : _tabs) {
        QVariant v;
        v.setValue(tab);
        ls << v;
    }
    return ls;
}

void TabsModel::insertTab(int i, QUrl url, QString title, QString html)
{
    Webpage* page = new Webpage(url, title, html);
    _tabs.insert(i, page);
    emit tabsChanged();
}

void TabsModel::removeTab(int idx)
{
    Webpage* p = _tabs.at(idx);
    _tabs.removeAt(idx);
    delete p;
    emit tabsChanged();
}
