#ifndef MatrixModel_H
#define MatrixModel_H

#include <QtCore/QtCore>
#include "macros.hpp"


class Controller;
class BaseListModelSignals : public QObject {
    Q_OBJECT



    PROP_DEF_BEGINS
    SIG_TF_0(model_reset)
    SIG_TF_3(rows_moved, int, int, int)
    SIG_TF_2(rows_removed, int, int)
    SIG_TF_2(rows_inserted, int, int)
    PROP_DEF_ENDS

public:
        BaseListModelSignals() = default;
};

template<class T>
class BaseListModel
{

    friend class Controller;
protected:
    QList<T> m_list;
    T m_null;
    QSemaphore m_semaphore{100};
public:
    void lock_for_read() { m_semaphore.acquire(1); }
    void unlock_for_read() { m_semaphore.release(1); }
    void lock_for_read_write() { m_semaphore.acquire(100); }
    void unlock_for_read_write() { m_semaphore.release(100); }
    virtual T& null() { return m_null; }

public:
    BaseListModelSignals sig;

    BaseListModel() = default;

    int count()
    {
        lock_for_read();
        int n = m_list.count();
        unlock_for_read();
        return n;
    }

    T& get(int row)
    {
        if (row < 0 || row >= count()) {
            qCritical() << "Error: array index out of range" << row << "/" << count();
            return null();
        }
        lock_for_read();
        T& rt = m_list[row];
        unlock_for_read();
        return rt;
    }

    T const& get(int row) const
    {
        if (row < 0 || row >= count()) {
            qCritical() << "Error: array index out of range" << row << "/" << count();
            return null();
        }
        lock_for_read();
        T const& rt = m_list[row];
        unlock_for_read();
        return rt;
    }

    int indexOf(T const& target)
    {
        lock_for_read();
        int i = m_list.indexOf(target);
        unlock_for_read();
        return i;
    }

protected:
    bool insertRows(int row, int n)
    {
        if (row >= 0 && row <= count())
        {
            for (int i = row; i < n; i++) {
                lock_for_read_write();
                m_list.insert(i, T());
                unlock_for_read_write();
            }
            sig.emit_tf_rows_inserted(row, n);
            return true;
        }
        return false;
    }

    bool removeRows(int row, int n)
    {
        if (row >= 0 && row < count()
                && row + n - 1 >= 0 && row + n - 1 <= count())
        {
            for (int i = row; i < count(); i++) {
                lock_for_read_write();
                m_list.removeAt(row);
                unlock_for_read_write();
            }
            sig.emit_tf_rows_removed(row, n);
            return true;
        }
        return false;
    }

    void resetModel(QList<T> const& model)
    {
        lock_for_read_write();
        m_list = model;
        unlock_for_read_write();
        sig.emit_tf_model_reset();
    }

    void clear()
    {
        lock_for_read_write();
        m_list.clear();
        unlock_for_read_write();
        sig.emit_tf_model_reset();
    }

    void insert(T const& t, int i = 0)
    {
        lock_for_read_write();
        m_list.insert(i, t);
        unlock_for_read_write();
        sig.emit_tf_rows_inserted(i, 1);
    }

    void remove(int i = 0)
    {
        lock_for_read_write();
        m_list.removeAt(i);
        unlock_for_read_write();
        sig.emit_tf_rows_removed(i, 1);
    }

    void remove(T const& t)
    {
        int i;
        while ((i = m_list.indexOf(t)) > -1) {
            lock_for_read_write();
            m_list.removeAt(i);
            unlock_for_read_write();
            sig.emit_tf_rows_removed(i, 1);
        }
    }

    void move(int first, int len, int to)
    {
        int last = first + len - 1;
        lock_for_read_write();
        int count = m_list.count();
        if (to > count) {
            to = count;
        }
        if (first < 0) {
            first = 0;
        }
        QList<T> targets;
        if (to < first) {
            for (int i = 0; i < len; i++)
            {
                m_list.move(last, to);
            }
        } else if (to > first) {
            for (int i = 0; i < len; i++)
            {
                m_list.move(first, to - 1);
            }
        }
        unlock_for_read_write();
        sig.emit_tf_rows_moved(first, len, to);
    }
};


#endif // MatrixModel_H
