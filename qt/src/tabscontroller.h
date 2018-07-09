#ifndef TABSCONTROLLER_H
#define TABSCONTROLLER_H

#include <QObject>
#include <QList>
#include "tabsmodel.h"
#include <QPair>
#include <QSharedPointer>
#include "webpage.h"
#include "macros.h"

class TabsController : public QObject
{
    Q_OBJECT

    enum TabState {
        Empty, Open, Preview
    };

    PROP_R_D(QSharedPointer<TabsModel>, open_tabs, QSharedPointer<TabsModel>::create())
    PROP_R_D(QSharedPointer<TabsModel>, preview_tabs, QSharedPointer<TabsModel>::create())
    PROP_RWN(int, current_index)
    PROP_RWN(Webpage*, current_webpage)
    PROP_RWN(TabState, current_state)

public:
    TabsController();

signals:

public slots:
    void newTab(TabState, const QString& url, bool switchToView, bool usePrevious = true);
    void viewTab(TabState, int i);
    void closeTab(TabState, int i);
    void closeTab(TabState, const QString& url);
    void reset();
};

#endif // TABSCONTROLLER_H
