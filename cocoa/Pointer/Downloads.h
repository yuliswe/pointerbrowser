//
//  Downloads.h
//  Pointer
//
//  Created by Yu Li on 2018-10-24.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <docviewer/docviewer.h>

#ifndef Downloads_h
#define Downloads_h

@interface NSURLSessionTask(Pointer)
- (void)setFile:(File_)file;
- (File_)file;
@end

@interface WebUIURLSessionDownloadTaskDelegate : NSObject<NSURLSessionDownloadDelegate, NSURLSessionTaskDelegate>

@end

@interface DownloadTableItem : NSObject
@property File_ file;
@property NSString* filename;
@property NSURL* filepath;
@property NSString* filesize;
@property NSImage* thumbnail;
@property BOOL requireHttpConscent;
@property NSTableView* tableView;
@end

@interface DownloadTableViewDelegate : NSObject<NSTableViewDelegate>
@end

@interface DownloadTableViewDataSource : NSObject<NSTableViewDataSource>
@end

@interface DownloadsViewController : NSViewController
{
    IBOutlet NSButton* m_show_in_finder_button;
    IBOutlet NSButton* m_move_all_to_finder_button;
    IBOutlet DownloadTableViewDataSource* m_datasource;
    IBOutlet NSPopover* m_popover;
}

@property IBOutlet NSTableView* tableView;
@end

#endif /* Downloads_h */
