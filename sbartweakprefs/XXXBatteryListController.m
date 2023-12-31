#import "XXXBatteryListController.h"

@implementation XXXBatteryListController

- (NSArray *)specifiers {
    if (!_specifiers)
        _specifiers = [self loadSpecifiersFromPlistName:@"BatterySettings" target:self];
    return _specifiers;
}

@end