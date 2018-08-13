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
@class TabView;

@interface TabViewItem : NSTabViewItem
{
    Webpage_ m_webpage;
    WebUI* m_webview;
    __weak TabView* m_tabview;
}

@property WebUI* webview;
@property Webpage_ webpage;
@property (weak) TabView* tabview;

- (TabViewItem*)initWithWebpage:(Webpage_)webpage tabview:(TabView*)tabview;

@end

@interface TabView : NSTabView
{
    IBOutlet __weak AddressBar* m_address_bar;
}

@property (weak) AddressBar* address_bar;

@end
