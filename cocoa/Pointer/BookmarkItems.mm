//
//  BookmarkItems.m
//  Pointer
//
//  Created by Yu Li on 2018-10-20.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import "BookmarkItems.mm.h"

@implementation BookmarksCollectionViewItem
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
    [(BookmarkCollectionViewItemRoot*)self.view setWebpage:self.webpage];
    ((BookmarkCollectionViewItemRoot*)self.view).bookmark_collectionviewitem = self;
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
@end


@implementation BookmarkCollectionViewItemRoot
@synthesize webpage = m_webpage;
@synthesize bookmark_collectionview = m_bookmark_collectionview;
@synthesize bookmark_collectionviewitem = m_bookmark_collectionviewitem;
- (void)mouseUp:(NSEvent*)event
{
    NSInteger button = event.buttonNumber;
    if (button == 0) {
        Global::controller->currentTabWebpageGoAsync(self.webpage->url().full());
    }
}
@end

@implementation BookmarkItemMenuDelegate
- (void)menuWillOpen:(NSMenu *)menu
{
    [self->m_bookmark_collectionviewitem.view.window makeFirstResponder:self->m_view_controller.view.window.initialFirstResponder];
}
@end
