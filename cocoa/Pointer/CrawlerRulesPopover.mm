//
//  CrawlerRulesPopover.m
//  Pointer
//
//  Created by Yu Li on 2018-09-05.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import "CrawlerRulesPopover.mm.h"
#include <docviewer/docviewer.h>

@implementation CrawlerRulesPopover

@synthesize caller_button = m_caller_button;

- (instancetype)initWithCoder:(NSCoder*)code
{
    self = [super init];
    self.contentViewController = [[CrawlerRulesPopoverContentViewController alloc] initWithPopover:self];
    [self connect];
    return self;
}

- (void)connect
{
    QObject::connect(Global::controller,
                     &Controller::signal_tf_show_crawler_rule_table,
                     [=]() {
                         [self performSelectorOnMainThread:@selector(handle_tf_show_crawler_rule_table) withObject:nil waitUntilDone:YES];
                     });
    QObject::connect(Global::controller,
                     &Controller::signal_tf_hide_crawler_rule_table,
                     [=]() {
                         [self performSelectorOnMainThread:@selector(handle_tf_hide_crawler_rule_table) withObject:nil waitUntilDone:YES];
                     });
}

- (void)handle_tf_show_crawler_rule_table
{
    [self showRelativeToRect:[self->m_caller_button bounds]
                      ofView:self->m_caller_button
               preferredEdge:NSRectEdgeMaxY];
}

- (void)handle_tf_hide_crawler_rule_table
{
    [self close];
}

@end


@implementation CrawlerRulesPopoverContentViewController
@synthesize table = m_table;
@synthesize table_title_textfield = m_table_title_textfield;
@synthesize popover = m_popover;

- (instancetype)initWithPopover:(NSPopover*)popover
{
    self = [super init];
    self.popover = popover;
    [self connect];
    return self;
}

- (void)connect
{
    QObject::connect(Global::controller,
                     &Controller::current_webpage_crawler_rule_table_changed,
                     [=]() {
                         [self performSelectorOnMainThread:@selector(handle_current_webpage_crawler_rule_table_changed) withObject:nil waitUntilDone:YES];
                     });
    QObject::connect(Global::controller,
                     &Controller::signal_tf_show_crawler_rule_table,
                     [=]() {
                         [self performSelectorOnMainThread:@selector(handle_current_webpage_crawler_rule_table_changed) withObject:nil waitUntilDone:YES];
                     });
}

- (NSNibName)nibName
{
    return @"CrawlerRulesPopover";
}

- (IBAction)handle_done_button_clicked:(id)sender
{
    Global::controller->hideCrawlerRuleTableAsync();
}

- (void)handle_current_webpage_crawler_rule_table_changed
{
    CrawlerRuleTable_ table = Global::controller->current_webpage_crawler_rule_table();
    QSet<CrawlerRule> rule = *table->rules();
    NSString* domain = table->domain().full().toNSString();
    NSString* title = [NSString stringWithFormat:@"Discovery rules on domain \"%@\"", domain];
    self.table_title_textfield.stringValue = title;
    [self.table reloadData];
}

- (void)viewDidLoad
{
    [self handle_current_webpage_crawler_rule_table_changed];
}

@end

@implementation CrawlerRuleTableData
@synthesize pattern = m_pattern;
@synthesize enabled = m_enabled;
@synthesize matched = m_matched;
@synthesize placeholder_line = m_placeholder_line;
@end


@implementation CrawlerRuleTableDelegate
- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    return YES;
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row
{
    CrawlerRuleTableCellView* cellview;
    if ([tableColumn.identifier isEqualToString:@"RegularExpressionColumn"]) {
        cellview = [tableView makeViewWithIdentifier:@"RegularExpressionCell" owner:self];
        ((CrawlerRuleTableCellTextField*)cellview.subviews[0]).table = (CrawlerRuleTableView*)tableView;
    } else if ([tableColumn.identifier isEqualToString:@"EnableButtonColumn"]) {
        cellview = [tableView makeViewWithIdentifier:@"EnableButtonCell" owner:self];
        ((CrawlerRuleTableCellEnableButton*)cellview.subviews[0]).table = (CrawlerRuleTableView*)tableView;
    } else if ([tableColumn.identifier isEqualToString:@"MatchIndicatorColumn"]) {
        cellview = [tableView makeViewWithIdentifier:@"MatchIndicatorCell" owner:self];
        ((CrawlerRuleTableCellMatchIndicator*)cellview.subviews[0]).table = (CrawlerRuleTableView*)tableView;
    }
    return cellview;
}

//- (NSIndexSet *)tableView:(NSTableView *)tableView selectionIndexesForProposedSelection:(NSIndexSet *)proposedSelectionIndexes
//{
//    return [[NSIndexSet alloc] init];
//}
@end


@implementation CrawlerRuleTableView

- (instancetype)initWithCoder:(NSCoder*)coder
{
    self = [super initWithCoder:coder];
    self.doubleAction = @selector(handleDoubleClick:);
    [self connect];
    return self;
}

- (void)handleDoubleClick:(id)sender
{
    if (self.clickedColumn == 1) {
        CrawlerRuleTableCellView* rowview = [self viewAtColumn:self.clickedColumn row:self.clickedRow makeIfNecessary:NO];
        [self.window makeFirstResponder:rowview.textfield];
    }
}

