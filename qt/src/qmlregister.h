#ifndef QMLREGISTER_H
#define QMLREGISTER_H

#include <QObject>
#include "filemanager.h"
#include "tabsmodel.h"

class QMLRegister : public QObject
{
        Q_OBJECT

    public:
        explicit QMLRegister(QObject *parent = nullptr);
        static FileManager* fileManager;
        static TabsModel* tabsModel;
        static void registerToQML();

    signals:

    public slots:
};

#endif // QMLREGISTER_H

