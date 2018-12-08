QT += sql
QT -= gui
CONFIG += c++14

DEFINES += QT_DEPRECATED_WARNINGS

HEADERS += \
    global.hpp \
    filemanager.hpp \
    keymaps.hpp \
    macros.hpp \
    searchdb.hpp \
    tabsmodel.hpp \
    webpage.hpp \
    crawler.hpp \
    docviewer.h \
    url.hpp \
    offline_crawler.hpp \
    controller.hpp \
    logging.hpp \
    file.hpp \
    filelistmodel.hpp \
    baselistmodel.hpp \
    tags.hpp \
    stringutils.hpp

DISTFILES += \
    defaults/dbgen.txt \
    resetTables.sqlite3 \
    db/exit.sqlite3 \
    crawler.hpp \
    defaults/bookmarks.json

SOURCES += \
    tabsmodel.cpp \
    webpage.cpp \
    searchdb.cpp \
    keymaps.cpp \
    global.cpp \
    crawler.cpp \
    filemanager.cpp \
    url.cpp \
    offline_crawler.cpp \
    controller.cpp \
    logging.cpp \
    file.cpp \
    filelistmodel.cpp \
    baselistmodel.cpp \
    tags.cpp \
    stringutils.cpp

RESOURCES += \
    db.qrc \
    defaults.qrc \
    others.qrc

macx {
    macx-clang {
        FRAMEWORK_HEADERS.version = Versions
        FRAMEWORK_HEADERS.files = $${HEADERS}
        FRAMEWORK_HEADERS.path = Headers
        QMAKE_BUNDLE_DATA += FRAMEWORK_HEADERS
        LIBS += -L/usr/local/lib/ -lgumbo_query -framework Foundation
        INCLUDEPATH += /usr/local/include/
        HEADERS += mac_crawler.hpp
        SOURCES += mac_crawler.mm
        CONFIG(debug, debug|release|profile) {
            TARGET = main
            SOURCES += mac_main.cpp
        }
        CONFIG(release, debug|release) {
#            DEFINES += QT_NO_DEBUG_OUTPUT
            TEMPLATE = lib
            CONFIG += lib_bundle
        }
    }
}

win32 {
    win32-msvc {
    }
}

