#ifndef FILE_H
#define FILE_H

#include "webpage.hpp"
#include "macros.hpp"
#include <QtCore/QtCore>

class File : public QObject, public QFileInfo
{
    Q_OBJECT

    PROP_DEF_BEGINS
    PROP_RWN_D(void *, thumbnail, nullptr)
    PROP_RWN_D(uint, size_bytes, 0)
    PROP_RWN_D(uint, size_bytes_exptected, 0)
    PROP_RWN_D(float, percentage, 0)
    PROP_DEF_ENDS
public:
    File(QFileInfo const&);
    virtual ~File() = default;
};

typedef QSharedPointer<File> File_;

Q_DECLARE_METATYPE(File_);

#endif // FILE_H
