//
//  AddTagsPopover.h
//  Pointer
//
//  Created by Yu Li on 2018-11-14.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#ifndef AddTagsPopover_h
#define AddTagsPopover_h

#import <Cocoa/Cocoa.h>
#import <docviewer/docviewer.h>
#import "CppData.h"

@class TagsPopoverTableView;
@interface AddTagsPopoverContentViewController : NSViewController
{
    Webpage_ m_webpage;
    IBOutlet NSSearchField* m_search_field;
    IBOutlet NSPopover* m_popover;
    IBOutlet TagsPopoverTableView* m_table_view;
}
@property Webpage_ webpage;
@property (readonly) IBOutlet NSSearchField* search_field;
@property (readonly) IBOutlet NSPopover* popover;
@end

@interface AddTagsPopover : NSPopover
- (void)showForWebpage:(Webpage_)webpage relativeToRect:(NSRect)positioningRect ofView:(NSView *)positioningView preferredEdge:(NSRectEdge)preferredEdge;
@end

@interface TagsPopoverTableView : NSTableView<NSTableViewDelegate, NSTableViewDataSource>
{
    IBOutlet AddTagsPopoverContentViewController* m_tags_popover_content_view_controller;
}
@property BOOL showingCreateTagButtonRow;
@end

@interface TagsPopoverTableRowObject : NSObject
{
    TagContainer_ m_tagContainer;
    NSString* m_title;
}
@property NSString* title;
@property TagContainer_ tagContainer;
@end

#endif /* AddTagsPopover_h */
