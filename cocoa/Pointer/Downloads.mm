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

- (void)viewDidLoad
{
    QObject::connect(&Global::controller->download_files()->sig, &BaseListModelSignals::signal_tf_model_reset, [=]() {
        [m_tableview performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(resizePopover) withObject:nil waitUntilDone:NO];
    });
    QObject::connect(&Global::controller->download_files()->sig, &BaseListModelSignals::signal_tf_rows_inserted, [=]() {
        [m_tableview performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(resizePopover) withObject:nil waitUntilDone:NO];
    });
    QObject::connect(&Global::controller->download_files()->sig, &BaseListModelSignals::signal_tf_rows_removed, [=]() {
        [m_tableview performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(resizePopover) withObject:nil waitUntilDone:NO];
    });
    QObject::connect(&Global::controller->downloading_files()->sig, &BaseListModelSignals::signal_tf_model_reset, [=]() {
        [m_tableview performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(resizePopover) withObject:nil waitUntilDone:NO];
    });
    QObject::connect(&Global::controller->downloading_files()->sig, &BaseListModelSignals::signal_tf_rows_inserted, [=]() {
        [m_tableview performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(resizePopover) withObject:nil waitUntilDone:NO];
    });
    QObject::connect(&Global::controller->downloading_files()->sig, &BaseListModelSignals::signal_tf_rows_removed, [=]() {
        [m_tableview performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(resizePopover) withObject:nil waitUntilDone:NO];
    });
}

- (void)resizePopover
{
    int nrows = [self->m_datasource numberOfRowsInTableView:self->m_tableview];
    NSSize size = self->m_popover.contentSize;
    size.height = MIN(53 * nrows + 60, 500);
    self->m_popover.contentSize = size;
}

- (void)viewWillAppear
{
    [self resizePopover];
    [m_tableview reloadData];
}

- (IBAction)moveAllToTrash:(id)sender
{
    for (int i = 0; i < Global::controller->download_files()->count(); i++) {
        File_ f = Global::controller->download_files()->get(i);
        NSURL* url = [NSURL fileURLWithPath:f->absoluteFilePath().toNSString()];
        [NSFileManager.defaultManager trashItemAtURL:url resultingItemURL:nil error:nil];
    }
    Global::controller->download_files()->loadDirectoryContentsAsync(Global::controller->downloads_dirpath());
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
    return Global::controller->downloading_files()->count() + Global::controller->download_files()->count();
}

- (id)tableView:(NSTableView *)tableView
objectValueForTableColumn:(NSTableColumn *)tableColumn
            row:(NSInteger)row
{
    DownloadTableItem* item = [[DownloadTableItem alloc] init];
    File_ f;
    int offset = Global::controller->downloading_files()->count();
    if (row < offset) {
        f = Global::controller->downloading_files()->get(row);
    } else {
        f = Global::controller->download_files()->get(row - offset);
    }
    
    item.filepath = [NSURL URLWithString:f->absoluteFilePath().toNSString()];
    if (f->downloading()) {
        item.filesize = f->downloadProgress().toNSString();
        item.filename = f->save_as_filename().toNSString();
    } else {
        item.filesize = f->filesize().toNSString();
        item.filename = f->fileName().toNSString();
    }
    item.thumbnail = [NSWorkspace.sharedWorkspace iconForFile:f->absoluteFilePath().toNSString()];
    QObject::connect(f.get(), &File::dataChanged, [=]() {
        [tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    });
    return item;
}
@end

@implementation DownloadTableViewDelegate

@end
