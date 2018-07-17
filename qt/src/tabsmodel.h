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
        QVariant virtual data(const QModelIndex& idx, int role = Qt::DisplayRole) const override;
        int virtual rowCount(const QModelIndex &parent) const override;
        QHash<int, QByteArray> virtual roleNames() const override;
        bool moveRows(const QModelIndex &sourceParent, int sourceRow, int count, const QModelIndex &destinationParent, int destinationChild) override;
//        Qt::ItemFlags virtual flags(const QModelIndex &index) const override;

    signals:
        void countChanged();

    public slots:
        void insertWebpage(int idx, const Webpage_ wp);
        void insertTab(int i, const QString& uri);
        void insertTab(int i, const QVariantMap&);
        void updateTab(int i, QString property, QVariant value);
        bool removeTab(int idx);
        bool removeTab(const QString& uri);
        void moveTab(int from, int to);
        int findTab(const QString& uri);
        int count() const;
//        void saveTabs();
//        void loadTabs();
        void clear();
        QVariant at(int index) const;
        Webpage_ webpage_(int index) const;
        void replaceModel(const Webpage_List& wp);

    private:
        Webpage_List _tabs;
};

Q_DECLARE_METATYPE(Webpage_List);

#endif // TABSMODEL_H
