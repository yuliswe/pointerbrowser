//
//  Downloads.m
//  Pointer
//
//  Created by Yu Li on 2018-10-24.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Downloads.h"
#import "CppData.h"
#import <objc/runtime.h>

@implementation DownloadsViewController
@synthesize tableview = m_tableview;

//- (void)viewDidAppear
//{
//    NSUInteger nrows = [m_datasource numberOfRowsInTableView:m_tableview];
//    NSRect frame = self.view.frame;
//    frame.size.height = 50 * nrows + 100;
//    self.view.frame = frame;
//}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    QObject::connect(&Global::controller->download_files()->sig, &BaseListModelSignals::signal_tf_model_reset, [=]() {
        [m_tableview performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        [self performSelectorOnMainThread:@selector(resizePopover) withObject:nil waitUntilDone:YES];
    });
    QObject::connect(&Global::controller->downloading_files()->sig, &BaseListModelSignals::signal_tf_rows_inserted, [=](int row, int count)
    {
        for (int i = 0; i < count; i++) {
            File_ f = Global::controller->downloading_files()->get(i);
            id item = [QSharedPointerWrapper wrap:f.staticCast<QObject>()];
            [self performSelectorOnMainThread:@selector(handle_downloading_files_inserted:) withObject:item waitUntilDone:YES];
        }
        [m_tableview performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        [self performSelectorOnMainThread:@selector(resizePopover) withObject:nil waitUntilDone:YES];
    });
    QObject::connect(&Global::controller->download_files()->sig, &BaseListModelSignals::signal_tf_rows_removed, [=]() {
        [m_tableview performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        [self performSelectorOnMainThread:@selector(resizePopover) withObject:nil waitUntilDone:YES];
    });
    QObject::connect(&Global::controller->downloading_files()->sig, &BaseListModelSignals::signal_tf_model_reset, [=]() {
        [m_tableview performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        [self performSelectorOnMainThread:@selector(resizePopover) withObject:nil waitUntilDone:YES];
    });
    QObject::connect(&Global::controller->downloading_files()->sig, &BaseListModelSignals::signal_tf_rows_inserted, [=]() {
        [m_tableview performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        [self performSelectorOnMainThread:@selector(resizePopover) withObject:nil waitUntilDone:YES];
    });
    QObject::connect(&Global::controller->downloading_files()->sig, &BaseListModelSignals::signal_tf_rows_removed, [=]() {
        [m_tableview performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        [self performSelectorOnMainThread:@selector(resizePopover) withObject:nil waitUntilDone:YES];
    });
    return self;
}

- (void)handle_downloading_files_inserted:(QSharedPointerWrapper*)file
{
    File_ f = file.ptr.staticCast<File>();
    NSURLSessionConfiguration* sessionconfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    static WebUIURLSessionDownloadTaskDelegate* sessiondelegate = [[WebUIURLSessionDownloadTaskDelegate alloc] init];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionconfig delegate:sessiondelegate delegateQueue:nil];
    NSURL* url = f->download_url().toNSURL();
    NSURLSessionDownloadTask* task = [session downloadTaskWithURL:url];
    
    [task setFile:f];
    QObject::connect(f.get(), &File::signal_tf_download_resume,[=]() {
        [task performSelectorOnMainThread:@selector(resume) withObject:nil waitUntilDone:YES];
    });
    QObject::connect(f.get(), &File::signal_tf_download_stop,[=]() {
        [task performSelectorOnMainThread:@selector(cancelByProducingResumeData:) withObject:(^(NSData * _Nullable resumeData) {
            // not implemented
        }) waitUntilDone:YES];
    });
    if (f->downloading()) {
        [task resume];
    }
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

- (IBAction)delete:(id)sender
{
    NSIndexSet* rows = self->m_tableview.selectedRowIndexes;
    [rows enumerateIndexesUsingBlock:^(NSUInteger row, BOOL * _Nonnull stop) { 
        int offset = Global::controller->downloading_files()->count();
        if (row < offset) {
            File_ f = Global::controller->downloading_files()->get(row);
            Global::controller->handleFileDownloadStoppedAsync(f);
        } else {
            File_ f = Global::controller->download_files()->get(row - offset);
            NSURL* url = [NSURL fileURLWithPath:f->absoluteFilePath().toNSString()];
            [[NSFileManager defaultManager] trashItemAtURL:url resultingItemURL:nil error:nil];
            Global::controller->download_files()->loadDirectoryContentsAsync(Global::controller->downloads_dirpath());
        }
    }];
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
    int c1 = Global::controller->downloading_files()->count();
    int c2 = Global::controller->download_files()->count();
    return c1 + c2;
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
    if (f->exists()) {
        item.thumbnail = [NSWorkspace.sharedWorkspace iconForFile:f->absoluteFilePath().toNSString()];
    } else {
        item.thumbnail = [NSWorkspace.sharedWorkspace iconForFileType:@""];
    }
    f->replaceConnection(0, QObject::connect(f.get(), &File::propertyChanged, [=]() {
        [self performSelectorOnMainThread:@selector(reloadRow:) withObject:@{@"table":tableView, @"row":[NSNumber numberWithInt:row]} waitUntilDone:YES];
    }));
    return item;
}

- (void)reloadRow:(NSDictionary*)dict
{
    NSTableView * tableview = dict[@"table"];
    int row = [dict[@"row"] intValue];
    [tableview reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:row] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
}
@end

@implementation DownloadTableViewDelegate

@end

@implementation WebUIURLSessionDownloadTaskDelegate
// called when download restarts
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
}
// called when receiving new data during download
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    static qint64 last_time_reported = 0;
    static qint64 accumulated_bytes_since_last_time = 0;
    if (QDateTime::currentSecsSinceEpoch() - last_time_reported >= 1) {
        File_ f = downloadTask.file;
        f->set_size_bytes_addition_async(accumulated_bytes_since_last_time);
        f->set_size_bytes_downloaded_async(totalBytesWritten);
        f->set_size_bytes_expected_async(totalBytesExpectedToWrite);
        f->set_percentage_async((float)totalBytesWritten / (float)totalBytesExpectedToWrite);
        last_time_reported = QDateTime::currentSecsSinceEpoch();
        accumulated_bytes_since_last_time = 0;
    } else {
        accumulated_bytes_since_last_time += bytesWritten;
    }
}
// called when download finishes
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    File_ f = downloadTask.file;
    f->setFile(QString::fromNSString(location.path));
    Global::controller->handleFileDownloadFinishedBlocking(f);
}
@end

@implementation NSURLSessionTask(Pointer)
- (void)setFile:(File_)file {
    id item = [QSharedPointerWrapper wrap:file.staticCast<QObject>()];
    objc_setAssociatedObject(self, @selector(file), item, OBJC_ASSOCIATION_RETAIN);
}
- (File_)file {
    QSharedPointerWrapper* item = objc_getAssociatedObject(self, @selector(file));
    return item.ptr.staticCast<File>();
}
@end

