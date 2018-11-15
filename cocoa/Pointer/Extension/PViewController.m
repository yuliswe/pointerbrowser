//
//  PViewController.m
//  Pointer
//
//  Created by Yu Li on 2018-10-27.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import "PViewController.h"

@implementation PViewController
- (void)loadView {
    [super loadView];
    self.view.frame = self.parentView.bounds;
    self.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.parentView addSubview:self.view];
}
@end
