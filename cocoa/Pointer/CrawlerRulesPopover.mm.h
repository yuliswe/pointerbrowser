//
//  CrawlerRulesPopover.h
//  Pointer
//
//  Created by Yu Li on 2018-09-05.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CrawlerRuleTableCellView;
@class CrawlerRulesPopover;
@class CrawlerRulesPopoverContentViewController;
@class CrawlerRuleTableDelegate;
@class CrawlerRuleTableDataSource;
@class CrawlerRuleTableCellTextFieldHintPopover;


@interface CrawlerRulesPopover : NSPopover
{
    IBOutlet NSButton* m_caller_button;
}

@property NSButton* caller_button;
@end

@interface CrawlerRuleTableView : NSTableView
{
    IBOutlet CrawlerRuleTableCellTextFieldHintPopover* m_hint_popover;
}
- (IBAction)handleRowEdited:(id)sender;
@end


@interface CrawlerRulesPopoverContentViewController : NSViewController
{
    NSPopover* m_popover;
    IBOutlet CrawlerRuleTableView* m_table;
    IBOutlet NSTextField* m_table_title_textfield;
}

@property NSPopover* popover;
@property CrawlerRuleTableView* table;
@property NSTextField* table_title_textfield;
- (instancetype)initWithPopover:(NSPopover*)popover;
@end

@interface CrawlerRuleTableDelegate : NSObject<NSTableViewDelegate>
{}
@end

@interface CrawlerRuleTableData : NSObject
{
    NSString* m_pattern;
    bool m_enabled;
    bool m_matched;
    bool m_placeholder_line;
}
@property NSString* pattern;
@property bool enabled;
@property bool matched;
@property bool placeholder_line;
@end

@interface CrawlerRuleTableDataSource : NSObject<NSTableViewDataSource>
{}
@end

@interface CrawlerRuleTableCellTextField : NSTextField
{
    IBOutlet CrawlerRuleTableView* m_table;
}
@property CrawlerRuleTableView* table;
@end


@interface CrawlerRuleTableCellTextFieldHintPopover : NSPopover
{
}
@end

@interface CrawlerRuleTableCellEnableButton : NSButton
{
    IBOutlet CrawlerRuleTableView* m_table;
    bool m_should_enable;
}
@property CrawlerRuleTableView* table;
@property bool should_enable;
@end


@interface CrawlerRuleTableCellMatchIndicator : NSButton
{
    IBOutlet CrawlerRuleTableView* m_table;
}
@property CrawlerRuleTableView* table;
@end


@interface CrawlerRuleTableCellView : NSTableCellView
{
    IBOutlet CrawlerRuleTableCellTextField* m_textfield;
    IBOutlet CrawlerRuleTableCellEnableButton* m_enable_button;
    IBOutlet CrawlerRuleTableCellMatchIndicator* m_match_indicator;
}
@property CrawlerRuleTableCellTextField* textfield;
@property CrawlerRuleTableCellEnableButton* enable_button;
@property CrawlerRuleTableCellMatchIndicator* match_indicator;
@end

@interface CrawlerRuleTableColumn : NSTableColumn
@end
