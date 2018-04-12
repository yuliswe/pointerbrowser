#include <QObject>
#include <QEvent>
#include <QDebug>
#include <QKeyEvent>
#include "eventfilter.h"

bool EventFilter::eventFilter(QObject *obj, QEvent *event)
{
    if (event->type() == QEvent::KeyPress) {
        QKeyEvent *keyEvent = static_cast<QKeyEvent *>(event);
//        qDebug() << "EventFilter::eventFilter" << keyEvent->key();
        if (keyEvent->key() == Qt::Key_Control) {
            setCtrlKeyDown(true);
        }
    } else if (event->type() == QEvent::KeyRelease) {
        QKeyEvent *keyEvent = static_cast<QKeyEvent *>(event);
        if (keyEvent->key() == Qt::Key_Control) {
            setCtrlKeyDown(false);
        }
    }
    return false;
}

void EventFilter::setCtrlKeyDown(bool b) { _ctrlKeyDown = b; emit ctrlKeyDownChanged(); }
bool EventFilter::ctrlKeyDown() { return _ctrlKeyDown; }

