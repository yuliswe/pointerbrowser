#ifndef WINDOW_H
#define WINDOW_H

#include <QQuickItem>
#include <QQuickWindow>
#include <QList>
#include <QSharedPointer>

class MacWindow : public QObject
{
    Q_OBJECT
    static QList<QQuickItem*> webUIs;
    static QList<QWindow*> windows;
    static QList<QSharedPointer<MacWindow>> instances;
public:
    MacWindow() = default;
    MacWindow(QWindow* target);
    static void initMacWindows();
    // used when double clicking the title bar area in qml
    // since macOS doesn't handle this when title bar is hidden
    Q_INVOKABLE static void zoom(QWindow*);
    // hotfix: macWindow will resize webUI when before zoom
    Q_INVOKABLE static void hotfixWebUIResize(QQuickItem* webUIs);
    Q_INVOKABLE static void hotfixNSVisualEffect(QWindow*);
//    Q_INVOKABLE static MacWindow* getMacWindow(QWindow*);

signals:

public slots:
};

typedef QSharedPointer<MacWindow> MacWindow_;

Q_DECLARE_METATYPE(MacWindow*)

#endif // WINDOW_H
