#ifndef TABSMODEL_H
#define TABSMODEL_H

#include <QtCore/QtCore>
#include "webpage.hpp"

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
    SIG_TF_2(tab_moved, int, int)

    public slots:
        void insertWebpage_(int idx, const Webpage_ wp);
        void insertTab(int i, Url const& uri);
//        void insertTab(int i, const QVariantMap&);
//        void updateTab(int i, QString property, QVariant value);
        bool removeTab(int idx);
        bool removeTab(Url const& uri);
        void moveTab(int from, int to);
        int findTab(Url const& uri);
        int findTab(Webpage*);
        int count() const;
//        void saveTabs();
//        void loadTabs();
        void clear();
        QVariant at(int index) const;
        Webpage_ webpage_(int index) const;
        Webpage* webpage(int index) const;
        void replaceModel(const Webpage_List& wp);

    private:
        Webpage_List _tabs;
};

Q_DECLARE_METATYPE(Webpage_List);
typedef std::shared_ptr<TabsModel> TabsModel_;

#endif // TABSMODEL_H
