#import "XXXTDateListController.h"

@implementation XXXTDateListController

- (NSArray *)specifiers {
    if (!_specifiers)
        _specifiers = [self loadSpecifiersFromPlistName:@"ClockSettings" target:self];
    return _specifiers;
}

@end