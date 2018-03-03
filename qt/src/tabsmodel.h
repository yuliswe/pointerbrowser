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

    public slots:
        void insertTab(int i, QUrl url, QString title, QString html);
        void removeTab(int idx);

    private:
        QList<Webpage*> _tabs;
};

#endif // TABSMODEL_H
