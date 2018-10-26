#include "file.hpp"
#include <iomanip>

File::File(File const& other)
    : QFileInfo(other)
{
//    m_size_bytes = other
}

File::File(QFileInfo const& info)
    : QFileInfo(info)
{

}

QString File::downloadProgress()
{
    QString rtv;
    QTextStream textstream(&rtv);
    QLocale locale;
    QString total;
    QString percent;
    if (size_bytes_expected() > 0) {
        total = locale.formattedDataSize(size_bytes_expected());
        percent.sprintf("%d%%", int(std::floor(percentage() * 100)));
    } else {
        total = "?";
        percent = "?%";
    }
    textstream << qSetFieldWidth(0) << "Downloaded "
               << qSetFieldWidth(0) << locale.formattedDataSize(size_bytes_downloaded())
               << qSetFieldWidth(0) << " of total size "
               << qSetFieldWidth(0) << total
               << qSetFieldWidth(0) << " ("
               << qSetFieldWidth(0) << percent
               << qSetFieldWidth(0) << ")";
    return rtv;
}

QString File::filesize()
{
    QLocale locale;
    return locale.formattedDataSize(size());
}
