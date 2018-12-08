#ifndef STRINGUTILS_HPP
#define STRINGUTILS_HPP

#include <QtCore/QtCore>
typedef QList<QPair<int,int>> RangeSet;

class StringUtils : public QObject
{
    Q_OBJECT
public:
    explicit StringUtils(QObject *parent = nullptr);
static RangeSet highlightWords(QString const& in, QSet<QString> const& word);
signals:

public slots:
};

Q_DECLARE_METATYPE(RangeSet)
#endif // STRINGUTILS_HPP
