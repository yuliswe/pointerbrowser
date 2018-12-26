//
//  ErrorPage.m
//  Pointer
//
//  Created by Yu Li on 2018-10-27.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import "ErrorPage.h"
#include <docviewer/docviewer.h>

@implementation ErrorPageViewController
- (NSNibName)nibName
{
    return @"ErrorPage";
}
- (void)showWithTitle:(NSString*)title
              message:(NSString*)message
            yesTarget:(id)yesTarget
          yesSelector:(SEL)yesSelector
             noTarget:(id)noTarget
           noSelector:(SEL)noSelector
{
    self.titleTextField.stringValue = title;
    self.messageTextField.stringValue = message;
    self.yesButton.hidden = ! (yesTarget && yesSelector);
    self.noButton.hidden = ! (noTarget && noSelector);
    self.yesButton.target = yesTarget;
    self.yesButton.action = yesSelector;
    self.noButton.target = noTarget;
    self.noButton.action = noSelector;
    self.view.hidden = NO;
}
- (void)hide
{
    self.view.hidden = YES;
}
@end
