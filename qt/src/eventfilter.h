#ifndef EVENTFILTER_H
#define EVENTFILTER_H
#include <QEvent>
#include <QObject>

class EventFilter : public QObject
{
        Q_OBJECT
        Q_PROPERTY(bool ctrlKeyDown READ ctrlKeyDown WRITE setCtrlKeyDown NOTIFY ctrlKeyDownChanged)

    public:
        bool _ctrlKeyDown = false;
        bool eventFilter(QObject *obj, QEvent *event);
        bool ctrlKeyDown();
        void setCtrlKeyDown(bool b);

    signals:
        void ctrlKeyDownChanged();
};

#endif // EVENTFILTER_H
