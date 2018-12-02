//
//  GenericTextFieldPopover.h
//  Pointer
//
//  Created by Yu Li on 2018-12-01.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface GenericTextFieldPopoverViewController : NSViewController
@property NSString* title;
@property NSString* defaultText;
@property IBOutlet NSTextField* textField;
@property IBOutlet NSPopover* popover;
@property SEL handleApply;
@property SEL handleCancel;
@property NSObject* target;
- (IBAction)actionApply:(id)sender;
- (IBAction)actionCancel:(id)sender;
@end

NS_ASSUME_NONNULL_END
