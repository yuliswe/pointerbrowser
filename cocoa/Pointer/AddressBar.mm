//
//  AddressBar.m
//  Pointer
//
//  Created by Yu Li on 2018-08-12.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import "AddressBar.mm.h"
#import <QuartzCore/QuartzCore.h>
#include <docviewer/controller.hpp>
#include <docviewer/global.hpp>
#include <QtCore/QObject>
#import "KeyCode.h"

@implementation AddressBarSurface

@synthesize refresh_button = m_refresh_button;

- (instancetype)initWithAddressBar:(AddressBar*)bar
{
    self = [super initWithFrame:bar.bounds];
    self->m_bar = bar;
    self.autoresizingMask = NSViewHeightSizable | NSViewWidthSizable;
    bar.autoresizesSubviews = YES;
    [self addButtons];
    [bar addSubview:self];
    return self;
}

- (void)mouseDown:(NSEvent *)event
{
    if (event.clickCount == 1) {
        [m_bar getFocus];
    }
    [super mouseDown:event];
}

- (void)drawRect:(NSRect)dirtyRect
{
    // draw nothing
}

- (void)addButtons
{
    RefreshButton* refresh = [[RefreshButton alloc] init];
    
    NSRect rect = self.bounds;
    rect.size.width = 25;
    [refresh setFrame:rect];
    
    [self addSubview:refresh];
    
    [NSLayoutConstraint
     constraintWithItem:refresh
     attribute:NSLayoutAttributeTrailing
     relatedBy:NSLayoutRelationEqual
     toItem:self
     attribute:NSLayoutAttributeTrailing
     multiplier:1
     constant:-1].active = YES;
    
    [NSLayoutConstraint
     constraintWithItem:refresh
     attribute:NSLayoutAttributeCenterY
     relatedBy:NSLayoutRelationEqual
     toItem:self
     attribute:NSLayoutAttributeCenterY
     multiplier:1
     constant:-1].active = YES;
    
    refresh.translatesAutoresizingMaskIntoConstraints = NO;
    
    self->m_refresh_button = refresh;
    
    QObject::connect(Global::controller, &Controller::current_tab_webpage_changed, [=]() {
        if (Global::controller->current_tab_state() != Controller::TabStateEmpty) {
            [self performSelectorOnMainThread:@selector(showButtons) withObject:nil waitUntilDone:YES];
        } else {
            [self performSelectorOnMainThread:@selector(hideButtons) withObject:nil waitUntilDone:YES];
        }
    });
    
    if (Global::controller->current_tab_state() == Controller::TabStateEmpty)
    {
        [self hideButtons];
    }
}

- (void)hideButtons
{
    self.refresh_button.hidden = YES;
}

- (void)showButtons
{
    self.refresh_button.hidden = NO;
}

//- (BOOL)performKeyEquivalent:(NSEvent *)event
//{
//    if ((event.modifierFlags & NSEventModifierFlagCommand)
//        && (event.keyCode == kVK_ANSI_R))
//    {
//        [self.refresh_button refresh];
//        return YES;
//    }
//    if ((event.modifierFlags & NSEventModifierFlagCommand)
//        && (event.keyCode == kVK_ANSI_E))
//    {
//        [m_bar getFocus];
//        return YES;
//    }
//    return NO;
//}

@end

@implementation ProgressCALayer

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    if ([key isEqualToString:@"progress_opacity"]) {
        return YES;
    }
    if ([key isEqualToString:@"progress"]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

- (id<CAAction>)actionForKey:(NSString *)key
{
    if ([key isEqualToString:@"progress_opacity"])
    {
        CABasicAnimation* fade_animation = [CABasicAnimation animationWithKeyPath:@"progress_opacity"];
        fade_animation.fromValue = [NSNumber numberWithFloat:self.presentationLayer.progress_opacity];
        fade_animation.duration = 1;
        return fade_animation;
    }
    if ([key isEqualToString:@"progress"] && (self.target_progress > self.progress))
    {
        CABasicAnimation* progress_animation = [CABasicAnimation animationWithKeyPath:@"progress"];
        progress_animation.fromValue = [NSNumber numberWithFloat:self.progress];
        return progress_animation;
    }
    return [super actionForKey:key];
}

- (void)drawInContext:(CGContextRef)ctx
{
    [super drawInContext:ctx];
    float min = self.presentationLayer.progress > self.progress ? self.progress : self.presentationLayer.progress;
    CGRect progressRect = self.bounds;
    progressRect.origin.y = progressRect.size.height - 2;
    progressRect.size.height = 2;
    progressRect.size.width *= min;
    CGContextSetRGBFillColor(ctx, 69./256, 145./256, 249./256, self.presentationLayer.progress_opacity);
    CGContextFillRect(ctx, progressRect);
}

@dynamic progress_opacity;
@dynamic progress;
@synthesize target_progress = m_target_progress;

- (instancetype)initWithAddressBar:(AddressBar*)bar
{
    self = [super init];
    self.progress_opacity = 1;
    self.progress = 0;
    NSRect frame = bar.bounds;
    // make sure not to draw on boundary
    frame.size.height -= 2;
    frame.size.width -= 2;
    frame.origin.y = 1;
    frame.origin.x = 1;
    self.frame = frame;
    self.masksToBounds = YES;
    self.cornerRadius = 4;
    self.autoresizingMask = NSViewHeightSizable | NSViewWidthSizable;
    [bar.layer addSublayer:self];
    return self;
}

- (void)setTargetProgress:(float)progress
{
    self->m_target_progress = progress;
    self.progress = progress;
}

@end

@implementation AddressBar

@synthesize url = m_uri;
@synthesize title = m_title;
@synthesize focus = m_focus;
@synthesize progress_layer = m_progress_layer;
@synthesize surface = m_surface;

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    self.wantsLayer = YES;
    self.progress_layer = [[ProgressCALayer alloc] initWithAddressBar:self];
    [self.progress_layer setNeedsDisplay];
    [self connect];
    self.title = Global::controller->address_bar_title().toNSString();
    self.url = Global::controller->address_bar_url().full().toNSString();
    self.stringValue = self.title;
    self->m_surface = [[AddressBarSurface alloc] initWithAddressBar:self];
    return self;
}

