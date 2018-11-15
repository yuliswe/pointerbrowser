//
//  BookmarksViewController.m
//  Pointer
//
//  Created by Yu Li on 2018-10-19.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import "Bookmarks.mm.h"
#include <docviewer/docviewer.h>
#import "CppData.h"
#import "OutlineView.mm.h"

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
    [self->m_bookmarks_collectionview registerClass:BookmarkCollectionViewItem.class forItemWithIdentifier:@"BookmarksCollectionViewItem"];
    [self->m_bookmarks_collectionview registerClass:TagCollectionViewItem.class forItemWithIdentifier:@"TagsCollectionViewItem"];
    [self->m_bookmarks_collectionview registerForDraggedTypes:@[NSPasteboardTypeURL, @"com.pointerbrowser.pasteboarditem.collection.bookmark", @"com.pointerbrowser.pasteboarditem.collection.tag"]];
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
    QObject::connect(&Global::controller->tags()->sig, &BaseListModelSignals::signal_tf_rows_inserted, [=]() {
        [self->m_bookmarks_collectionview performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    });
    QObject::connect(&Global::controller->tags()->sig, &BaseListModelSignals::signal_tf_rows_removed, [=]() {
        [self->m_bookmarks_collectionview performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    });
    QObject::connect(&Global::controller->tags()->sig, &BaseListModelSignals::signal_tf_rows_moved, [=]() {
        [self->m_bookmarks_collectionview performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    });
    QObject::connect(&Global::controller->tags()->sig, &BaseListModelSignals::signal_tf_model_reset, [=]() {
        [self->m_bookmarks_collectionview performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    });
    [super viewDidLoad];
}
@end



@implementation BookmarksCollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView
{
    // index 0 lists bookmarks
    // index 1 lists tags
    return 2;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    if (section == 0) {
        return Global::controller->bookmarks()->count();
    }
    if (section == 1) {
        return Global::controller->tags()->count();
    }
    return 0;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView
     itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        Webpage_ w = Global::controller->bookmarks()->webpage_(indexPath.item);
        BookmarkCollectionViewItem* item = [collectionView makeItemWithIdentifier:@"BookmarksCollectionViewItem" forIndexPath:indexPath];
        item.webpage = w;
        [item connect];
        return item;
    }
    if (indexPath.section == 1) {
        TagContainer_ c = Global::controller->tags()->get(indexPath.item);
        TagCollectionViewItem* item = [collectionView makeItemWithIdentifier:@"TagsCollectionViewItem" forIndexPath:indexPath];
        item.tagContainer = c;
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
    if (indexPath.section == 0) {
        BookmarkCollectionViewItem* item = (BookmarkCollectionViewItem*)[collectionView itemAtIndexPath:indexPath];
        return item;
    }
    if (indexPath.section == 1) {
        TagCollectionViewItem* item = (TagCollectionViewItem*)[collectionView itemAtIndexPath:indexPath];
        return item;
    }
    return nil;
}

- (BOOL)collectionView:(NSCollectionView *)collectionView
            acceptDrop:(id<NSDraggingInfo>)draggingInfo
             indexPath:(NSIndexPath *)indexPath
         dropOperation:(NSCollectionViewDropOperation)dropOperation
{
    int new_index = indexPath.item;
    NSPasteboard* pasteboard = draggingInfo.draggingPasteboard;
    if (indexPath.section == 0) {
        NSArray<id>* boarditems = [pasteboard readObjectsForClasses:@[SearchResultTabItem.class, OpenTabItem.class, WorkspaceTabItem.class, BookmarkCollectionViewItem.class] options:nil];
        for (int i = boarditems.count - 1; i >= 0; i--) {
            id item = boarditems[i];
            if ([item isKindOfClass:BookmarkCollectionViewItem.class]) {
                Webpage_ webpage = [item webpage];
                int old = Global::controller->bookmarks()->findTab(webpage);
                Global::controller->moveBookmarkAsync(old, new_index);
                return YES;
            }
        }
        return NO;
    }
    if (indexPath.section == 1) {
        NSArray<id>* boarditems = [pasteboard readObjectsForClasses:@[SearchResultTabItem.class, OpenTabItem.class, WorkspaceTabItem.class, TagCollectionViewItem.class] options:nil];
        for (int i = boarditems.count - 1; i >= 0; i--) {
            id item = boarditems[i];
            if ([item isKindOfClass:TagCollectionViewItem.class]) {
                TagContainer_ container = [item tagContainer];
                int old = Global::controller->tags()->indexOf(container);
                Global::controller->moveTagContainerAsync(old, new_index);
                return YES;
            }
        }
        return NO;
    }
    return NO;
}

- (NSDragOperation)collectionView:(NSCollectionView *)collectionView
                     validateDrop:(id<NSDraggingInfo>)draggingInfo
                proposedIndexPath:(NSIndexPath * _Nonnull *)proposedDropIndexPath
                    dropOperation:(NSCollectionViewDropOperation *)proposedDropOperation
{
    NSIndexPath* path = *proposedDropIndexPath;
    NSPasteboard* pasteboard = draggingInfo.draggingPasteboard;
    if ([pasteboard canReadObjectForClasses:@[BookmarkCollectionViewItem.class] options:nil]
        && path.section == 0)
    {
        return NSDragOperationMove;
    }
    if ([pasteboard canReadObjectForClasses:@[TagCollectionViewItem.class] options:nil]
        && path.section == 1)
    {
        return NSDragOperationMove;
    }
    return NSDragOperationNone;
}

@end

@implementation BookmarkCollectionView
- (void)mouseDown:(NSEvent*)event
{
    Global::controller->closeAllPopoversAsync();
    [super mouseDown:event];
}
@end
