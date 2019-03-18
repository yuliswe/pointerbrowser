//
//  WebFindText.h
//  Pointer
//
//  Created by Yu Li on 2019-03-16.
//  Copyright © 2019 Yu Li. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Extension/Extension.h"

NS_ASSUME_NONNULL_BEGIN
@class WebFindTextCell;
@class WebFindTextLabel;

@interface WebFindText : PSearchField<NSSearchFieldDelegate>
@property IBOutlet WebFindTextLabel* label;
- (void)updateLabel:(NSUInteger)found;
@end

@interface WebFindTextLabel : PTextField
@end

@interface WebFindTextCell : NSSearchFieldCell
@property IBOutlet WebFindText* searchField;
@property IBOutlet WebFindTextLabel* label;
@end

NS_ASSUME_NONNULL_END
