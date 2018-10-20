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

- (void)viewDidLoad {
    [super viewDidLoad];
    [self->m_parent addSubview:self.view];
    self.view.frame = self->m_parent.bounds;
    self.view.autoresizingMask = NSViewHeightSizable | NSViewWidthSizable;
}

@end

@implementation BookmarksCollectionViewDataSource

@end

@implementation BookmarksCollectionViewDelegate
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
        item.webpage = w;
        return item;
    }
    return nil;
}
@end

@implementation BookmarksCollectionViewItem
@synthesize webpage = m_webpage;
@end