- (void)connect
{
    QObject::connect(Global::controller, &Controller::address_bar_load_progress_changed, [=](float value) {
        [self performSelectorOnMainThread:@selector(updateProgress:) withObject:[NSNumber numberWithFloat:value] waitUntilDone:YES];
    });

    QObject::connect(Global::controller, &Controller::address_bar_title_changed, [=](const QString& title) {
        [self performSelectorOnMainThread:@selector(updateTitle:) withObject:title.toNSString() waitUntilDone:YES];
    });
    
}

- (void)updateProgress:(NSNumber*)num
{
    [self.progress_layer setTargetProgress:num.floatValue];
    if (num.floatValue == 1) {
        self.progress_layer.progress_opacity = 0;
        [self.surface.refresh_button showRefresh];
    } else if (self.progress_layer.progress_opacity == 0) {
        self.progress_layer.progress_opacity = 1;
        [self.surface.refresh_button showCancel];
    }
}

//- (void)updateUrl:(NSString*)url
//{
//    self.url = url;
//    if (self.focus) {
//        self.stringValue = self.url;
//    }
//}

- (void)updateTitle:(NSString*)title
{
    self.title = title;
    BOOL isEditing = self.currentEditor != nil;
    if (! isEditing) {
        self.stringValue = self.title;
    }
}

- (BOOL)wantsLayer { return YES; }
- (BOOL)wantsUpdateLayer { return NO; }

- (void)resetCursorRects {
    [self addCursorRect:[self bounds] cursor:[NSCursor arrowCursor]];
}

- (void)getFocus
{
//    m_surface.hidden = NO;
    [self.window makeFirstResponder:self];
    self.stringValue = Global::controller->address_bar_url().full().toNSString();
//    self.focus = true;
}

- (void)loseFocus
{
//    m_surface.hidden = NO;
//    self.focus = false;
    self.url = self.stringValue;
    self.stringValue = Global::controller->address_bar_title().toNSString();
    [self.window makeFirstResponder:self.window];
}

- (void)textDidEndEditing:(NSNotification *)notification
{
    [self loseFocus];
//    [self resignFirstResponder];
    [super textDidEndEditing:notification];
}

- (void)keyUp:(NSEvent *)event
{
    int code = event.keyCode;
    if (event.keyCode == kVK_Return) {
        NSString* u = self.url;
        Global::controller->currentTabWebpageGoAsync(QString::fromNSString(u));
        [self loseFocus];
    }
    [super keyUp:event];
}

@end

@implementation AddressBarCell
- (NSRect)drawingRectForBounds:(NSRect)rect {
    
    // This gives pretty generous margins, suitable for a large font size.
    // If you're using the default font size, it would probably be better to cut the inset values in half.
    // You could also propertize a CGFloat from which to derive the inset values, and set it per the font size used at any given time.
//    if (! self->m_address_bar.focus) {
        NSRect rectInset = NSMakeRect(rect.origin.x, rect.origin.y, rect.size.width - 20.0f, rect.size.height);
        return [super drawingRectForBounds:rectInset];
//    }
//    return [super drawingRectForBounds:rect];
}
@end


@implementation RefreshButton
- (instancetype)init
{
    self = [super init];
    [self showRefresh];
    self.bordered = YES;
    self.bezelStyle = NSBezelStyleRounded;
    self.transparent = YES;
    self.buttonType = NSButtonTypeMomentaryPushIn;
    self.action = @selector(handleClicked);
    return self;
}

- (void)showCancel
{
    self.image = [NSImage imageNamed:NSImageNameStopProgressTemplate];
}

- (void)showRefresh
{
    self.image = [NSImage imageNamed:NSImageNameRefreshTemplate];
}

- (void)mouseDown:(NSEvent *)event
{
    [self handleClicked];
    [super mouseDown:event];
}

- (IBAction)handleClicked
{
    Global::controller->currentTabWebpageRefreshAsync();
}
@end


@implementation GoBackButton : NSButton
{}
- (void)mouseDown:(NSEvent *)event
{
    [super mouseDown:event];
    Global::controller->currentTabWebpageBackAsync();
}

- (NSImage *)image
{
    return [NSImage imageNamed:NSImageNameGoBackTemplate];
}
@end

@implementation GoForwardButton : NSButton
{}
- (void)mouseDown:(NSEvent *)event
{
    [super mouseDown:event];
    Global::controller->currentTabWebpageForwardAsync();
}

- (NSImage *)image
{
    return [NSImage imageNamed:NSImageNameGoForwardTemplate];
}
@end
