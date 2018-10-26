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

@interface WebUIURLSessionDownloadTaskDelegate : NSObject<NSURLSessionDownloadDelegate>

@end

@interface WebUI : WKWebView<WKNavigationDelegate>
{
    Webpage_ m_webpage;
}

@property Webpage_ webpage;

- (instancetype)initWithTabItem:(TabViewItem*)tabItem;
- (void)loadUri:(NSString*)url;

- (NSInteger)highlightAllOccurencesOfString:(NSString*)str;
- (void)removeAllHighlights;

@end

@interface WebUIDelegate : NSObject<WKUIDelegate>
{
    
}
@end

@interface NSURLSessionTask(Pointer)
- (void)setFile:(File_)file;
- (File_)file;
@end
