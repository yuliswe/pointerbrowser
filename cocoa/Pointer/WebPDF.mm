//
//  WebPDF.m
//  Pointer
//
//  Created by Yu Li on 2019-03-15.
//  Copyright © 2019 Yu Li. All rights reserved.
//

#import "WebPDF.h"
#import "WebUI.mm.h"
#include <docviewer/docviewer.h>

@implementation WebPDF

- (instancetype)initWithWebUI:(WebUI*)parent {
    self = [super init];
    self.webUI = parent;
    self.acceptsTouchEvents = NO;
    self.autoScales = YES;
    self.touches = [[NSMutableDictionary alloc] init];
    return self;
}

- (void)drawHighlightOnFindText {
    [self setHighlightedSelections:nil];
    self.current_find_highlights = [self.document findString:self.current_find_text withOptions:NSCaseInsensitiveSearch];
    Global::controller->updateWebpageFindTextFoundAsync(self.webUI.webpage, self.current_find_highlights.count);
    for (PDFSelection* sel in self.current_find_highlights) {
        sel.color = NSColor.systemYellowColor;
    }
    [self setHighlightedSelections:self.current_find_highlights];
}

- (void)drawHighlightOnCurrentText {
    PDFSelection* current = [self.current_find_highlights[self.current_find_index] copy];
    current.color = NSColor.systemOrangeColor;
    [self clearSelection];
    [self setCurrentSelection:current animate:NO];
    [self scrollSelectionToVisible:self];
}

- (void)findHighlightAll:(NSString*)text {
    [self findClear];
    self.current_find_text = text;
    [self drawHighlightOnFindText];
}

- (void)findClear {
    self.current_find_highlights = nil;
    self.current_find_index = -1;
    [self clearSelection];
    [self setHighlightedSelections:nil];
}

- (void)findScrollToNextHighlight {
    if (self.current_find_highlights.count == 0) { return; }
    if (self.current_find_index < 0
        || self.current_find_index >= self.current_find_highlights.count - 1)
    {
        self.current_find_index = 0;
    } else {
        self.current_find_index += 1;
    }
    [self drawHighlightOnCurrentText];
}

- (void)findScrollToPreviousHighlight {
    if (self.current_find_highlights.count == 0) { return; }
    if (self.current_find_index <= 0)
    {
        self.current_find_index = self.current_find_highlights.count - 1;
    } else {
        self.current_find_index -= 1;
    }
    [self drawHighlightOnCurrentText];
}

// not used

- (void)touchesBeganWithEvent:(NSEvent *)event {
    NSSet<NSTouch*>* touches = [event touchesMatchingPhase:NSTouchPhaseBegan inView:self];
    [touches enumerateObjectsUsingBlock:^(NSTouch * _Nonnull obj, BOOL * _Nonnull stop) {
        self.touches[obj.identity] = obj;
    }];
}

- (void)touchesEndedWithEvent:(NSEvent *)event {
    NSSet<NSTouch*>* touches = [event touchesMatchingPhase:NSTouchPhaseEnded inView:self];
    [touches enumerateObjectsUsingBlock:^(NSTouch * _Nonnull obj, BOOL * _Nonnull stop) {
        self.touches[obj.identity] = nil;
    }];
}

- (void)touchesMovedWithEvent:(NSEvent *)event {
    NSSet<NSTouch*>* touches = [event touchesMatchingPhase:NSTouchPhaseTouching inView:self];
    if (touches.count == 2) {
        __block float delta_x = 0;
        __block float delta_y = 0;
        [touches.allObjects enumerateObjectsUsingBlock:^(NSTouch * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            float dx = obj.normalizedPosition.x - self.touches[obj.identity].normalizedPosition.x;
            float dy = obj.normalizedPosition.y - self.touches[obj.identity].normalizedPosition.y;
            delta_x += dx;
            delta_y += dy;
        }];
        delta_x /= 2;
        delta_y /= 2;
//        NSSet<NSTouch*>* touches_1 = [touches filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"identity == %@", self.touch_1.identity]];
//        NSSet<NSTouch*>* touches_2 = [touches filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"identity == %@", self.touch_2.identity]];
        NSLog(@"%f %f", delta_x, delta_y);
        if (abs(delta_y) < 0.1 && delta_x > 0.1) {
            [self.webUI goBack];
        }
    }
}

@end
