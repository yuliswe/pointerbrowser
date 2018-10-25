//
//  Downloads.m
//  Pointer
//
//  Created by Yu Li on 2018-10-24.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Downloads.h"

@implementation DownloadsViewController
@synthesize tableview = m_tableview;

//- (void)viewDidAppear
//{
//    NSUInteger nrows = [m_datasource numberOfRowsInTableView:m_tableview];
//    NSRect frame = self.view.frame;
//    frame.size.height = 50 * nrows + 100;
//    self.view.frame = frame;
//}

- (void)viewWillAppear
{
    [m_tableview reloadData];
}

- (IBAction)moveAllToTrash:(id)sender
{
    
    NSArray* urls = [[NSFileManager defaultManager] URLsForDirectory:NSDownloadsDirectory inDomains:NSUserDomainMask];
    NSURL* downloads_url = urls[0];
    NSError* error;
    NSArray* contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:downloads_url.path error:&error];
    for (NSUInteger i = 0; i < contents.count; i++) {
        NSString* filename = contents[i];
        NSURL* filepath = [downloads_url URLByAppendingPathComponent:filename];
        [NSFileManager.defaultManager trashItemAtURL:filepath resultingItemURL:nil error:nil];
    }
    [m_tableview reloadData];
    NSUInteger nrows = [self->m_datasource numberOfRowsInTableView:self->m_tableview];
    NSSize size = self->m_popover.contentSize;
    size.height = MIN(53 * nrows + 60, 500);
    self->m_popover.contentSize = size;
}

- (IBAction)showInFinder:(id)sender
{
    NSArray* urls = [[NSFileManager defaultManager] URLsForDirectory:NSDownloadsDirectory inDomains:NSUserDomainMask];
    NSURL* downloads_url = urls[0];
    [[NSWorkspace sharedWorkspace] openURL:downloads_url];
}

- (IBAction)done:(id)sender
{
    Global::controller->set_downloads_visible_async(false);
}

@end

@implementation DownloadTableItem
@synthesize thumbnail = m_thumbnail;
@synthesize filename = m_filename;
@synthesize filepath = m_filepath;
@synthesize filesize = m_filesize;
@end

@implementation DownloadTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    NSArray* urls = [[NSFileManager defaultManager] URLsForDirectory:NSDownloadsDirectory inDomains:NSUserDomainMask];
    NSURL* download_dir_url = urls[0];
    NSError* error;
    NSArray* contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:download_dir_url.path error:&error];
    return contents.count;
}

- (id)tableView:(NSTableView *)tableView
objectValueForTableColumn:(NSTableColumn *)tableColumn
            row:(NSInteger)row
{
    DownloadTableItem* item = [[DownloadTableItem alloc] init];
    NSArray* urls = [[NSFileManager defaultManager] URLsForDirectory:NSDownloadsDirectory inDomains:NSUserDomainMask];
    NSURL* downloads_url = urls[0];
    NSError* error;
    NSArray* contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:downloads_url.path error:&error];
    NSString* filename = contents[row];
    NSURL* filepath = [downloads_url URLByAppendingPathComponent:filename];
    NSDictionary *attribs = [[NSFileManager defaultManager] attributesOfItemAtPath:filepath.path error:&error];
    item.filename = filename;
    item.filepath = filepath;
    item.filesize = [NSByteCountFormatter stringFromByteCount:[attribs fileSize] countStyle:NSByteCountFormatterCountStyleFile];
    item.thumbnail = [NSWorkspace.sharedWorkspace iconForFile:filepath.path];
    return item;
}
@end

@implementation DownloadTableViewDelegate

@end
