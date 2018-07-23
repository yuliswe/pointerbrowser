#include <QGuiApplication>
#include <QQmlEngine>
#import <AppKit/AppKit.h>
#include <QThread>
#include <QTime>
#include <QtConcurrent>
#import "macwindow.h"

@interface QNSWindowDelegate : NSObject <NSWindowDelegate>
                               @property(copy) void (^willZoomTo)(NSRect);
@end

//MacWindow::MacWindow(QWindow* target)
//    : window(target)
//{
//}

void MacWindow::zoom(QWindow* window)
{
    NSView* view = reinterpret_cast<NSView*>(window->winId());
    for (QQuickItem* target : webUIs) {
    }
    [view.window zoom:view];
}

void MacWindow::hotfixWebUIResize(QQuickItem* target)
{
    qInfo() << "MacWindow::hotfixWebUIResize" << target;
    webUIs << target;
    QWindow* parent = target->window();
    if (! parent) { return; }
    //    NSView* view = reinterpret_cast<NSView*>(parent->winId());
    //    NSWindow* win = view.window;
    //    QNSWindowDelegate* delegate = reinterpret_cast<QNSWindowDelegate*>(win.delegate);
    //    delegate.willZoomTo = (^void (NSRect frame) {
    //                               qDebug() << "will zoom!!!!!!!!!!!!!!!!!!!" << webUIs
    //                               << frame.size.height <<  frame.size.width;
    //                               target->setWidth(10000);
    //                               target->setHeight(frame.size.height);
    //                               target->update();
    //                               QCoreApplication::flush();
    //                               [win zoom:view];
    //                           });
}

void MacWindow::hotfixNSVisualEffect(QWindow* item)
{
    qInfo() << "MacWindow::hotfixNSVisualEffect" << item;
    windows << item;
}

void MacWindow::initMacWindows()
{
    QWindowList windows = QGuiApplication::topLevelWindows();
    for (QWindow* target : windows) {
        Q_ASSERT(target);
        NSView* view = reinterpret_cast<NSView*>(target->winId());
        NSVisualEffectView* effect = [[NSVisualEffectView alloc] init];
        NSWindow* win = view.window;
        [win setContentView:effect];
        [effect addSubview:view];
        [win makeFirstResponder:view];
        win.styleMask |= NSWindowStyleMaskFullSizeContentView;
        win.titlebarAppearsTransparent = true;
        win.titleVisibility = NSWindowTitleHidden;
        //        win.movableByWindowBackground = true;
        [view.topAnchor constraintEqualToAnchor:effect.topAnchor].active = true;
        [view.leftAnchor constraintEqualToAnchor:effect.leftAnchor].active = true;
        [view.rightAnchor constraintEqualToAnchor:effect.rightAnchor].active = true;
        [view.bottomAnchor constraintEqualToAnchor:effect.bottomAnchor].active = true;
        view.translatesAutoresizingMaskIntoConstraints = false;
    }
    for (QQuickItem* target : webUIs) {
        hotfixWebUIResize(target);
    }
}

QList<QWindow*> MacWindow::windows = QList<QWindow*>();
QList<QQuickItem*> MacWindow::webUIs = QList<QQuickItem*>();
