//
//  ErrorPage.h
//  Pointer
//
//  Created by Yu Li on 2018-10-27.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "Extension/PViewController.h"
#include <docviewer/docviewer.h>

NS_ASSUME_NONNULL_BEGIN

@interface ErrorPageViewController : PViewController
@property IBOutlet NSButton* yesButton;
@property IBOutlet NSButton* noButton;
@property IBOutlet NSTextField* titleTextField;
@property IBOutlet NSTextField* messageTextField;
- (void)showWithTitle:(NSString*)title
              message:(NSString*)message
            yesTarget:(id)yesTarget
          yesSelector:(SEL)yesSelector
             noTarget:(id)noTarget
           noSelector:(SEL)noSelector;
- (void)hide;
@end

NS_ASSUME_NONNULL_END
