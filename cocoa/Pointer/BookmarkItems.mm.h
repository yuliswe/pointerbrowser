//
//  BookmarkItems.h
//  Pointer
//
//  Created by Yu Li on 2018-10-20.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <docviewer/docviewer.h>
#import "CppData.h"

NS_ASSUME_NONNULL_BEGIN

/********************************* Bookmarks **********************************/

@interface BookmarkCollectionViewItem : NSCollectionViewItem<WebpageWrapper, NSPasteboardWriting, NSPasteboardReading>
{
    IBOutlet NSTextField* m_letter;
    IBOutlet NSTextField* m_title;
}
@property Webpage_ webpage;
- (void)connect:(Webpage_)webpage;
- (IBAction)menu_delete:(id)sender;
- (IBAction)menu_edit:(id)sender;
- (IBAction)handle_title_edit_done:(id)sender;;
@end

@class BookmarkCollectionViewItemRootView;

@interface BookmarkCollectionViewItemThumbnailView : NSView
@property IBOutlet BookmarkCollectionViewItemRootView* rootView;
@end

@interface BookmarkCollectionViewItemRootView : NSView
{
    Webpage_ m_webpage;
    NSCollectionView* m_bookmark_collectionview;
    NSCollectionViewItem* m_bookmark_collectionviewitem;
    BOOL m_is_tag;
    TagContainer_ m_tagContainer;
    NSCollectionView* m_tag_collectionview;
    NSCollectionViewItem* m_tag_collectionviewitem;
}
@property Webpage_ webpage;
@property NSCollectionView* bookmark_collectionview;
@property NSCollectionViewItem* bookmark_collectionviewitem;
@property BOOL is_tag;
@property TagContainer_ tagContainer;
@property NSCollectionView* tag_collectionview;
@property NSCollectionViewItem* tag_collectionviewitem;
@end

@interface BookmarkItemMenuDelegate : NSObject<NSMenuDelegate>
{
    IBOutlet NSViewController* m_view_controller;
    IBOutlet NSCollectionViewItem* m_bookmark_collectionviewitem;
}
@end

/********************************* Tags **********************************/

@interface TagCollectionViewItem : NSCollectionViewItem<TagContainerWrapper, NSPasteboardWriting, NSPasteboardReading>
{
    IBOutlet NSTextField* m_letter;
    IBOutlet NSTextField* m_title;
}
@property TagContainer_ tagContainer;
- (void)connect:(TagContainer_)tagContainer;
- (IBAction)menu_delete:(id)sender;
- (IBAction)menu_edit:(id)sender;
- (IBAction)handle_title_edit_done:(id)sender;;
@end

@interface TagItemMenuDelegate : NSObject<NSMenuDelegate>
{
    IBOutlet NSViewController* m_view_controller;
    IBOutlet NSCollectionViewItem* m_tag_collectionviewitem;
}
@end
NS_ASSUME_NONNULL_END
