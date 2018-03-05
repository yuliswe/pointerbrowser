#include "tabsmodel.h"
#include <QString>
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

void TabsModel::insertTab(int i, QString url, QString title, QString html)
{
    Webpage* page = new Webpage(url, title, html);
    _tabs.insert(i, page);
    emit tabsChanged();
    emit tabInserted(i, page);
}

int TabsModel::appendTab(QString url, QString title, QString html)
{
    Webpage* page = new Webpage(url, title, html);
    _tabs.append(page);
    emit tabsChanged();
    int idx = _tabs.length() - 1;
    emit tabInserted(idx, page);
    return idx;
}

void TabsModel::removeTab(int idx)
{
    Webpage* page = _tabs.at(idx);
    _tabs.removeAt(idx);
    emit tabsChanged();
    emit tabRemoved(page);
    delete page;
}

int TabsModel::findTab(QString url) {
    int i = 0;
    for (Webpage* tab : _tabs) {
        if (tab->url() == url) {
            return i;
        }
        i++;
    }
    return -1;
}
