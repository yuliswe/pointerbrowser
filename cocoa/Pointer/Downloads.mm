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

@implementation DownloadTable

- (instancetype)initWithCoder:(NSCoder *)coder
{
    Global::controller->download_files()->lock_for_read();
    Global::controller->downloading_files()->lock_for_read();
    DownloadTable* rt = [super initWithCoder:coder];
    Global::controller->downloading_files()->unlock_for_read();
    Global::controller->download_files()->unlock_for_read();
    return rt;
}

- (void)reloadData
{
    Global::controller->download_files()->lock_for_read();
    Global::controller->downloading_files()->lock_for_read();
    [super reloadData];
    Global::controller->downloading_files()->unlock_for_read();
    Global::controller->download_files()->unlock_for_read();
}

@end

@implementation DownloadsViewController

//- (void)viewDidAppear
//{
//    NSUInteger nrows = [m_datasource numberOfRowsInTableView:self.tableView];
//    NSRect frame = self.view.frame;
//    frame.size.height = 50 * nrows + 100;
//    self.view.frame = frame;
//}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    QObject::connect(&Global::controller->download_files()->sig, &BaseListModelSignals::signal_tf_model_reset, [=]() {
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        [self performSelectorOnMainThread:@selector(resizePopover) withObject:nil waitUntilDone:YES];
    });
    QObject::connect(&Global::controller->downloading_files()->sig, &BaseListModelSignals::signal_tf_rows_inserted, [=](int row, int count)
    {
        for (int i = 0; i < count; i++) {
            File_ f = Global::controller->downloading_files()->get(i);
            id item = [QSharedPointerWrapper wrap:f.staticCast<QObject>()];
            [self performSelectorOnMainThread:@selector(handle_downloading_files_inserted:) withObject:item waitUntilDone:YES];
        }
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        [self performSelectorOnMainThread:@selector(resizePopover) withObject:nil waitUntilDone:YES];
    });
    QObject::connect(&Global::controller->download_files()->sig, &BaseListModelSignals::signal_tf_rows_removed, [=]() {
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        [self performSelectorOnMainThread:@selector(resizePopover) withObject:nil waitUntilDone:YES];
    });
    QObject::connect(&Global::controller->downloading_files()->sig, &BaseListModelSignals::signal_tf_model_reset, [=]() {
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        [self performSelectorOnMainThread:@selector(resizePopover) withObject:nil waitUntilDone:YES];
    });
    QObject::connect(&Global::controller->downloading_files()->sig, &BaseListModelSignals::signal_tf_rows_inserted, [=]() {
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        [self performSelectorOnMainThread:@selector(resizePopover) withObject:nil waitUntilDone:YES];
    });
    QObject::connect(&Global::controller->downloading_files()->sig, &BaseListModelSignals::signal_tf_rows_removed, [=]() {
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
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
}

- (void)resizePopover
{
    int nrows = [self->m_datasource numberOfRowsInTableView:self.tableView];
    NSSize size = self.tableView.intrinsicContentSize;
//    NSSize size = self->m_popover.contentSize;
    size.height += 60;
    size.width = 430;
    self->m_popover.contentSize = size;
}

- (void)viewWillAppear
{
    [super viewWillAppear];
    [self resizePopover];
    [self.tableView reloadData];
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
    NSIndexSet* rows = self.tableView.selectedRowIndexes;
    [rows enumerateIndexesUsingBlock:^(NSUInteger row, BOOL * _Nonnull stop) { 
        int offset = Global::controller->downloading_files()->count();
        if (row < offset) {
            File_ f = Global::controller->downloading_files()->get(row);
            Global::controller->deleteFileDownloadAsync(f);
        } else {
            File_ f = Global::controller->download_files()->get(row - offset);
            NSURL* url = [NSURL fileURLWithPath:f->absoluteFilePath().toNSString()];
            [[NSFileManager defaultManager] trashItemAtURL:url resultingItemURL:nil error:nil];
            Global::controller->download_files()->loadDirectoryContentsAsync(Global::controller->downloads_dirpath());
        }
    }];
}

- (IBAction)openDownloadedFile:(id)sender
{
    int row = self.tableView.selectedRow - Global::controller->downloading_files()->count();
    if (row >= 0) {
        File_ f = Global::controller->download_files()->get(row);
        [[NSWorkspace sharedWorkspace] openFile:f->absoluteFilePath().toNSString()];
    }
}

@end

@implementation DownloadTableItem
- (instancetype)initWithFile:(File_)file tableView:(NSTableView*)tableView;
{
    self = [super init];
    self.tableView = tableView;
    self.file = file;
    self.filepath = [NSURL URLWithString:file->absoluteFilePath().toNSString()];
    if (file->state() == DownloadStateLocal) {
        self.filesize = file->filesize().toNSString();
        self.filename = file->fileName().toNSString();
    } else {
        self.filesize = file->downloadProgress().toNSString();
        self.filename = file->save_as_filename().toNSString();
    }
    self.requireHttpConscent = file->state() == DownloadStateHttpUserConscentRequired;
    if (file->exists()) {
        self.thumbnail = [NSWorkspace.sharedWorkspace iconForFile:file->absoluteFilePath().toNSString()];
    } else {
        self.thumbnail = [NSWorkspace.sharedWorkspace iconForFileType:@""];
    }
    file->replaceConnection("HandleDownloadFilePropertyChanged", QObject::connect(file.get(), &File::propertyChanged, [=]() {
        [self performSelectorOnMainThread:@selector(reloadItem) withObject:nil waitUntilDone:YES];
    }));
    return self;
}
- (void)reloadItem
{
    int index = Global::controller->download_files()->indexOf(self.file) + Global::controller->downloading_files()->indexOf(self.file) + 1; // one of them is -1
    NSIndexSet* currentSelection = self.tableView.selectedRowIndexes;
    [self.tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
    [self.tableView selectRowIndexes:currentSelection byExtendingSelection:NO];
}
- (void)conscentHttp
{
    Global::controller->conscentHttpFileDownloadAsync(self.file);
    Global::controller->startFileDownloadAsync(self.file);
}
- (void)declineHttp
{
    Global::controller->deleteFileDownloadAsync(self.file);
}
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
    File_ f;
    int offset = Global::controller->downloading_files()->count();
    if (row < offset) {
        f = Global::controller->downloading_files()->get(row);
    } else {
        f = Global::controller->download_files()->get(row - offset);
    }
    DownloadTableItem* item = [[DownloadTableItem alloc] initWithFile:f tableView:tableView];
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
    Global::controller->finishFileDownloadBlocking(f);
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

