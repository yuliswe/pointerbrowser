#ifndef MatrixModel_H
#define MatrixModel_H

#include <QtCore/QtCore>

template<class T>
class MatrixModel : public QAbstractListModel
{

protected:
    QList<T> m_list;
    int m_nrows = 0;
    int m_ncols = 0;
public:
    MatrixModel() = default;

    MatrixModel(int nrows, int ncols = 0) {
        m_nrows = nrows;
        m_ncols = ncols;
        m_list.reserve(nrows * ncols);
    }

    int rowCount(const QModelIndex &parent = QModelIndex()) const override
    {
        return m_nrows;
    }

    int columnCount(const QModelIndex &parent = QModelIndex()) const override
    {
        return m_ncols;
    }

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override
    {
        return QVariant(get(index.row(), index.column()));
    }

    T& get(int row, int col = 0, const QModelIndex &parent = QModelIndex())
    {
        return m_list[row * columnCount() + col];
    }

    T const& get(int row, int col = 0, const QModelIndex &parent = QModelIndex()) const
    {
        return m_list[row * columnCount() + col];
    }

    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override
    {
        if (index.row() >= 0 && index.row() < rowCount()
                && index.column() >= 0 && index.column() < columnCount())
        {
            m_list[index.column() + index.row() * columnCount()] = value.value<T>();
            return true;
        }
        return false;
    }

    bool insertRows(int row, int count, const QModelIndex &parent = QModelIndex()) override
    {
        if (row >= 0 && row <= rowCount())
        {
            beginInsertRows(parent, row, count);
            for (int i = row; i < count; i++) {
                for (int j = 0; j < columnCount(); j++) {
                    m_list.insert(i, T());
                }
            }
            endInsertRows();
            return true;
        }
        return false;
    }

    bool removeRows(int row, int count, const QModelIndex &parent = QModelIndex()) override
    {
        if (row >= 0 && row < rowCount()
                && row + count - 1 >= 0 && row + count - 1 <= rowCount())
        {
            beginRemoveRows(parent, row, count);
            for (int i = row; i < count; i++) {
                for (int j = 0; j < columnCount(); j++) {
                    m_list.removeAt(row);
                }
            }
            endRemoveRows();
            return true;
        }
        return false;
    }

    void replaceModel(QList<T> const& model)
    {
        beginResetModel();
        m_list = model;
        endResetModel();
    }

    void clearModel()
    {
        beginResetModel();
        m_list.clear();
        endResetModel();
    }

//    bool moveRows(const QModelIndex &sourceParent, int sourceRow, int count, const QModelIndex &destinationParent, int destinationChild) override
//    {
//        beginMoveRows();

//        endMoveRows();
//    }

};


#endif // MatrixModel_H
