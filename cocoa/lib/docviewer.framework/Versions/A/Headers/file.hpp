#ifndef FILE_H
#define FILE_H

#include "webpage.hpp"
#include "macros.hpp"
#include "url.hpp"
#include <QtCore/QtCore>

class Controller;
class FileListModel;

class File : public QObject, public QFileInfo
{
    friend class Controller;
    friend class FileListModel;

    Q_OBJECT

    PROP_DEF_BEGINS
    PROP_RWN_D(std::shared_ptr<void>, thumbnail, nullptr)
    PROP_RWN_D(qint64, size_bytes_downloaded, 0)
    PROP_RWN_D(qint64, size_bytes_addition, 0)
    PROP_RWN_D(qint64, size_bytes_expected, 0)
    PROP_RWN_D(float, percentage, 0)
    PROP_RN_D(bool, downloading, false)
    PROP_RWN_D(Url, download_url, Url())
    PROP_RWN_D(QString, save_as_filename, "")
    PROP_DEF_ENDS

    SIG_TF_0(download_resume)
    SIG_TF_0(download_pause)
    SIG_TF_0(download_stop)

public:
        File() = default;
    File(File const&);
    File(QFileInfo const&);
    virtual ~File() = default;
    QString filesize();
    QString downloadProgress();
};

typedef QSharedPointer<File> File_;
Q_DECLARE_METATYPE(File);
Q_DECLARE_METATYPE(File_);

#endif // FILE_H
