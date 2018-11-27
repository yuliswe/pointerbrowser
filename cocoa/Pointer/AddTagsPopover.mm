//
//  AddTagsPopover.m
//  Pointer
//
//  Created by Yu Li on 2018-11-14.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddTagsPopover.h"

@implementation AddTagsPopoverContentViewController
@synthesize webpage = m_webpage;
@synthesize search_field = m_search_field;
@synthesize popover = m_popover;
- (NSNibName)nibName
{
    return @"AddTagsPopover";
}

- (IBAction)handleSearchStringChanged:(id)sender
{
    [self->m_table_view reloadData];
}

- (void)viewDidAppear
{
    [self->m_table_view reloadData];
}

@end

@implementation AddTagsPopover

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    [self connect];
    return self;
}

- (void)connect
{
    QObject::connect(Global::controller, &Controller::signal_tf_close_all_popovers, [=]() {
        [self performSelectorOnMainThread:@selector(close) withObject:nil waitUntilDone:YES];
    });
}

- (void)showForWebpage:(Webpage_)webpage relativeToRect:(NSRect)positioningRect ofView:(NSView *)positioningView preferredEdge:(NSRectEdge)preferredEdge
{
    if (! webpage.get()) { return; }
    AddTagsPopoverContentViewController* contentViewController = (AddTagsPopoverContentViewController*)self.contentViewController;
    contentViewController.webpage = webpage;
    [super showRelativeToRect:positioningRect ofView:positioningView preferredEdge:preferredEdge];
}
@end

@implementation TagsPopoverTableView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    self.delegate = self;
    self.dataSource = self;
    self.action = @selector(handleAction:);
    self.showingCreateTagButtonRow = NO;
    [self connect];
    return self;
}

