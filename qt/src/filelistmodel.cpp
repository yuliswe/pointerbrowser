#include "filelistmodel.hpp"

//FileListModel::FileListModel()
//    : MatrixModel<File_>()
//{

//}

int FileListModel::loadDirectoryContents(QString const& dirpath, void const* sender)
{
    qInfo() << "FileListModel::loadDirectoryContents" << dirpath;
    QDir dir(dirpath);

    qInfo() << dir.exists();
    QList<QFileInfo> infols = dir.entryInfoList();
    QList<File_> retval;
    for (int i = 0; i < infols.size(); i++)
    {
        retval.insert(i, File_::create(infols[i]));
    }
    replaceModel(retval);
    return retval.size();
}
