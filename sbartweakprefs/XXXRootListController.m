#import <Foundation/Foundation.h>
#import <spawn.h>
#import <rootless.h>
#import "XXXRootListController.h"

@implementation XXXRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

- (void)reSpring {
	pid_t pid;
	int status;
	const char* args[] = {"killall", "-9", "SpringBoard", NULL};
	posix_spawn(&pid, ROOT_PATH("/usr/bin/killall"), NULL, NULL, (char* const*)args, NULL);
	waitpid(pid, &status, WEXITED);
}

- (NSString *)getVersion:(PSSpecifier *)specifier {
	return @"1.2.0";
}

- (NSString *)getBuild:(PSSpecifier *)specifier {
#ifdef DEV_BUILD
	return @"Dev";
#else
	return @"Final";
#endif
}

@end
