#ifndef MACROS_H
#define MACROS_H

#include "logging.hpp"
#include <memory>

//#define qDebug QT_NO_QDEBUG_MACRO
#include <QtCore/QtCore>

#define STRING(x) #x

#define PROP_RWN_D(type, prop, defv) \
    Q_PROPERTY(type prop READ prop WRITE set_##prop NOTIFY prop##_changed) \
    protected: QSemaphore m_##prop##_semaphore{100}; \
    protected: void lock_##prop##_for_read_write() { qCDebug(MacroLogging) << STRING(lock_##prop##_for_read_write); m_##prop##_semaphore.acquire(100); } \
    protected: void unlock_##prop##_for_read_write() { qCDebug(MacroLogging) << STRING(unlock_##prop##_for_read_write); m_##prop##_semaphore.release(100); } \
    public: type prop() { qCDebug(MacroLogging) << STRING(get_##prop); m_##prop##_semaphore.acquire(1); type tmp = m_##prop; m_##prop##_semaphore.release(1); return tmp; } \
    public: Q_INVOKABLE type const& set_##prop(type const& val, void const* sender = nullptr) { qCInfo(MacroLogging) << STRING(set_##prop) << val; Q_ASSERT(thread() == QThread::currentThread()); lock_##prop##_for_read_write(); m_##prop = val; unlock_##prop##_for_read_write(); emit prop##_changed(val, sender); emit dataChanged(); return val; } \
    public: void set_##prop##_async(type const& val, void const* sender = nullptr) { qCDebug(MacroLogging) << STRING(set_##prop##_async) << val; QMetaObject::invokeMethod(this, STRING(set_##prop), Qt::QueuedConnection, Q_ARG(type const&,val), Q_ARG(void const*,sender)); } \
    protected: type m_##prop = defv; \
    public: Q_SIGNAL void prop##_changed(type, void const* sender = nullptr);

#define PROP_RN_D(type, prop, defv) \
    Q_PROPERTY(type prop READ prop WRITE set_##prop NOTIFY prop##_changed) \
    protected: QSemaphore m_##prop##_semaphore{100}; \
    protected: void lock_##prop##_for_read_write() { qCDebug(MacroLogging) << STRING(lock_##prop##_for_read_write); m_##prop##_semaphore.acquire(100); } \
    protected: void unlock_##prop##_for_read_write() { qCDebug(MacroLogging) << STRING(unlock_##prop##_for_read_write); m_##prop##_semaphore.release(100); } \
    public: type prop() { qCDebug(MacroLogging) << STRING(get_##prop); m_##prop##_semaphore.acquire(1); type tmp = m_##prop; m_##prop##_semaphore.release(1); return tmp; } \
    protected: Q_INVOKABLE type const& set_##prop(type const& val, void const* sender = nullptr) { qCInfo(MacroLogging) << STRING(set_##prop) << val; Q_ASSERT(thread() == QThread::currentThread()); lock_##prop##_for_read_write(); m_##prop = val; unlock_##prop##_for_read_write(); emit prop##_changed(val, sender); emit dataChanged(); return val; } \
    protected: void set_##prop##_async(type const& val, void const* sender = nullptr) { qCDebug(MacroLogging) << STRING(set_##prop##_async) << val; QMetaObject::invokeMethod(this, STRING(set_##prop), Qt::QueuedConnection, Q_ARG(type const&,val), Q_ARG(void const*,sender)); } \
    protected: type m_##prop = defv; \
    public: Q_SIGNAL void prop##_changed(type, void const* sender = nullptr);

#define PROP_N_D(type, prop, defv) \
    Q_PROPERTY(type prop READ prop WRITE set_##prop NOTIFY prop##_changed) \
    protected: QSemaphore m_##prop##_semaphore{100}; \
    protected: void lock_##prop##_for_read_write() { qCDebug(MacroLogging) << STRING(lock_##prop##_for_read_write); m_##prop##_semaphore.acquire(100); } \
    protected: void unlock_##prop##_for_read_write() { qCDebug(MacroLogging) << STRING(unlock_##prop##_for_read_write); m_##prop##_semaphore.release(100); } \
    protected: type prop() { qCDebug(MacroLogging) << STRING(get_##prop); m_##prop##_semaphore.acquire(1); type tmp = m_##prop; m_##prop##_semaphore.release(1); return tmp; } \
    protected: Q_INVOKABLE type const& set_##prop(type const& val, void const* sender = nullptr) { qCInfo(MacroLogging) << STRING(set_##prop) << val; Q_ASSERT(thread() == QThread::currentThread()); lock_##prop##_for_read_write(); m_##prop = val; unlock_##prop##_for_read_write(); emit prop##_changed(val, sender); emit dataChanged(); return val; } \
    protected: void set_##prop##_async(type const& val, void const* sender = nullptr) { qCDebug(MacroLogging) << STRING(set_##prop##_async) << val; QMetaObject::invokeMethod(this, STRING(set_##prop), Qt::QueuedConnection, Q_ARG(type const&,val), Q_ARG(void const*,sender)); } \
    protected: type m_##prop = defv; \
    public: Q_SIGNAL void prop##_changed(type, void const* sender = nullptr);

// define write yourself
#define PROP_RwN_D(type, prop, defv) \
    Q_PROPERTY(type prop READ prop WRITE set_##prop NOTIFY prop##_changed) \
    protected: QSemaphore m_##prop##_semaphore{100}; \
    protected: void lock_##prop##_for_read_write() { qCDebug(MacroLogging) << STRING(lock_##prop##_for_read_write); m_##prop##_semaphore.acquire(100); } \
    protected: void unlock_##prop##_for_read_write() { qCDebug(MacroLogging) << STRING(unlock_##prop##_for_read_write); m_##prop##_semaphore.release(100); } \
    public: type prop() { qCDebug(MacroLogging) << STRING(get_##prop); m_##prop##_semaphore.acquire(1); type tmp = m_##prop; m_##prop##_semaphore.release(1); return tmp; } \
    protected: type custom_set_##prop(type const& val, void const* sender = nullptr); \
    protected: type m_##prop = defv; \
    protected: Q_INVOKABLE type const& set_##prop(type const& val, void const* sender = nullptr) { qCInfo(MacroLogging) << STRING(set_##prop) << val; Q_ASSERT(thread() == QThread::currentThread()); type const& newval = custom_set_##prop(val,sender); lock_##prop##_for_read_write(); m_##prop = newval; unlock_##prop##_for_read_write(); emit prop##_changed(newval, sender); emit dataChanged(); return newval; } \
    public: void set_##prop##_async(type const& val, void const* sender = nullptr) { qCDebug(MacroLogging) << STRING(set_##prop##_async) << val; QMetaObject::invokeMethod(this, STRING(set_##prop), Qt::QueuedConnection, Q_ARG(type const&,val), Q_ARG(void const*,sender)); } \
    public: Q_SIGNAL void prop##_changed(type, void const* sender = nullptr);

#define PROP_R_N_D(type, prop, defv) \
    Q_PROPERTY(type prop READ prop WRITE set_##prop NOTIFY prop##_changed) \
    protected: QSemaphore m_##prop##_semaphore{100}; \
    protected: void lock_##prop##_for_read_write() { qCDebug(MacroLogging) << STRING(lock_##prop##_for_read_write); m_##prop##_semaphore.acquire(100); } \
    protected: void unlock_##prop##_for_read_write() { qCDebug(MacroLogging) << STRING(unlock_##prop##_for_read_write); m_##prop##_semaphore.release(100); } \
    public: type prop() { qCDebug(MacroLogging) << STRING(get_##prop); m_##prop##_semaphore.acquire(1); type tmp = m_##prop; m_##prop##_semaphore.release(1); return tmp; } \
    protected: type custom_set_##prop(type const& val, void const* sender = nullptr); \
    protected: type m_##prop = defv; \
    protected: Q_INVOKABLE type const& set_##prop(type const& val, void const* sender = nullptr) { qCInfo(MacroLogging) << STRING(set_##prop) << val; Q_ASSERT(thread() == QThread::currentThread()); type const& newval = custom_set_##prop(val,sender); lock_##prop##_for_read_write(); m_##prop = newval; unlock_##prop##_for_read_write(); emit prop##_changed(newval, sender); emit dataChanged(); return newval; } \
    protected: void set_##prop##_async(type const& val, void const* sender = nullptr) { qCDebug(MacroLogging) << STRING(set_##prop##_async) << val; QMetaObject::invokeMethod(this, STRING(set_##prop), Qt::QueuedConnection, Q_ARG(type const&,val), Q_ARG(void const*,sender)); } \
    public: Q_SIGNAL void prop##_changed(type, void const* sender = nullptr);

#define SIG_TF_0(name) \
    public: Q_SIGNAL void signal_tf_##name(void const* sender = nullptr); \
    public: void emit_tf_##name(void const* sender = nullptr) { qCInfo(MacroLogging) << STRING(emit_tf_##name); emit signal_tf_##name(sender); }

#define SIG_TF_1(name,T1) \
    public: Q_SIGNAL void signal_tf_##name(T1,void const* sender = nullptr); \
    public: void emit_tf_##name(T1 v1,void const* sender = nullptr) { qCInfo(MacroLogging) << STRING(emit_tf_##name) << v1; emit signal_tf_##name(v1,sender); }

#define SIG_TF_2(name,T1,T2) \
    public: Q_SIGNAL void signal_tf_##name(T1,T2,void const* sender = nullptr); \
    public: void emit_tf_##name(T1 v1,T2 v2,void const* sender = nullptr) { qCInfo(MacroLogging) << STRING(emit_tf_##name) << v1 << v2; emit signal_tf_##name(v1,v2,sender); }

#define SIG_TF_3(name,T1,T2,T3) \
    public: Q_SIGNAL void signal_tf_##name(T1,T2,T3,void const* sender = nullptr); \
    public: void emit_tf_##name(T1 v1,T2 v2, T3 v3,void const* sender = nullptr) { qCInfo(MacroLogging) << STRING(emit_tf_##name) << v1 << v2 << v3; emit signal_tf_##name(v1,v2,v3,sender); }

#define METH_ASYNC_0(RetT, Name) \
    protected: Q_INVOKABLE RetT Name(void const* sender = nullptr); \
    public: void Name##Async(void const* sender = nullptr) { QMetaObject::invokeMethod(this, STRING(Name), Qt::QueuedConnection, Q_ARG(void const*,sender)); } \
    public: RetT Name##Blocking(void const* sender = nullptr) { Q_ASSERT(thread() != QThread::currentThread()); RetT r; QMetaObject::invokeMethod(this, STRING(Name), Qt::BlockingQueuedConnection, Q_RETURN_ARG(RetT,r), Q_ARG(void const*,sender)); return r; }

#define METH_ASYNC_1(RetT,Name,T1) \
    protected: Q_INVOKABLE RetT Name(T1, void const* sender = nullptr); \
    public: void Name##Async(T1 v1, void const* sender = nullptr) { QMetaObject::invokeMethod(this, STRING(Name), Qt::QueuedConnection, Q_ARG(T1,v1), Q_ARG(void const*,sender)); } \
    public: RetT Name##Blocking(T1 v1, void const* sender = nullptr) { Q_ASSERT(thread() != QThread::currentThread()); RetT r; QMetaObject::invokeMethod(this, STRING(Name), Qt::BlockingQueuedConnection, Q_RETURN_ARG(RetT,r), Q_ARG(T1,v1), Q_ARG(void const*,sender)); return r; }

#define METH_ASYNC_2(RetT,Name,T1,T2) \
    protected: Q_INVOKABLE RetT Name(T1, T2, void const* sender = nullptr); \
    public: void Name##Async(T1 v1, T2 v2, void const* sender = nullptr) { QMetaObject::invokeMethod(this, STRING(Name), Qt::QueuedConnection, Q_ARG(T1,v1), Q_ARG(T2,v2), Q_ARG(void const*,sender)); } \
    public: RetT Name##Blocking(T1 v1, T2 v2, void const* sender = nullptr) { Q_ASSERT(thread() != QThread::currentThread()); RetT r; QMetaObject::invokeMethod(this, STRING(Name), Qt::BlockingQueuedConnection, Q_RETURN_ARG(RetT,r), Q_ARG(T1,v1), Q_ARG(T2,v2), Q_ARG(void const*,sender)); return r; }

#define METH_ASYNC_3(RetT,Name,T1,T2,T3) \
    protected: Q_INVOKABLE RetT Name(T1,T2,T3,void const* sender = nullptr); \
    public: void Name##Async(T1 v1, T2 v2, T3 v3, void const* sender = nullptr) { QMetaObject::invokeMethod(this, STRING(Name), Qt::QueuedConnection, Q_ARG(T1,v1), Q_ARG(T2,v2), Q_ARG(T3,v3), Q_ARG(void const*,sender)); } \
    public: RetT Name##Blocking(T1 v1, T2 v2, T3 v3, void const* sender = nullptr) { Q_ASSERT(thread() != QThread::currentThread()); RetT r; QMetaObject::invokeMethod(this, STRING(Name), Qt::BlockingQueuedConnection, Q_RETURN_ARG(RetT,r), Q_ARG(T1,v1), Q_ARG(T2,v2), Q_ARG(T3,v3), Q_ARG(void const*,sender)); return r; }

#define METH_ASYNC_4(RetT,Name,T1,T2,T3,T4) \
    protected: Q_INVOKABLE RetT Name(T1,T2,T3,T4, void const* sender = nullptr); \
    public: void Name##Async(T1 v1, T2 v2, T3 v3, T4 v4, void const* sender = nullptr) { QMetaObject::invokeMethod(this, STRING(Name), Qt::QueuedConnection, Q_ARG(T1,v1), Q_ARG(T2,v2), Q_ARG(T3,v3), Q_ARG(T4,v4), Q_ARG(void const*,sender)); } \
    public: RetT Name##Blocking(T1 v1, T2 v2, T3 v3, T4 v4, void const* sender = nullptr) { Q_ASSERT(thread() != QThread::currentThread()); RetT r; QMetaObject::invokeMethod(this, STRING(Name), Qt::BlockingQueuedConnection, Q_RETURN_ARG(RetT,r), Q_ARG(T1,v1), Q_ARG(T2,v2), Q_ARG(T3,v3), Q_ARG(T4,v4), Q_ARG(void const*,sender)); return r; }

#define METH_ASYNC_5(RetT,Name,T1,T2,T3,T4,T5) \
    protected: Q_INVOKABLE RetT Name(T1,T2,T3,T4,T5, void const* sender = nullptr); \
    public: void Name##Async(T1 v1, T2 v2, T3 v3, T4 v4, T5 v5, void const* sender = nullptr) { QMetaObject::invokeMethod(this, STRING(Name), Qt::QueuedConnection, Q_ARG(T1,v1), Q_ARG(T2,v2), Q_ARG(T3,v3), Q_ARG(T4,v4), Q_ARG(T5,v5), Q_ARG(void const*,sender)); } \
    public: RetT Name##Blocking(T1 v1, T2 v2, T3 v3, T4 v4, T5 v5, void const* sender = nullptr) { Q_ASSERT(thread() != QThread::currentThread()); RetT r; QMetaObject::invokeMethod(this, STRING(Name), Qt::BlockingQueuedConnection, Q_RETURN_ARG(RetT,r), Q_ARG(T1,v1), Q_ARG(T2,v2), Q_ARG(T3,v3), Q_ARG(T4,v4), Q_ARG(T5,v5), Q_ARG(void const*,sender)); return r; }


#define PROP_DEF_BEGINS \
    public: Q_SIGNAL void dataChanged(); \
    protected: std::unique_ptr<QMetaObject::Connection> m_connections[10]; \
    public: void replaceConnection(int i, QMetaObject::Connection const& conn) { if (m_connections[i] != nullptr) { QObject::disconnect(*m_connections[i]); }; m_connections[i] = std::make_unique<QMetaObject::Connection>(conn); }

#define PROP_DEF_ENDS


template<class T>
QDebug& operator<<(QDebug& debug, const std::shared_ptr<T>& ptr)
{
    debug << ptr.get();
    return debug;
}

template<class T>
std::shared_ptr<T> shared() {
    T* p = new T();
    return std::shared_ptr<T>(p, [=](T* pp) {
        pp->deleteLater();
    });
}

template<class T, class T1>
std::shared_ptr<T> shared(T1 v1) {
    T* p = new T(v1);
    return std::shared_ptr<T>(p, [=](T* pp) {
        pp->deleteLater();
    });
}

template<class T, class T1, class T2>
std::shared_ptr<T> shared(T1 v1, T2 v2) {
    T* p = new T(v1,v2);
    return std::shared_ptr<T>(p, [=](T* pp) {
        pp->deleteLater();
    });
}

template<class T, class T1, class T2, class T3>
std::shared_ptr<T> shared(T1 v1, T2 v2, T3 v3) {
    T* p = new T(v1,v2,v3);
    return std::shared_ptr<T>(p, [=](T* pp) {
        pp->deleteLater();
    });
}

template<class T, class T1, class T2, class T3, class T4>
std::shared_ptr<T> shared(T1 v1, T2 v2, T3 v3, T4 v4) {
    T* p = new T(v1,v2,v3,v4);
    return std::shared_ptr<T>(p, [=](T* pp) {
        pp->deleteLater();
    });
}
#endif // MACROS_H
