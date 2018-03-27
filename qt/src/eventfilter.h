#ifndef EVENTFILTER_H
#define EVENTFILTER_H
#include <QEvent>
#include <QObject>

class KeyPressEater : public QObject
{
        Q_OBJECT

    protected:
        bool eventFilter(QObject *obj, QEvent *event);
};

#endif // EVENTFILTER_H
