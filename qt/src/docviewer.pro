QT += sql
QT -= gui
CONFIG += c++17 qt thread
QTPLUGIN += qsqlite

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
    stringutils.hpp \
    usersettings.hpp

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
    stringutils.cpp \
    usersettings.cpp

RESOURCES += \
    db.qrc \
    defaults.qrc \
    others.qrc

macx {
    LIBS += -L/usr/local/lib -L../deps -lqsqlite -lgumbo_query -framework Foundation
    INCLUDEPATH += /usr/local/include
    HEADERS += mac_crawler.hpp
    SOURCES += mac_crawler.mm
    CONFIG(debug, debug|release|profile) {
        TARGET = main
        SOURCES += mac_main.cpp
    }
    CONFIG(release, debug|release) {
        VER_MAJ = 1
        VER_MIN = 2
        VER_PAT = 1
        CONFIG += plugin # prevent qmake from adding version numbers to .dylib
        QMAKE_SONAME_PREFIX = @rpath # set install_name for library
        include.files = $${HEADERS} # include headers ...
        include.path = /usr/local/include/$${TARGET} # install headers to ...
        target.path = /usr/local/lib/ # install lib to ...
        INSTALLS += target include
        QMAKE_FRAMEWORK_VERSION = A
        FRAMEWORK_HEADERS.version = Versions
        FRAMEWORK_HEADERS.files = $${HEADERS}
        FRAMEWORK_HEADERS.path = Headers
        QMAKE_BUNDLE_DATA += FRAMEWORK_HEADERS
        DEFINES += QT_NO_DEBUG_OUTPUT
        TEMPLATE = lib
        QMAKE_LFLAGS_PLUGIN += -install_name @rpath/lib$${TARGET}.dylib
        QMAKE_STRIP = echo # prevent stripping the changes codesign
        QMAKE_POST_LINK += \
            install_name_tool -id @rpath/lib$${TARGET}.dylib lib$${TARGET}.dylib && \
            install_name_tool \
                -change @rpath/QtCore.framework/Versions/5/QtCore @rpath/QtCore.framework/Versions/A/QtCore \
                -change @rpath/QtSql.framework/Versions/5/QtSql @rpath/QtSql.framework/Versions/A/QtSql \
                lib$${TARGET}.dylib && \
            codesign lib$${TARGET}.dylib -s 6JKDPRT88Y
    }
}

win32 {
    win32-msvc {
    }
}

