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

File_& FileListModel::null()
{
    return m_null;
}

int FileListModel::indexOfDownloadUrl(Url url)
{
    for (int i = 0; i < count(); i++) {
        if (get(i)->download_url() == url) {
            return i;
        }
    }
    return -1;
}

//File_ FileListModel::get(int row)
//{
//    qvariant(row).value<File_>();
//}

//File_ const FileListModel::get(int row) const
//{
//    qvariant(row).value<File_>();
//}
