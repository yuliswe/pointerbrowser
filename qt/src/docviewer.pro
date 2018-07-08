TARGET = Dereference

QT += qml quick sql svg concurrent
CONFIG += c++14

# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

HEADERS += \
    tabsmodel.h \
    filemanager.h \
    qmlregister.h \
    webpage.h \
    palette.h \
    eventfilter.h \
    searchdb.h \
    keymaps.h

DISTFILES += \
    defaults/dbgen.txt \
    resetTables.sqlite3 \
    db/exit.sqlite3

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
    main.cpp \
    tabsmodel.cpp \
    filemanager.cpp \
    qmlregister.cpp \
    webpage.cpp \
    palette.cpp \
    eventfilter.cpp \
    searchdb.cpp \
    keymaps.cpp


RESOURCES += qml.qrc db.qrc js.qrc controls.qrc defaults.qrc

macx {
    ICON += chrome.icns
    macx-clang {
        QT += webengine
        RESOURCES += os-specific/mac.qrc
        SOURCES += os-specific/mac/macwindow.mm
        HEADERS += os-specific/mac/macwindow.h
        QMAKE_LFLAGS += -F/System/Library/Frameworks/
        LIBS += -framework AppKit -framework Quartz
    }
}


win32 {
    RC_ICONS += chrome.ico
    win32-msvc {
        QT += webengine
        RESOURCES += os-specific/win.qrc
        LIBS += -lUser32
    }
}


# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target
