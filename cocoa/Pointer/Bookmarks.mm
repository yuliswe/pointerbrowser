//
//  BookmarksViewController.m
//  Pointer
//
//  Created by Yu Li on 2018-10-19.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import "Bookmarks.mm.h"
#include <docviewer/docviewer.h>
#import "CppData.mm.h"

@implementation BookmarksViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    [self loadView];
    return self;
}


- (void)viewDidLoad {
    [self->m_parent addSubview:self.view];
    self.view.frame = self->m_parent.bounds;
    self.view.autoresizingMask = NSViewHeightSizable | NSViewWidthSizable;
    [self->m_bookmarks_collectionview registerClass:BookmarksCollectionViewItem.class forItemWithIdentifier:@"BookmarksCollectionViewItem"];
    [self->m_bookmarks_collectionview registerForDraggedTypes:@[NSPasteboardTypeURL]];
    QObject::connect(Global::controller->bookmarks().get(), &TabsModel::rowsInserted, [=]() {
        [self->m_bookmarks_collectionview performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    });
    QObject::connect(Global::controller->bookmarks().get(), &TabsModel::rowsRemoved, [=]() {
        [self->m_bookmarks_collectionview performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    });
    QObject::connect(Global::controller->bookmarks().get(), &TabsModel::rowsMoved, [=]() {
        [self->m_bookmarks_collectionview performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    });
    QObject::connect(Global::controller->bookmarks().get(), &TabsModel::modelReset, [=]() {
        [self->m_bookmarks_collectionview performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    });
    [super viewDidLoad];
}

- (void)mouseDown:(id)sender
{
    [self.view.window makeFirstResponder:self.view.window];
}

@end



@implementation BookmarksCollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return Global::controller->bookmarks()->count();
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView
     itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        Webpage_ w = Global::controller->bookmarks()->webpage_(indexPath.item);
        //        CppSharedData* item = [CppSharedData wrap:(std::static_pointer_cast<Webpage>(w))];
        BookmarksCollectionViewItem* item = [collectionView makeItemWithIdentifier:@"BookmarksCollectionViewItem" forIndexPath:indexPath];
//        NSRect frame = item.view.frame;
//        frame.size.height = 30;
//        frame.size.width = 30;
//        item.view.frame = frame;
        item.webpage = w;
        [item connect];
        return item;
    }
    return nil;
}
@end

@implementation BookmarksCollectionViewDelegate

- (id<NSPasteboardWriting>)collectionView:(NSCollectionView *)collectionView
       pasteboardWriterForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSPasteboardItem* boarditem = [[NSPasteboardItem alloc] init];
    BookmarksCollectionViewItem* item = (BookmarksCollectionViewItem*)[collectionView itemAtIndexPath:indexPath];
    Webpage_ w = item.webpage;
    [boarditem setString:w->url().full().toNSString() forType:NSPasteboardTypeURL];
    return boarditem;
}

- (BOOL)collectionView:(NSCollectionView *)collectionView
            acceptDrop:(id<NSDraggingInfo>)draggingInfo
             indexPath:(NSIndexPath *)indexPath
         dropOperation:(NSCollectionViewDropOperation)dropOperation
{
    NSPasteboard* pasteboard = draggingInfo.draggingPasteboard;
    NSPasteboardItem* boarditem = pasteboard.pasteboardItems[0];
    NSString* urlstr = [boarditem stringForType:NSPasteboardTypeURL];
    int old_index = Global::controller->bookmarks()->findTab(QString::fromNSString(urlstr));
    int new_index = indexPath.item;
    if (old_index >= 0) {
        Global::controller->moveBookmarkAsync(old_index, new_index, (__bridge void*)self);
    } else {
        Webpage_ w = shared<Webpage>(QString::fromNSString(urlstr));
        Global::controller->insertBookmark(w, new_index);
    }
    return YES;
}

- (NSDragOperation)collectionView:(NSCollectionView *)collectionView
                     validateDrop:(id<NSDraggingInfo>)draggingInfo
                proposedIndexPath:(NSIndexPath * _Nonnull *)proposedDropIndexPath
                    dropOperation:(NSCollectionViewDropOperation *)proposedDropOperation
{
    NSIndexPath* path = *proposedDropIndexPath;
    if (draggingInfo.draggingSource != collectionView) {
        return NSDragOperationCopy;
    }
    return NSDragOperationMove;
}
//
//- (void)outlineView:(NSOutlineView *)outlineView
//    draggingSession:(NSDraggingSession *)session
//   willBeginAtPoint:(NSPoint)screenPoint
//           forItems:(NSArray *)draggedItems
//{
//    outlineView.draggingDestinationFeedbackStyle = NSTableViewDraggingDestinationFeedbackStyleGap;
//}
@end
