//
//  BookmarkItems.h
//  Pointer
//
//  Created by Yu Li on 2018-10-20.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <docviewer/docviewer.h>

NS_ASSUME_NONNULL_BEGIN

@interface BookmarksCollectionViewItem : NSCollectionViewItem
{
    Webpage_ m_webpage;
    IBOutlet NSTextField* m_letter;
    IBOutlet NSTextField* m_title;
}
@property Webpage_ webpage;
- (void)connect;
- (IBAction)menu_delete:(id)sender;
- (IBAction)menu_edit:(id)sender;
- (IBAction)handle_title_edit_done:(id)sender;;
@end

@interface BookmarkCollectionViewItemRoot: NSView
{
    Webpage_ m_webpage;
    NSCollectionView* m_bookmark_collectionview;
    NSCollectionViewItem* m_bookmark_collectionviewitem;
}
@property Webpage_ webpage;
@property NSCollectionView* bookmark_collectionview;
@property NSCollectionViewItem* bookmark_collectionviewitem;
@end

@interface BookmarkItemMenuDelegate : NSObject<NSMenuDelegate>
{
    IBOutlet NSViewController* m_view_controller;
    IBOutlet NSCollectionViewItem* m_bookmark_collectionviewitem;
}
@end
NS_ASSUME_NONNULL_END
