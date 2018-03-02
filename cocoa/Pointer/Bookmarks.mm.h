//
//  BookmarksViewController.h
//  Pointer
//
//  Created by Yu Li on 2018-10-19.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <docviewer/docviewer.h>
#import "BookmarkItems.mm.h"

NS_ASSUME_NONNULL_BEGIN

@interface BookmarksViewController : NSViewController
{
    IBOutlet NSView* m_parent;
    IBOutlet NSCollectionView* m_bookmarks_collectionview;
}
@end

@interface BookmarksCollectionViewDataSource : NSObject<NSCollectionViewDataSource>

@end

@interface BookmarksCollectionViewDelegate : NSObject<NSCollectionViewDelegate>

@end

NS_ASSUME_NONNULL_END
