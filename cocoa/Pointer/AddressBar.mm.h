//
//  AddressBar.h
//  Pointer
//
//  Created by Yu Li on 2018-08-12.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import "Subclass/PTextField.h"

@interface GoBackButton : NSButton
{}
@end

@interface GoForwardButton : NSButton
{}
@end

@interface RefreshButton : NSButton
{}
- (void)showRefresh;
- (void)showCancel;
- (void)handleClicked;
@end

@class AddressBar;

@interface AddressBarSurface : NSButton
{
    AddressBar* m_bar;
    RefreshButton* m_refresh_button;
}
- (instancetype)initWithAddressBar:(AddressBar*)bar;

@property RefreshButton* refresh_button;

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
    AddressBarSurface* m_surface;
}
@property AddressBarSurface* surface;
@property ProgressCALayer* progress_layer;
@property NSString* url;
@property NSString* title;
@property bool focus;
- (IBAction)getFocus;
- (void)loseFocus;
@end

@interface AddressBarCell : NSTextFieldCell
{
    IBOutlet AddressBar* m_address_bar;
}
@end

