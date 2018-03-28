#ifndef QMLREGISTER_H
#define QMLREGISTER_H

#include <QObject>
#include "filemanager.h"
#include "tabsmodel.h"
#include "eventfilter.h"
#include "searchdb.h"

class QMLRegister : public QObject
{
        Q_OBJECT

    public:
        explicit QMLRegister(QObject *parent = nullptr);
        static FileManager* fileManager;
        static TabsModel* tabsModel;
        static EventFilter* eventFilter;
        static SearchDB* searchDB;
        static void registerToQML();

    signals:

    public slots:
};

#endif // QMLREGISTER_H

