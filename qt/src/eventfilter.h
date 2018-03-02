#ifndef EVENTFILTER_H
#define EVENTFILTER_H
#include <QEvent>
#include <QObject>


#define QPROP_DEC(type, prop) \
    Q_PROPERTY(type prop READ prop WRITE set_##prop NOTIFY prop##_changed) \
    public: type prop() const; \
    public: void set_##prop(type); \
    private: type _##prop; \
    Q_SIGNAL void prop##_changed(type); \


class EventFilter : public QObject
{
    Q_OBJECT

    QPROP_DEC(bool, ctrlKeyDown)
    QPROP_DEC(bool, escapeKeyDown)

    public:
        bool eventFilter(QObject *obj, QEvent *event);
};

#endif // EVENTFILTER_H
