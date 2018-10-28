//
//  ErrorPage.m
//  Pointer
//
//  Created by Yu Li on 2018-10-27.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import "ErrorPage.h"
#include <docviewer/docviewer.h>
@implementation ErrorObjectController
@synthesize error_msg = m_error_msg;
@end

@implementation ErrorPageViewController
@synthesize error_msg = m_error_msg;
- (NSNibName)nibName
{
    return @"ErrorPage";
}
- (void)setErrorMessage:(NSString*)msg
{
    self->m_object_controller.error_msg = msg;
}
@end
