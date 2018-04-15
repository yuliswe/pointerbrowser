#ifndef TABSMODEL_H
#define TABSMODEL_H

#include <QAbstractListModel>
#include <QVariantList>
#include "webpage.h"

class TabsModel : public QAbstractListModel
{
        Q_OBJECT
//        Q_PROPERTY(QVariantList tabs READ tabs NOTIFY tabsChanged)
        Q_PROPERTY(int count READ count NOTIFY countChanged)

    public:
        explicit TabsModel(QObject *parent = nullptr);
        QVariant data(const QModelIndex& idx, int role = Qt::DisplayRole) const;
        int rowCount(const QModelIndex &parent) const;
        void insertWebpage(int idx, Webpage_ wp);
        QHash<int, QByteArray> roleNames() const;

    signals:
        void countChanged();

    public slots:
        void insertTab(int i, QString url);
        void updateTab(int i, QString property, QVariant value);
        bool removeTab(int idx);
        int findTab(QString url);
        int count();
        void saveTabs();
        void loadTabs();
        void clear();
        QVariant at(int index);

    private:
        WebpageList _tabs;
};

#endif // TABSMODEL_H
