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

@interface ErrorObjectController : NSObjectController
{
    NSString* m_error_msg;
}
@property NSString* error_msg;
@end

@interface ErrorPageViewController : PViewController
{
    NSString* m_error_msg;
    IBOutlet ErrorObjectController* m_object_controller;
}
@property NSString* error_msg;
//- (void)setErrorMessage:(NSString*)msg;
@end

NS_ASSUME_NONNULL_END
