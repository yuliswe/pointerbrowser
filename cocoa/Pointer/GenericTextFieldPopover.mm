//
//  GenericTextFieldPopover.m
//  Pointer
//
//  Created by Yu Li on 2018-12-01.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import "GenericTextFieldPopover.h"
#include <docviewer/docviewer.h>

@implementation GenericTextFieldPopoverViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    Global::controller->replaceConnection("GenericTextFieldPopoverViewController_CloseAllPopovers", QObject::connect(Global::controller, &Controller::signal_tf_close_all_popovers, [=]() {
        [self.popover performSelectorOnMainThread:@selector(close) withObject:nil waitUntilDone:YES];
    }));
}

- (void)viewDidAppear {
    [super viewDidAppear];
    self.textField.stringValue = self.defaultText;
}

- (NSNibName)nibName
{
    return @"GenericTextFieldPopover";
}

- (IBAction)actionApply:(id)sender
{
    if (self.handleApply) {
        [self.target performSelector:self.handleApply withObject:self];
    }
    [self.popover close];
}

- (IBAction)actionCancel:(id)sender
{
    if (self.handleCancel) {
        [self.target performSelector:self.handleCancel withObject:self];
    }
    [self.popover close];
}
@end