- (void)connect
{
    QObject::connect(Global::controller,
                     &Controller::signal_tf_hide_crawler_rule_table_row_hint,
                     [=]() {
                         [self performSelectorOnMainThread:@selector(handle_tf_hide_crawler_rule_table_row_hint) withObject:nil waitUntilDone:YES];
                     });
    
    QObject::connect(Global::controller,
                     &Controller::signal_tf_show_crawler_rule_table_row_hint,
                     [=](int row) {
                         NSNumber* n = [NSNumber numberWithInt:row];
                         [self performSelectorOnMainThread:@selector(handle_tf_show_crawler_rule_table_row_hint:) withObject:n waitUntilDone:YES];
                     });
}

- (void)handle_tf_hide_crawler_rule_table_row_hint
{
    [self->m_hint_popover close];
}

- (void)handle_tf_show_crawler_rule_table_row_hint:(NSNumber*)row
{
    NSTableRowView* rowview = [self rowViewAtRow:row.intValue makeIfNecessary:NO];
    CrawlerRuleTableCellView* cell = [rowview viewAtColumn:1];
    [self.window makeFirstResponder:cell.textfield];
    [self->m_hint_popover showRelativeToRect:[rowview bounds] ofView:rowview preferredEdge:NSRectEdgeMinY];
}

- (IBAction)handleRowEdited:(id)sender
{
    NSInteger row = [self rowForView:sender];
    CrawlerRuleTableData* data = [[CrawlerRuleTableData alloc] init];
    for (int i = 0; i < self.numberOfColumns; i++) {
        CrawlerRuleTableCellView* cellview = [self viewAtColumn:i row:row makeIfNecessary:NO];
        if ([cellview.identifier isEqualToString:@"RegularExpressionCell"]) {
            data.pattern = cellview.textfield.stringValue;
        } else if ([cellview.identifier isEqualToString:@"EnableButtonCell"]) {
            CrawlerRuleTableCellEnableButton* button = cellview.enable_button;
            data.enabled = button.should_enable;
        }
    }
    if (! data.pattern || [data.pattern length] == 0) {
        Global::controller->currentTabWebpageCrawlerRuleTableRemoveRuleAsync(row);
    } else if (row == Global::controller->current_webpage_crawler_rule_table()->rulesCount())
    {
        CrawlerRule rule = CrawlerRule::fromString(QString::fromNSString(data.pattern));
        Global::controller->currentTabWebpageCrawlerRuleTableInsertRuleAsync(rule);
    } else {
        CrawlerRule rule = CrawlerRule::fromString(QString::fromNSString(data.pattern));
        rule.set_enabled(data.enabled);
        Global::controller->currentTabWebpageCrawlerRuleTableModifyRuleAsync(row, rule);
    }
}
@end

@implementation CrawlerRuleTableDataSource
{}
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    NSInteger count = Global::controller->current_webpage_crawler_rule_table()->rulesCount();
    return count + 1; // + 1 for new row
}
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    CrawlerRuleTableData* data = [[CrawlerRuleTableData alloc] init];
    int count = Global::controller->current_webpage_crawler_rule_table()->rulesCount();
    if (row >= count) {
        data.pattern = nil;
        data.enabled = false;
        data.matched = false;
        data.placeholder_line = true;
        return data;
    }
    CrawlerRule rule = Global::controller->current_webpage_crawler_rule_table()->rule(row);
    data.pattern = rule.toString().toNSString();
    data.enabled = rule.enabled();
    data.matched = rule.matched();
    data.placeholder_line = false;
    return data;
}
@end


@implementation CrawlerRuleTableCellTextField
{}
@synthesize table = m_table;
- (void)textDidEndEditing:(NSNotification *)notification
{
    [self.table handleRowEdited:self];
    [super textDidEndEditing:notification];
}
@end

@implementation CrawlerRuleTableCellEnableButton
{}
@synthesize should_enable = m_should_enable;
- (void)mouseDown:(NSEvent *)event
{
    if (self.state == NSControlStateValueOn) {
        self.should_enable = false;
    } else {
        self.should_enable = true;
    }
//    [self setNextState];
    [self.table handleRowEdited:self];
}

- (void)mouseUp:(NSEvent *)event
{
//    [self setNextState];
}
@end

@implementation CrawlerRuleTableCellMatchIndicator
@end

@implementation CrawlerRuleTableCellView
@synthesize enable_button = m_enable_button;
@synthesize textfield = m_textfield;
@synthesize match_indicator = m_match_indicator;
@end

@implementation CrawlerRuleTableColumn
@end

@implementation CrawlerRuleTableCellTextFieldHintPopover

//- (instancetype)init
//{
//    self = [super init];
//    self.contentViewController = [[NSViewController alloc] init];
//    NSSize size = self.contentSize;
//    size.height = 50;
//    size.width = 200;
//    self.contentSize = size;
//    NSVisualEffectView* rootView = [[NSVisualEffectView alloc] init];
//    NSRect rootFrame = rootView.frame;
//    rootFrame.size.height = 50;
//    rootFrame.size.width = 200;
//    rootView.frame = rootFrame;
//    NSTextField* text = [NSTextField labelWithString:@"Regular expression must match the current domain"];
//    NSFont* font = font
//    text.font.pointSize = kCTFontUIFontSmallSystem;
//    text.frame = rootView.bounds;
//    [rootView addSubview:text];
//    self.contentViewController.view = rootView;
//    return self;
//}

@end

