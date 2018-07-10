#include <QObject>
#include <QEvent>
#include <QDebug>
#include <QKeyEvent>
#include "eventfilter.h"

#define QPROP_FUNC(TYPE, PROP) \
    TYPE EventFilter::PROP() const { return _##PROP; } \
    void EventFilter::set_##PROP(TYPE x) { _##PROP = x; }

QPROP_FUNC(bool, ctrlKeyDown)
QPROP_FUNC(bool, escapeKeyDown)

bool EventFilter::eventFilter(QObject *obj, QEvent *event)
{
    switch(event->type()) {
    case QEvent::KeyPress: {
        QKeyEvent* e = static_cast<QKeyEvent *>(event);
        qInfo() << "EventFilter::eventFilter" << obj << e->modifiers() << e->key() << e->isAutoRepeat();
        switch(e->key()) {
        case Qt::Key_Control: set_ctrlKeyDown(true); return true;
        case Qt::Key_Escape: set_escapeKeyDown(true); return false;
        }
        break;
    }
    case QEvent::KeyRelease: {
        QKeyEvent* e = static_cast<QKeyEvent *>(event);
        switch(e->key()) {
        case Qt::Key_Control: set_ctrlKeyDown(false); return true;
        case Qt::Key_Escape: set_escapeKeyDown(false); return false;
        }
        break;
    }
    case QEvent::WindowStateChange: {
        qDebug() << event << endl;
        break;
    }
    case QEvent::UpdateRequest: {
        qDebug() << obj <<  event << endl;
        break;
    }
    default:
        return false;
    }
    return false;
}
