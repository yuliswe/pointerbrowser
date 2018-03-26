#ifndef TABSMODEL_H
#define TABSMODEL_H

#include <QAbstractListModel>
#include <QVariantList>
#include "webpage.h"

class TabsModel : public QAbstractListModel
{
        Q_OBJECT
        Q_PROPERTY(QVariantList tabs READ tabs NOTIFY tabsChanged)

    public:
        explicit TabsModel(QObject *parent = nullptr);
        QVariantList tabs() const;
        QVariant data(const QModelIndex& idx, int role = Qt::DisplayRole) const;
        int rowCount(const QModelIndex &parent) const;
        bool setData(const QModelIndex &index, const QVariant &value, int role);
        Qt::ItemFlags flags(const QModelIndex &index) const;
        bool insertRows(int row, int count, const QModelIndex &parent = QModelIndex());
        bool removeRows(int row, int count, const QModelIndex &parent = QModelIndex());

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
