#include <QObject>
#include <QEvent>
#include <QDebug>
#include <QKeyEvent>
#include "eventfilter.h"

bool KeyPressEater::eventFilter(QObject *obj, QEvent *event)
{
    if (event->type() == QEvent::KeyPress) {
        QKeyEvent *keyEvent = static_cast<QKeyEvent *>(event);
        qDebug("Ate key press %d", keyEvent->key());
        // standard event processing
//        return QObject::eventFilter(obj, event);
    }
    return false;
}
