#include "filelistmodel.hpp"
#include "filemanager.hpp"


int FileListModel::loadDirectoryContents(QString const& dirpath, void const* sender)
{
    qInfo() << "FileListModel::loadDirectoryContents" << dirpath;
    QList<QFileInfo> infols = FileManager::readDirContents(dirpath);
    QList<File_> retval;
    for (int i = 0; i < infols.size(); i++)
    {
        retval.insert(i, File_::create(infols[i]));
    }
    resetModel(retval);
    return retval.size();
}


//File_ FileListModel::get(int row)
//{
//    qvariant(row).value<File_>();
//}

//File_ const FileListModel::get(int row) const
//{
//    qvariant(row).value<File_>();
//}
