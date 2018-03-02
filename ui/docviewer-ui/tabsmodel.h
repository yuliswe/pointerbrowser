#ifndef TABSMODEL_H
#define TABSMODEL_H

#include <QObject>

class TabsModel : public QObject
{
        Q_OBJECT
    public:
        explicit TabsModel(QObject *parent = nullptr);

    signals:

    public slots:
};

#endif // TABSMODEL_H