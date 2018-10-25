#ifndef FILESMODEL_H
#define FILESMODEL_H

#include <QtCore/QtCore>
#include "matrixmodel.hpp"
#include "file.hpp"
#include "macros.hpp"

class FileListModel : public MatrixModel<File_>
{
    Q_OBJECT

public:
    METH_ASYNC_1(int, loadDirectoryContents, QString const&)
};

typedef QSharedPointer<FileListModel> FileListModel_;

Q_DECLARE_METATYPE(FileListModel_)
//Q_DECLARE_METATYPE(MatrixModel<QSharedPointer<File>>)

#endif // FILESMODEL_H
