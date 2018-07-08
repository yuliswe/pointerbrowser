#ifndef WINDOW_H
#define WINDOW_H

#include <QQuickItem>
#include <QQuickWindow>

class MacWindow : public QObject
{
    Q_OBJECT
    QWindow* window;
public:
    MacWindow(QWindow* target = nullptr);
    static void initMacWindows();
    Q_INVOKABLE static void zoom(QWindow* target);

signals:

public slots:
};

#endif // WINDOW_H
