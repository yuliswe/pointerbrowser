#ifndef TAGSMANAGER_HPP
#define TAGSMANAGER_HPP

#include <QtCore/QtCore>
#include "macros.hpp"
#include "webpage.hpp"
#include "filemanager.hpp"
#include "baselistmodel.hpp"


class TagContainer : public QObject, public BaseListModel<Webpage_>
{

    Q_OBJECT

    PROP_DEF_BEGINS
    PROP_RN_D(QString, title, "")
    PROP_DEF_ENDS

    public: TagContainer() = default;
    TagContainer(QString const&);
    void reloadFromFile();
    void saveToFile();
    void deleteFile();
    void renameFile(QString const&);
    int removeByUrl(Url const&);
    void insertWebpage(Webpage_, int = 0);
    int indexOfUrl(Url const&);
    bool containsUrl(Url const&);
    QString filename();


};
typedef QSharedPointer<TagContainer> TagContainer_;

class TagsCollection : public QObject, public BaseListModel<TagContainer_>
{

    Q_OBJECT

    PROP_DEF_BEGINS
    PROP_DEF_ENDS
    int indexOfTagContainer(TagContainer*);
//    METH_ASYNC_1(int, remove, int)
};
typedef QSharedPointer<TagsCollection> TagsCollection_;

Q_DECLARE_METATYPE(TagContainer_)
Q_DECLARE_METATYPE(TagsCollection_)

#endif // TAGSMANAGER_HPP
