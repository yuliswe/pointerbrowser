#include <QObject>
#include <QEvent>
#include <QDebug>
#include <QKeyEvent>
#include "eventfilter.h"

bool EventFilter::eventFilter(QObject *obj, QEvent *event)
{
    switch(event->type()) {
    case QEvent::KeyPress: {
        QKeyEvent* e = static_cast<QKeyEvent *>(event);
//        qDebug() << "EventFilter::eventFilter" << obj << e->modifiers() << e->key() << e->isAutoRepeat();
        if (e->key() == Qt::Key_Control) {
            setCtrlKeyDown(true);
        }
        break;
    }
    case QEvent::KeyRelease: {
        QKeyEvent* e = static_cast<QKeyEvent *>(event);
        if (e->key() == Qt::Key_Control) {
            setCtrlKeyDown(false);
        }
        break;
    }
    default:
        return false;
    }
    return false;
}

void EventFilter::setCtrlKeyDown(bool b) { _ctrlKeyDown = b; emit ctrlKeyDownChanged(); }
bool EventFilter::ctrlKeyDown() { return _ctrlKeyDown; }

