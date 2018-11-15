//
//  BookmarkItems.m
//  Pointer
//
//  Created by Yu Li on 2018-10-20.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import "BookmarkItems.mm.h"

/********************************* Bookmarks **********************************/

@implementation BookmarkCollectionViewItem
@synthesize webpage = m_webpage;

- (NSNibName)nibName
{
    return @"BookmarkItems";
}

- (void)connect
{
    NSString* title = self->m_webpage->title().toNSString();
    self->m_title.stringValue = title;
    if (self->m_webpage->title().length() > 0) {
        NSString* letter = QString(self->m_webpage->title()[0].toUpper()).toNSString();
        self->m_letter.stringValue = letter;
    }
    [(BookmarkCollectionViewItemRootView*)self.view setWebpage:self.webpage];
    ((BookmarkCollectionViewItemRootView*)self.view).bookmark_collectionviewitem = self;
    QObject::connect(self.webpage.get(), &Webpage::propertyChanged, [=]() {
        [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    });
}

- (void)menu_delete:(id)sender
{
    NSIndexPath* indexpath = [self.collectionView indexPathForItem:self];
    int idx = indexpath.item;
    Global::controller->removeBookmarkAsync(idx);
}

- (void)menu_edit:(id)sender
{
    [self->m_title setEditable:YES];
    [self.view.window makeFirstResponder:self->m_title];
    [self->m_title selectText:self];
}

- (void)handle_title_edit_done:(id)sender
{
    NSTextField* textfield = (NSTextField*)sender;
    Global::controller->renameBookmarkAsync(self.webpage, QString::fromNSString(textfield.stringValue));
    textfield.editable = NO;
}
- (instancetype)initWithPasteboardPropertyList:(id)propertyList ofType:(NSPasteboardType)type
{
    int index = [propertyList intValue];
    Webpage_ w = Global::controller->bookmarks()->webpage_(index);
    self.webpage = w;
    [self connect];
    return self;
}
- (id)pasteboardPropertyListForType:(NSPasteboardType)type
{
    int index = Global::controller->bookmarks()->findTab(self.webpage);
    return [NSNumber numberWithInt:index];
}
- (NSArray<NSPasteboardType> *)writableTypesForPasteboard:(NSPasteboard *)pasteboard
{
    return @[@"com.pointerbrowser.pasteboarditem.collection.bookmark"];
}
+ (NSArray<NSPasteboardType> *)readableTypesForPasteboard:(NSPasteboard *)pasteboard
{
    return @[@"com.pointerbrowser.pasteboarditem.collection.bookmark"];
}
+ (NSPasteboardReadingOptions)readingOptionsForType:(NSPasteboardType)type pasteboard:(NSPasteboard *)pasteboard
{
    return NSPasteboardReadingAsPropertyList;
}
@end


@implementation BookmarkCollectionViewItemRootView
@synthesize webpage = m_webpage;
@synthesize bookmark_collectionview = m_bookmark_collectionview;
@synthesize bookmark_collectionviewitem = m_bookmark_collectionviewitem;
- (void)mouseUp:(NSEvent*)event
{
    NSInteger button = event.buttonNumber;
    if (button == 0) {
        if (self.is_tag) {
            if (Global::controller->current_tab_webpage()->is_blank()) {
                Global::controller->closeTabAsync();
            }
            Global::controller->workspacesInsertTagContainerAsync(0, self.tagContainer);
        } else {
            Global::controller->currentTabWebpageGoAsync(self.webpage->url().full());
        }
    }
}
@end

@implementation BookmarkItemMenuDelegate
- (void)menuWillOpen:(NSMenu *)menu
{
    [self->m_bookmark_collectionviewitem.view.window makeFirstResponder:self->m_view_controller.view.window];
}
@end

/********************************* Tags **********************************/

@implementation TagCollectionViewItem
@synthesize tagContainer = m_tagContainer;

- (NSNibName)nibName
{
    return @"BookmarkItems";
}

- (void)connect
{
    NSString* title = self->m_tagContainer->title().toNSString();
    self->m_title.stringValue = title;
    if (title.length > 0) {
        QChar c = self->m_tagContainer->title()[0].toUpper();
        NSString* letter = QString(c).toNSString();
        NSString* digits = QString::number(self->m_tagContainer->count()).toNSString();
        NSMutableAttributedString* title = [[NSMutableAttributedString alloc] initWithString:letter];
        NSMutableAttributedString* sups = [[NSMutableAttributedString alloc] initWithString:digits];
        if (QString("INMEKHXZJ").indexOf(c) >= 0) {
            NSMutableAttributedString* spaced = [[NSMutableAttributedString alloc] initWithString:@" "];
            [spaced appendAttributedString:sups];
            sups = spaced;
        }
        NSFont* font = [NSFont fontWithDescriptor:[[NSFontDescriptor alloc] fontDescriptorWithSymbolicTraits:NSFontDescriptorTraitCondensed] size:9];
        [sups addAttribute:NSFontAttributeName value:font range:NSRange{0,sups.length}];
        if (QString("FTYPZVJWU").indexOf(c) >= 0) {
            [sups addAttribute:NSBaselineOffsetAttributeName value:@-5 range:NSRange{0,sups.length}];
        } else {
            [sups addAttribute:NSBaselineOffsetAttributeName value:@22 range:NSRange{0,sups.length}];
        }
        NSMutableAttributedString* finally = [[NSMutableAttributedString alloc] initWithAttributedString:sups];
        [finally addAttribute:NSForegroundColorAttributeName
                         value:[NSColor clearColor]
                        range:NSMakeRange(0, finally.length)];
        [title appendAttributedString:sups];
        [finally appendAttributedString:title];
        self->m_letter.attributedStringValue = finally;
    }
    BookmarkCollectionViewItemRootView* view = (BookmarkCollectionViewItemRootView*)self.view;
    view.is_tag = YES;
    view.tagContainer = self.tagContainer;
    view.tag_collectionviewitem = self;
    QObject::connect(self.tagContainer.get(), &TagContainer::propertyChanged, [=]() {
        [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    });
}

- (void)menu_delete:(id)sender
{
    NSIndexPath* indexpath = [self.collectionView indexPathForItem:self];
    int idx = indexpath.item;
    Global::controller->removeTagContainerAsync(idx);
}

- (void)menu_edit:(id)sender
{
    [self->m_title setEditable:YES];
    [self.view.window makeFirstResponder:self->m_title];
    [self->m_title selectText:self];
}

- (void)handle_title_edit_done:(id)sender
{
    NSTextField* textfield = (NSTextField*)sender;
    Global::controller->renameTagContainerAsync(self.tagContainer, QString::fromNSString(textfield.stringValue));
    textfield.editable = NO;
}
- (instancetype)initWithPasteboardPropertyList:(id)propertyList ofType:(NSPasteboardType)type
{
    int index = [propertyList intValue];
    TagContainer_ c = Global::controller->tags()->get(index);
    self.tagContainer = c;
    [self connect];
    return self;
}
- (id)pasteboardPropertyListForType:(NSPasteboardType)type
{
    int index = Global::controller->tags()->indexOf(self.tagContainer);
    return [NSNumber numberWithInt:index];
}
- (NSArray<NSPasteboardType> *)writableTypesForPasteboard:(NSPasteboard *)pasteboard
{
    return @[@"com.pointerbrowser.pasteboarditem.collection.tag"];
}
+ (NSArray<NSPasteboardType> *)readableTypesForPasteboard:(NSPasteboard *)pasteboard
{
    return @[@"com.pointerbrowser.pasteboarditem.collection.tag"];
}
+ (NSPasteboardReadingOptions)readingOptionsForType:(NSPasteboardType)type pasteboard:(NSPasteboard *)pasteboard
{
    return NSPasteboardReadingAsPropertyList;
}
@end

@implementation TagItemMenuDelegate
- (void)menuWillOpen:(NSMenu *)menu
{
    [self->m_tag_collectionviewitem.view.window makeFirstResponder:self->m_view_controller.view.window.initialFirstResponder];
}
@end
