#ifndef TABSMODEL_H
#define TABSMODEL_H

#include <QObject>
#include <QVariantList>
#include "webpage.h"

class TabsModel : public QObject
{
        Q_OBJECT
        Q_PROPERTY(QVariantList tabs READ tabs NOTIFY tabsChanged)

    public:
        explicit TabsModel(QObject *parent = nullptr);
        QVariantList tabs() const;

    signals:
        void tabsChanged();
        void tabInserted(int index, Webpage* webpage);
        void tabRemoved(int index, Webpage* webpage);

    public slots:
        void insertTab(int i, QString url, QString title, QString html);
        int appendTab(QString url, QString title, QString html);
        void removeTab(int idx);
        int findTab(QString url);
        void saveTabs();
        void loadTabs();
        void syncTabs(QVariantList);

    private:
        WebpageList _tabs;
};

#endif // TABSMODEL_H
