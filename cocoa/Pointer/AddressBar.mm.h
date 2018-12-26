//
//  AddressBar.h
//  Pointer
//
//  Created by Yu Li on 2018-08-12.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Extension/Extension.h"

@interface GoBackButton : NSButton
{}
@end

@interface GoForwardButton : NSButton
{}
@end

@interface RefreshButton : NSButton
- (void)showRefresh;
- (void)showCancel;
- (void)handleClicked;
@end

@interface TrustButton : NSButton
- (void)showTrusted;
- (void)showUntrusted;
- (void)handleClicked;
@end

@class AddressBar;

@interface AddressBarSurface : NSButton
{
    AddressBar* m_bar;
}
- (instancetype)initWithAddressBar:(AddressBar*)bar;

@property RefreshButton* refresh_button;
@property TrustButton* trust_button;
@end

@interface ProgressCALayer : CALayer
{
    float m_progress_opacity;
    float m_progress;
    float m_target_progress;
}
- (instancetype)initWithAddressBar:(AddressBar*)bar;
@property (nonatomic) float progress_opacity;
@property (nonatomic) float progress;
@property float target_progress;
@end

@interface AddressBar : NSTextField
{
    NSString* m_uri;
    NSString* m_title;
    ProgressCALayer* m_progress_layer;
}
@property AddressBarSurface* surface;
@property ProgressCALayer* progress_layer;
@property NSString* url;
@property NSString* title;
@property bool focus;
- (IBAction)getFocus;
- (void)loseFocus;
- (void)commit;
@end

@interface AddressBarCell : NSTextFieldCell
{
    IBOutlet AddressBar* m_address_bar;
}
@end

