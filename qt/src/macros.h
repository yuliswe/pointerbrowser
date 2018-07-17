#ifndef MACROS_H
#define MACROS_H

#include <QObject>
#include <QDebug>

#define STRING(x) #x

#define PROP_R_D(type, prop, val) \
    Q_PROPERTY(type prop READ prop) \
    protected: type _##prop = val; \
    public: type prop() const { return _##prop; }

#define PROP_R(type, prop) \
    Q_PROPERTY(type prop READ prop FINAL) \
    protected: type _##prop; \
    public: type prop() const { return _##prop; }

#define PROP_RWN(type, prop) \
    Q_PROPERTY(type prop READ prop WRITE set_##prop NOTIFY prop##_changed) \
    public: type prop() const { return _##prop; } \
    public: void set_##prop(type const & val) { _##prop = val; qDebug() << STRING(set_##prop) << val; emit prop##_changed(val); } \
    protected: type _##prop; \
    Q_SIGNAL void prop##_changed(type);

#define PROP_RWN_D(type, prop, defv) \
    Q_PROPERTY(type prop READ prop WRITE set_##prop NOTIFY prop##_changed) \
    public: type prop() const { return _##prop; } \
    public: void set_##prop(type const & val) { _##prop = val; qDebug() << STRING(set_##prop) << val; emit prop##_changed(val); } \
    protected: type _##prop = defv; \
    Q_SIGNAL void prop##_changed(type);

#define PROP_RN_D(type, prop, defv) \
    Q_PROPERTY(type prop READ prop NOTIFY prop##_changed) \
    public: type prop() const { return _##prop; } \
    public: void set_##prop(type const & val) { _##prop = val; qDebug() << STRING(set_##prop) << val; emit prop##_changed(val); } \
    protected: type _##prop = defv; \
    Q_SIGNAL void prop##_changed(type);

// define write yourself
#define PROP_RwN_D(type, prop, defv) \
    Q_PROPERTY(type prop READ prop WRITE set_##prop NOTIFY prop##_changed) \
    public: type prop() const { return _##prop; } \
    public: void set_##prop(type const & val); \
    protected: type _##prop = defv; \
    Q_SIGNAL void prop##_changed(type);

#define CONST_PROP_RN_D(type, prop, defv) \
    Q_PROPERTY(type prop READ prop NOTIFY prop##_changed) \
    public: type const prop() const { return _##prop; } \
    protected: type const _##prop = defv; \
    Q_SIGNAL void prop##_changed(type);

#endif // MACROS_H
