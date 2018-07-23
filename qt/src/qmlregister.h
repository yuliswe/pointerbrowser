#ifndef QMLREGISTER_H
#define QMLREGISTER_H

#include <QObject>
#include "filemanager.h"
#include "tabsmodel.h"
#include "eventfilter.h"
#include "searchdb.h"
#include "palette.h"
#include "keymaps.h"
#include "browsercontroller.h"

#ifdef Q_OS_MACOS
#include "os-specific/mac/macwindow.h"
#endif

class QMLRegister : public QObject
{
    Q_OBJECT

public:
    explicit QMLRegister(QObject *parent = nullptr);
    static FileManager* fileManager;
    static SettingsModel* settingsModel;
    static KeyMaps* keyMaps;
    static TabsModel* tabsModel;
    static TabsModel* previewTabsModel;
    static EventFilter* eventFilter;
    static SearchDB* searchDB;
    static Palette* palette;
    static BrowserController* browserController;

#ifdef Q_OS_MACOS
    static MacWindow* macWindow;
#endif

    static void registerToQML();

signals:

public slots:
};

#endif // QMLREGISTER_H

