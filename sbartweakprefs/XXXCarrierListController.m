#import "XXXCarrierListController.h"

@implementation XXXCarrierListController

- (NSArray *)specifiers {
    if (!_specifiers)
        _specifiers = [self loadSpecifiersFromPlistName:@"CarrierSettings" target:self];
    return _specifiers;
}

@end