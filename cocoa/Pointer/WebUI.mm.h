//
//  WebUI.h
//  Pointer
//
//  Created by Yu Li on 2018-08-01.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import <WebKit/WebKit.h>
#include <docviewer/docviewer.h>
#include "TabView.mm.h"

@class TabViewItem;

@interface WebUI : WKWebView<WKNavigationDelegate>
{
    Webpage_ m_webpage;
}

@property Webpage_ webpage;

- (instancetype)initWithTabItem:(TabViewItem*)tabItem;
- (void)loadUri:(NSString*)url;
- (void)dealloc;

- (NSInteger)highlightAllOccurencesOfString:(NSString*)str;
- (void)removeAllHighlights;

@end

@interface WebUIDelegate : NSObject<WKUIDelegate>
{
    
}
@end
