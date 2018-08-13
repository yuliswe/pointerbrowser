#ifndef MACROS_H
#define MACROS_H

//#define qDebug QT_NO_QDEBUG_MACRO
#include <QtCore/QtCore>

#define STRING(x) #x

#define PROP_DEF_BEGINS \
    public: Q_SIGNAL void dataChanged();

#define PROP_DEF_ENDS

#define PROP_RWN_D(type, prop, defv) \
    Q_PROPERTY(type prop READ prop WRITE set_##prop NOTIFY prop##_changed) \
    protected: QSemaphore m_##prop##_semaphore{100}; \
    protected: void lock_##prop##_for_read_write() { m_##prop##_semaphore.acquire(100); } \
    protected: void unlock_##prop##_for_read_write() { m_##prop##_semaphore.release(100); } \
    public: type prop() { m_##prop##_semaphore.acquire(1); type tmp = m_##prop; m_##prop##_semaphore.release(1); return tmp; } \
    public: void set_##prop(type const& val) { Q_ASSERT(thread() == QThread::currentThread()); lock_##prop##_for_read_write(); m_##prop = val; unlock_##prop##_for_read_write(); qDebug() << STRING(set_##prop) << val; emit prop##_changed(val); emit dataChanged(); } \
    protected: type m_##prop = defv; \
    public: Q_SIGNAL void prop##_changed(type);

#define PROP_RN_D(type, prop, defv) \
    Q_PROPERTY(type prop READ prop WRITE set_##prop NOTIFY prop##_changed) \
    protected: QSemaphore m_##prop##_semaphore{100}; \
    protected: void lock_##prop##_for_read_write() { m_##prop##_semaphore.acquire(100); } \
    protected: void unlock_##prop##_for_read_write() { m_##prop##_semaphore.release(100); } \
    public: type prop() { m_##prop##_semaphore.acquire(1); type tmp = m_##prop; m_##prop##_semaphore.release(1); return tmp; } \
    protected: void set_##prop(type const& val) { Q_ASSERT(thread() == QThread::currentThread()); lock_##prop##_for_read_write(); m_##prop = val; unlock_##prop##_for_read_write(); qDebug() << STRING(set_##prop) << val; emit prop##_changed(val); emit dataChanged(); } \
    protected: type m_##prop = defv; \
    public: Q_SIGNAL void prop##_changed(type);

#define PROP_N_D(type, prop, defv) \
    Q_PROPERTY(type prop READ prop WRITE set_##prop NOTIFY prop##_changed) \
    protected: QSemaphore m_##prop##_semaphore{100}; \
    protected: void lock_##prop##_for_read_write() { m_##prop##_semaphore.acquire(100); } \
    protected: void unlock_##prop##_for_read_write() { m_##prop##_semaphore.release(100); } \
    protected: type prop() { m_##prop##_semaphore.acquire(1); type tmp = m_##prop; m_##prop##_semaphore.release(1); return tmp; } \
    protected: void set_##prop(type const& val) { Q_ASSERT(thread() == QThread::currentThread()); lock_##prop##_for_read_write(); m_##prop = val; unlock_##prop##_for_read_write(); qDebug() << STRING(set_##prop) << val; emit prop##_changed(val); emit dataChanged(); } \
    protected: type m_##prop = defv; \
    public: Q_SIGNAL void prop##_changed(type);

// define write yourself
#define PROP_RwN_D(type, prop, defv) \
    Q_PROPERTY(type prop READ prop WRITE set_##prop NOTIFY prop##_changed) \
    protected: QSemaphore m_##prop##_semaphore{100}; \
    protected: void lock_##prop##_for_read_write() { m_##prop##_semaphore.acquire(100); } \
    protected: void unlock_##prop##_for_read_write() { m_##prop##_semaphore.release(100); } \
    public: type prop() { m_##prop##_semaphore.acquire(1); type tmp = m_##prop; m_##prop##_semaphore.release(1); return tmp; } \
    protected: void custom_set_##prop(type const& val); \
    protected: type m_##prop = defv; \
    public: void set_##prop(type const& val) { Q_ASSERT(thread() == QThread::currentThread()); lock_##prop##_for_read_write(); custom_set_##prop(val); type copy = m_##prop; unlock_##prop##_for_read_write(); qDebug() << STRING(set_##prop) << copy; emit prop##_changed(copy); emit dataChanged(); } \
    public: Q_SIGNAL void prop##_changed(type);

#define PROP_R_N_D(type, prop, defv) \
    Q_PROPERTY(type prop READ prop WRITE set_##prop NOTIFY prop##_changed) \
    protected: QSemaphore m_##prop##_semaphore{100}; \
    protected: void lock_##prop##_for_read_write() { m_##prop##_semaphore.acquire(100); } \
    protected: void unlock_##prop##_for_read_write() { m_##prop##_semaphore.release(100); } \
    public: type prop() { m_##prop##_semaphore.acquire(1); type tmp = m_##prop; m_##prop##_semaphore.release(1); return tmp; } \
    protected: void custom_set_##prop(type const& val); \
    protected: type m_##prop = defv; \
    protected: void set_##prop(type const& val) { Q_ASSERT(thread() == QThread::currentThread()); lock_##prop##_for_read_write(); custom_set_##prop(val); type copy = m_##prop; unlock_##prop##_for_read_write(); qDebug() << STRING(set_##prop) << copy; emit prop##_changed(copy); emit dataChanged(); } \
    public: Q_SIGNAL void prop##_changed(type);

#define SIG_TF_0(name) \
    public: Q_SIGNAL void signal_tf_##name(void); \
    public: void emit_tf_##name(void) { qInfo() << STRING(name); emit signal_tf_##name(); }

#define SIG_TF_1(name, type) \
    public: Q_SIGNAL void signal_tf_##name(type); \
    public: void emit_tf_##name(type value) { qInfo() << STRING(name) << value; emit signal_tf_##name(value); }

#define SIG_TF_2(name,T1,T2) \
    public: Q_SIGNAL void signal_tf_##name(T1,T2); \
    public: void emit_tf_##name(T1 v1,T2 v2) { qInfo() << STRING(name) << v1 << v2; emit signal_tf_##name(v1,v2); }

#define METH_ASYNC_0(RetT, Name) \
    protected: Q_INVOKABLE RetT Name(); \
    public: void Name##Async() { QMetaObject::invokeMethod(this, STRING(Name), Qt::QueuedConnection); } \
    public: RetT Name##AsyncBlocking() { RetT r; QMetaObject::invokeMethod(this, STRING(Name), Qt::BlockingQueuedConnection, Q_RETURN_ARG(RetT,r)); return r; }

#define METH_ASYNC_1(RetT,Name,T1) \
    protected: Q_INVOKABLE RetT Name(T1); \
    public: void Name##Async(T1 v1) { QMetaObject::invokeMethod(this, STRING(Name), Qt::QueuedConnection, Q_ARG(T1,v1)); } \
    public: RetT Name##AsyncBlocking(T1 v1) { RetT r; QMetaObject::invokeMethod(this, STRING(Name), Qt::BlockingQueuedConnection, Q_RETURN_ARG(RetT,r), Q_ARG(T1,v1)); return r; }

#define METH_ASYNC_2(RetT,Name,T1,T2) \
    protected: Q_INVOKABLE RetT Name(T1,T2); \
    public: void Name##Async(T1 v1, T2 v2) { QMetaObject::invokeMethod(this, STRING(Name), Qt::QueuedConnection, Q_ARG(T1,v1), Q_ARG(T2,v2)); } \
    public: RetT Name##AsyncBlocking(T1 v1, T2 v2) { RetT r; QMetaObject::invokeMethod(this, STRING(Name), Qt::BlockingQueuedConnection, Q_RETURN_ARG(RetT,r), Q_ARG(T1,v1), Q_ARG(T2,v2)); return r; }

#define METH_ASYNC_3(RetT,Name,T1,T2,T3) \
    protected: Q_INVOKABLE RetT Name(T1,T2,T3); \
    public: void Name##Async(T1 v1, T2 v2, T3 v3) { QMetaObject::invokeMethod(this, STRING(Name), Qt::QueuedConnection, Q_ARG(T1,v1), Q_ARG(T2,v2), Q_ARG(T3,v3)); } \
    public: RetT Name##AsyncBlocking(T1 v1, T2 v2, T3 v3) { RetT r; QMetaObject::invokeMethod(this, STRING(Name), Qt::BlockingQueuedConnection, Q_RETURN_ARG(RetT,r), Q_ARG(T1,v1), Q_ARG(T2,v2), Q_ARG(T3,v3)); return r; }

#define METH_ASYNC_4(RetT,Name,T1,T2,T3,T4) \
    protected: Q_INVOKABLE RetT Name(T1,T2,T3,T4); \
    public: void Name##Async(T1 v1, T2 v2, T3 v3, T4 v4) { QMetaObject::invokeMethod(this, STRING(Name), Qt::QueuedConnection, Q_ARG(T1,v1), Q_ARG(T2,v2), Q_ARG(T3,v3), Q_ARG(T4,v4)); } \
    public: RetT Name##AsyncBlocking(T1 v1, T2 v2, T3 v3, T4 v4) { RetT r; QMetaObject::invokeMethod(this, STRING(Name), Qt::BlockingQueuedConnection, Q_RETURN_ARG(RetT,r), Q_ARG(T1,v1), Q_ARG(T2,v2), Q_ARG(T3,v3), Q_ARG(T4,v4)); return r; }

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
