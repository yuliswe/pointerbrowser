//
//  WebFindText.m
//  Pointer
//
//  Created by Yu Li on 2019-03-16.
//  Copyright © 2019 Yu Li. All rights reserved.
//

#import "WebFindText.h"

@implementation WebFindText

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    self.delegate = self;
    return self;
}

- (void)textDidBeginEditing:(NSNotification *)notification
{
    self.label.hidden = NO;
    return [super textDidBeginEditing:notification];
}

- (void)updateLabel:(NSUInteger)found {
    self.label.hidden = found == -1;
    if (found == -1) { found = 0; }
    self.label.stringValue = [NSString stringWithFormat:@"%d found", found];
}
@end

@implementation WebFindTextCell

- (NSRect)drawingRectForBounds:(NSRect)rect {
    if (self.label.hidden) {
        return [super drawingRectForBounds:rect];
    }
    int label_width = self.label.intrinsicContentSize.width;
    NSRect rectInset = NSMakeRect(rect.origin.x + 1, rect.origin.y, rect.size.width - label_width - 10, rect.size.height);
    return [super drawingRectForBounds:rectInset];
}

// MACOS 10.14.3 可能有bug, 不知道为什么这个method必须被override
// 不然以下bug可能发生--重复动作:
// 在search field中输入长于最长显示长度的文字，然后用鼠标点击外面取消focus，文字会溢出
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    [super drawWithFrame:cellFrame inView:controlView];
}

@end

@implementation WebFindTextLabel
@end

