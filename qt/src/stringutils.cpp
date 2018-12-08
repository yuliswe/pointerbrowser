#include "stringutils.hpp"

StringUtils::StringUtils(QObject *parent) : QObject(parent)
{

}

RangeSet StringUtils::highlightWords(QString const& in, QSet<QString> const& keywords)
{
    RangeSet out;
    QString lower_in = in.toLower();
    for (auto i = keywords.begin(); i != keywords.end(); i++) {
        QString const& word_lower = i->toLower();
        int start = lower_in.indexOf(word_lower);
        if (start == -1 || word_lower.isEmpty()) { continue; }
//        QString left = out.left(start);
//        QString mid = out.mid(start, word.length());
//        QString right = out.mid(end);
//        out = left + "|" + mid + "|" + right;
        out << QPair<int,int>(start, word_lower.length());
    }
    return out;
}
