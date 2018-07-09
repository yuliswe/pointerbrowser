#ifndef MACROS_H
#define MACROS_H

#include <QObject>


#define PROP_R_D(type, prop, val) \
    Q_PROPERTY(type prop READ prop) \
    protected: type _##prop = val; \
    public: type prop() const { return _##prop; }

#define PROP_RWN(type, prop) \
    Q_PROPERTY(type prop READ prop WRITE set_##prop NOTIFY prop##_changed) \
    public: type prop() const { return _##prop; } \
    public: void set_##prop(type val) { _##prop = val; emit prop##_changed(val); } \
    protected: type _##prop; \
    Q_SIGNAL void prop##_changed(type);

#endif // MACROS_H
