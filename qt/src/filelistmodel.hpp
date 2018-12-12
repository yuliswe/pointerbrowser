#ifndef FILESMODEL_H
#define FILESMODEL_H

#include <QtCore/QtCore>
#include "baselistmodel.hpp"
#include "file.hpp"
#include "macros.hpp"

class Controller;
class FileListModel : public QObject, public BaseListModel<File_>
{
    File_ m_null = File_::create();
    virtual File_& null() override;
    friend class Controller;
    Q_OBJECT
public:
    METH_ASYNC_1(int, loadDirectoryContents, QString const&)
    int indexOfDownloadUrl(Url url);
};

typedef QSharedPointer<FileListModel> FileListModel_;

Q_DECLARE_METATYPE(FileListModel_)

#endif // FILESMODEL_H
