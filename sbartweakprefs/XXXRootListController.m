#import <Foundation/Foundation.h>
#import "XXXRootListController.h"
#import <spawn.h>

@implementation XXXRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

- (void) killSpringBoard {
	pid_t pid;
	const char* args[] = {
		"killall", "-9", "SpringBoard"
	};
	posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
}

@end
