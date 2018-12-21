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
    {
        RefreshButton* refreshButton = [[RefreshButton alloc] init];
        self.refresh_button = refreshButton;
        [self addSubview:refreshButton];
        [NSLayoutConstraint
         constraintWithItem:refreshButton
         attribute:NSLayoutAttributeTrailing
         relatedBy:NSLayoutRelationEqual
         toItem:self
         attribute:NSLayoutAttributeTrailing
         multiplier:1
         constant:-4].active = YES;
        [NSLayoutConstraint
         constraintWithItem:refreshButton
         attribute:NSLayoutAttributeCenterY
         relatedBy:NSLayoutRelationEqual
         toItem:self
         attribute:NSLayoutAttributeCenterY
         multiplier:1
         constant:0].active = YES;
        [NSLayoutConstraint
         constraintWithItem:refreshButton
         attribute:NSLayoutAttributeWidth
         relatedBy:NSLayoutRelationEqual
         toItem:nil
         attribute:NSLayoutAttributeNotAnAttribute
         multiplier:1
         constant:23].active = YES;
        refreshButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    {
        TrustButton* trustButton = [[TrustButton alloc] init];
        self.trust_button = trustButton;
        [self addSubview:trustButton];
        [NSLayoutConstraint
         constraintWithItem:trustButton
         attribute:NSLayoutAttributeLeading
         relatedBy:NSLayoutRelationEqual
         toItem:self
         attribute:NSLayoutAttributeLeading
         multiplier:1
         constant:10].active = YES;
        [NSLayoutConstraint
         constraintWithItem:trustButton
         attribute:NSLayoutAttributeCenterY
         relatedBy:NSLayoutRelationEqual
         toItem:self
         attribute:NSLayoutAttributeCenterY
         multiplier:1
         constant:0].active = YES;
        [NSLayoutConstraint
         constraintWithItem:trustButton
         attribute:NSLayoutAttributeWidth
         relatedBy:NSLayoutRelationEqual
         toItem:nil
         attribute:NSLayoutAttributeNotAnAttribute
         multiplier:1
         constant:56].active = YES;
        [NSLayoutConstraint
         constraintWithItem:trustButton
         attribute:NSLayoutAttributeHeight
         relatedBy:NSLayoutRelationEqual
         toItem:nil
         attribute:NSLayoutAttributeNotAnAttribute
         multiplier:1
         constant:20].active = YES;
        trustButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
}

- (void)hideRefreshButton
{
    self.refresh_button.hidden = YES;
}

- (void)showRefreshButton
{
    self.refresh_button.hidden = NO;
}

- (void)hideTrustButton
{
    self.trust_button.hidden = YES;
}

- (void)showTrustButton
{
    self.trust_button.hidden = NO;
}
@end

@implementation TrustButton
- (instancetype)init
{
    self = [super init];
    [self showTrusted];
    self.bezelStyle = NSBezelStyleRounded;
    self.bordered = NO;
    self.buttonType = NSButtonTypeMomentaryPushIn;
    self.imageScaling = NSImageScaleProportionallyDown;
    self.imagePosition = NSImageLeft;
    self.font = [NSFont systemFontOfSize:NSFont.smallSystemFontSize];
    self.action = @selector(handleClicked);
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    NSString *osxMode = [[NSUserDefaults standardUserDefaults] stringForKey:@"AppleInterfaceStyle"];
    NSColor* color;
    if ([osxMode isEqualToString:@"Dark"]) {
        color = [NSColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:1];
    } else {
        color = [NSColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1];
    }
    [color set];
    NSRectFill(NSMakeRect(self.bounds.size.width - 1, 5, 1, self.bounds.size.height - 9));
}

- (void)showTrusted
{
    NSImage* img = [NSImage namedImageWithTintColor:NSImageNameLockLockedTemplate color:NSColor.systemGrayColor];
    NSSize size = img.size;
    size.height = 11;
    size.width = 9;
    img.size = size;
    self.image = img;
    NSMutableAttributedString* astr = [[NSMutableAttributedString alloc] initWithString:@"Secure"];
    NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
    [style setParagraphStyle:NSParagraphStyle.defaultParagraphStyle];
    style.alignment = NSTextAlignmentLeft;
    style.firstLineHeadIndent = 2;
    [astr addAttributes:@{NSForegroundColorAttributeName:NSColor.systemGrayColor,
                          NSParagraphStyleAttributeName:style}
                  range:NSMakeRange(0,astr.length)];
    self.attributedTitle = astr;
}
- (void)showUntrusted
{
    NSImage* img = [NSImage namedImageWithTintColor:NSImageNameLockUnlockedTemplate color:NSColor.systemRedColor];
    NSSize size = img.size;
    size.height = 11;
    size.width = 9;
    img.size = size;
    self.image = img;
    NSMutableAttributedString* astr = [[NSMutableAttributedString alloc] initWithString:@"Unsafe"];
    NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
    [style setParagraphStyle:NSParagraphStyle.defaultParagraphStyle];
    style.alignment = NSTextAlignmentLeft;
    style.firstLineHeadIndent = 2;
    [astr addAttributes:@{NSForegroundColorAttributeName:NSColor.systemRedColor,
                          NSParagraphStyleAttributeName:style}
                  range:NSMakeRange(0,astr.length)];
    self.attributedTitle = astr;
}
- (void)handleClicked
{
}
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
    self.surface = [[AddressBarSurface alloc] initWithAddressBar:self];
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
    
    QObject::connect(Global::controller,
                     &Controller::current_tab_webpage_is_blank_changed,
                     [=](bool blank)
    {
        if (blank) {
            [self.surface performSelectorOnMainThread:@selector(hideRefreshButton) withObject:nil waitUntilDone:YES];
            [self.surface performSelectorOnMainThread:@selector(hideTrustButton) withObject:nil waitUntilDone:YES];
        } else {
            [self.surface performSelectorOnMainThread:@selector(showRefreshButton) withObject:nil waitUntilDone:YES];
            [self.surface performSelectorOnMainThread:@selector(showTrustButton) withObject:nil waitUntilDone:YES];
        }
    });
    
    QObject::connect(Global::controller,
                     &Controller::current_tab_webpage_is_secure_changed,
                     [=](bool secure)
                     {
                         if (secure) {
                             [self.surface.trust_button performSelectorOnMainThread:@selector(showTrusted) withObject:nil waitUntilDone:YES];
                         } else {
                             [self.surface.trust_button performSelectorOnMainThread:@selector(showUntrusted) withObject:nil waitUntilDone:YES];
                         }
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

- (void)updateTitle:(NSString*)title
{
    self.title = title;
    BOOL isEditing = self.currentEditor != nil;
    if (! isEditing) {
        self.stringValue = self.title;
    }
}

- (BOOL)wantsLayer { return YES; }
- (BOOL)wantsUpdateLayer { return YES; }

- (void)resetCursorRects {
    [self addCursorRect:[self bounds] cursor:[NSCursor arrowCursor]];
}

- (void)getFocus
{
    [self.window makeFirstResponder:self];
    self.stringValue = Global::controller->address_bar_url().full().toNSString();
}

- (void)loseFocus
{
    self.url = self.stringValue;
    self.stringValue = Global::controller->address_bar_title().toNSString();
    if (self.window.firstResponder == self.currentEditor) {
        [self.window makeFirstResponder:nil];
    }
}

- (void)textDidEndEditing:(NSNotification *)notification
{
    [self loseFocus];
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
    NSRect rectInset = NSMakeRect(rect.origin.x + 60.f, rect.origin.y, rect.size.width - 80.0f, rect.size.height);
    return [super drawingRectForBounds:rectInset];
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
    self.imageScaling = NSImageScaleProportionallyDown;
    self.action = @selector(handleClicked);
    return self;
}

- (void)showCancel
{
    self.image = [NSImage namedImageWithTintColor:NSImageNameStopProgressTemplate color:NSColor.darkGrayColor];
}

- (void)showRefresh
{
    self.image = [NSImage namedImageWithTintColor:NSImageNameRefreshTemplate color:NSColor.darkGrayColor];
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