- (void)connect
{
    QObject::connect(&Global::controller->tags()->sig, &BaseListModelSignals::signal_tf_model_reset, [=]() {
        [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    });
    QObject::connect(&Global::controller->tags()->sig, &BaseListModelSignals::signal_tf_rows_inserted, [=]() {
        [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    });
    QObject::connect(&Global::controller->tags()->sig, &BaseListModelSignals::signal_tf_rows_removed, [=]() {
        [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    });
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    if (! self->m_tags_popover_content_view_controller) { return 0; }
    NSString* search_str = self->m_tags_popover_content_view_controller.search_field.stringValue;
    int search_str_len = search_str.length;
    if (search_str_len > 0) {
        int search_tags_count = Global::controller->listTagsMatching(QString::fromNSString(self->m_tags_popover_content_view_controller.search_field.stringValue))->count();
        if (Global::controller->indexOfTagContainerByTitle(QString::fromNSString(search_str)) >= 0) {
            self.showingCreateTagButtonRow = NO;
            return search_tags_count;
        } else {
            self.showingCreateTagButtonRow = YES;
            return search_tags_count + 1;
        }
    } else {
        return Global::controller->tags()->count();
    }
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row
{
    NSString* search_str = self->m_tags_popover_content_view_controller.search_field.stringValue;
    int search_str_len = search_str.length;
    NSTableRowView* rowView;
    if (search_str_len > 0) {
        if (row == 0 && self.showingCreateTagButtonRow) {
            rowView = [self makeViewWithIdentifier:@"CreateTag" owner:nil];
        } else {
            std::pair<TagsCollection_,TagsCollection_> partition = Global::controller->partitionTagsByUrl(self->m_tags_popover_content_view_controller.webpage->url());
            TagsCollection_ yes = partition.first;
            TagsCollection_ no = partition.second;
            TagsPopoverTableRowObject* object = [self tableView:self objectValueForTableColumn:self.tableColumns[0] row:row];
            if (yes->indexOf(object.tagContainer) >= 0) {
                rowView = [self makeViewWithIdentifier:@"CurrentTag" owner:nil];
            } else {
                rowView = [self makeViewWithIdentifier:@"AvailableTag" owner:nil];
            }
        }
    } else {
        std::pair<TagsCollection_,TagsCollection_> partition = Global::controller->partitionTagsByUrl(self->m_tags_popover_content_view_controller.webpage->url());
        TagsCollection_ yes = partition.first;
        TagsCollection_ no = partition.second;
        if (row < yes->count()) {
            rowView = [self makeViewWithIdentifier:@"CurrentTag" owner:nil];
        } else {
            rowView = [self makeViewWithIdentifier:@"AvailableTag" owner:nil];
        }
    }
    return rowView;
}

- (id)tableView:(NSTableView *)tableView
objectValueForTableColumn:(NSTableColumn *)tableColumn
            row:(NSInteger)row
{
    TagsPopoverTableRowObject* objectValue = [[TagsPopoverTableRowObject alloc] init];
    NSString* search_str = self->m_tags_popover_content_view_controller.search_field.stringValue;
    if (search_str.length == 0) {
        std::pair<TagsCollection_,TagsCollection_> partition = Global::controller->partitionTagsByUrl(self->m_tags_popover_content_view_controller.webpage->url());
        TagsCollection_ yes = partition.first;
        TagsCollection_ no = partition.second;
        if (row < yes->count()) {
            TagContainer_ container = yes->get(row);
            [self helperConnectTagContainerSignals:container];
            objectValue.title = container->title().toNSString();
            objectValue.tagContainer = container;
        } else {
            TagContainer_ container = no->get(row - yes->count());
            [self helperConnectTagContainerSignals:container];
            objectValue.title = container->title().toNSString();
            objectValue.tagContainer = container;
        }
        return objectValue;
    } else {
        if (row == 0 && self.showingCreateTagButtonRow) {
            objectValue.title = [NSString stringWithFormat:@"Create \"%@\"", search_str];
            return objectValue;
        } else {
            TagsCollection_ collection = Global::controller->listTagsMatching(QString::fromNSString(self->m_tags_popover_content_view_controller.search_field.stringValue));
            int count = collection->count();
            TagContainer_ container = collection->get(self.showingCreateTagButtonRow ? row - 1 : row); // -1 for Create Button
            [self helperConnectTagContainerSignals:container];
            objectValue.title = container->title().toNSString();
            objectValue.tagContainer = container;
            return objectValue;
        }
    }
    return nil;
}

- (void)helperConnectTagContainerSignals:(TagContainer_)container
{
    container->replaceConnection("handleModelReset", QObject::connect(&container->sig, &BaseListModelSignals::signal_tf_model_reset, [=]() {
        [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    }));
    container->replaceConnection("handleRowsInserted", QObject::connect(&container->sig, &BaseListModelSignals::signal_tf_rows_inserted, [=]() {
        [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    }));
    container->replaceConnection("handleRowsRemoved", QObject::connect(&container->sig, &BaseListModelSignals::signal_tf_rows_removed, [=]() {
        [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    }));
}

- (SEL)handleAction:(id)sender
{
    int search_tags_count = Global::controller->listTagsMatching(QString::fromNSString(self->m_tags_popover_content_view_controller.search_field.stringValue))->count();
    NSString* search_str = self->m_tags_popover_content_view_controller.search_field.stringValue;
    Webpage_ w = self->m_tags_popover_content_view_controller.webpage;
    NSTableColumn* col = self.tableColumns[0];
    TagsPopoverTableRowObject* objectValue = [self tableView:self objectValueForTableColumn:col row:self.clickedRow];
    // if the Create new Tag is clicked
    if (search_str.length > 0)
    {
        if (self.clickedRow == 0 && self.showingCreateTagButtonRow) {
            Global::controller->createTagContainerByWebpageCopyAsync(QString::fromNSString(search_str), 0, self->m_tags_popover_content_view_controller.webpage);
        } else {
            TagContainer_ container = objectValue.tagContainer;
            if (container->containsUrl(w->url())) {
                Global::controller->tagContainerRemoveWebpageAsync(container, w);
            } else {
                Global::controller->tagContainerInsertWebpageCopyAsync(container, 0, w);
            }
        }
    }
    else if (search_str.length == 0) {
        TagContainer_ container = objectValue.tagContainer;
        if (container->containsUrl(w->url())) {
            Global::controller->tagContainerRemoveWebpageAsync(container, w);
        } else {
            Global::controller->tagContainerInsertWebpageCopyAsync(objectValue.tagContainer, 0, w);
        }
    }
}

- (void)reloadData
{
    [super reloadData];
    NSSize size = self->m_tags_popover_content_view_controller.popover.contentSize;
    size.height = self.intrinsicContentSize.height + (self.numberOfRows > 0 ? 60 : 50);
    self->m_tags_popover_content_view_controller.popover.contentSize = size;
}

@end

@implementation TagsPopoverTableRowObject
@synthesize tagContainer = m_tagContainer;
@synthesize title = m_title;
@end
