//
//  TabView.h
//  Pointer
//
//  Created by Yu Li on 2018-08-11.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <docviewer/tabsmodel.hpp>
#include "AddressBar.mm.h"

@class WebUI;
@class TabViewController;

@interface TabViewController : NSTabViewController
{
    IBOutlet AddressBar* m_address_bar;
    IBOutlet NSWindowController* m_window_controller;
    IBOutlet NSView* m_parent_view;
}

@property AddressBar* address_bar;
- (void)print;
- (void)downloadAsWebArchive;
- (void)downloadAsPDF;
@end
