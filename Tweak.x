#import <UIKit/UIKit.h>

// @interface _UIStatusBarForegroundView: UIView
// @end

// %hook _UIStatusBarForegroundView

// - (void) didMoveToWindow {
// 	%orig;
// 	_UIStatusBarStringView *label = [self.subviews objectAtIndex:5];
// 	// label.text = @"Hello world";
// 	label.hidden = YES;
// }

// %end

static BOOL enabled;
static NSString *customtext;
static NSString *clockformat;

@interface _UIStatusBarStringView: UILabel
@end

%hook _UIStatusBarStringView

- (void) setText:(id) text {
	if (enabled != NO) {
		if ([text rangeOfString: [NSString stringWithFormat:@"%s", ":"]].location != NSNotFound)
			self.hidden = YES;
		%orig(customtext);
	} else {
		%orig;
	}
}

%end

void preferencesChanged() {
	NSDictionary *prefs = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"me.lebao3105.sbartweakprefs"];
	enabled = (prefs && [prefs objectForKey:@"enabled"] ? [[prefs valueForKey:@"enabled"] boolValue] : YES);
	customtext = [prefs objectForKey:@"customtext"];
	clockformat = [prefs objectForKey:@"clockformat"];
}

%ctor{
	preferencesChanged();

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
									NULL, (CFNotificationCallback)preferencesChanged,
									CFSTR("me.lebao3105.sbartweakprefsUpdated"),
									NULL, CFNotificationSuspensionBehaviorDeliverImmediately
	);
}