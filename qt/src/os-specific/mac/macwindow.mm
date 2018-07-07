#include "macwindow.h"
#include <QGuiApplication>
#include <AppKit/AppKit.h>

MacWindow::MacWindow(QWindow* target)
    : window(target)
{

}

void MacWindow::zoom(QWindow* target)
{
    NSView* view = reinterpret_cast<NSView*>(target->winId());
    [view.window zoom:view];
}

void MacWindow::initMacWindows()
{
    QWindowList windows = QGuiApplication::topLevelWindows();
    for (QWindow* target : windows) {
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
}
