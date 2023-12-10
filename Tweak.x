#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#ifdef DEBUG_RLOG
#import <RemoteLog.h>
#endif

/*
	Tweak settings
	All toggles are OFF by default!
*/
static BOOL enabled; /* main toggle */
static BOOL enabledCarrier; /* custom carrier text toggle */
static NSString *customCarriertext; /* custom carrier text */
static BOOL enabledClock; /* custom clock text toggle */
static BOOL enabledClockFormat; /* custom clock format toggle */
static NSString *customtext; /* custom clock text */
static BOOL enabledBPercent; /* battery percentage text hook toggle */
static BOOL showUsedBP; /* show used battery percents */

@interface _UIStatusBarStringView: UILabel
@property (nonatomic, assign, readwrite) BOOL isCarrier;
// @property UIView *superview;
@end

%group SBarOverride
%hook _UIStatusBarStringView

- (void) setText:(id) text {

	if (enabled == YES) {
		#ifdef DEBUG_RLOG
		RLog(text);
		#endif

		if ((enabledCarrier == YES) && ([self isCarrier] == YES))
			return %orig(customCarriertext);

		if (enabledClock == YES) {
			if ([text rangeOfString:@":"].location != NSNotFound) {
				NSString *target;
				if (enabledClockFormat == YES) {
					NSDateFormatter *df = [[NSDateFormatter alloc] init];
					NSDate *date = [NSDate date];
					[df setDateFormat:customtext];
					target = [df stringFromDate:date];
				}
				return %orig(target);
			}
		}
		
		if ((enabledBPercent == YES) && (showUsedBP == YES)) {
			if ([text rangeOfString:@"%"].location != NSNotFound) {
				UIDevice *mydev = [UIDevice currentDevice];
				[mydev setBatteryMonitoringEnabled:YES];
				int left = (int)([mydev batteryLevel] * 100);
				NSString *target = [NSString stringWithFormat:@"-%d%%", 100 - left];
				return %orig(target);
			}
		}
	}
	
	else {
		return %orig;
	}
}

%end
%end

void preferencesChanged() {
	NSDictionary *prefs = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"me.lebao3105.sbartweakprefs"];
	enabled = (prefs && [prefs objectForKey:@"enabled"] ? [[prefs valueForKey:@"enabled"] boolValue] : NO);
	enabledCarrier = (prefs && [prefs objectForKey:@"enabledCarrier"] ? [[prefs valueForKey:@"enabledCarrier"] boolValue] : NO);
	customCarriertext = [prefs objectForKey:@"customCarriertext"];
	enabledClock = (prefs && [prefs objectForKey:@"enabledClock"] ? [[prefs valueForKey:@"enabledClock"] boolValue] : NO);
	enabledClockFormat = (prefs && [prefs objectForKey:@"enabledClockFormat"] ? [[prefs valueForKey:@"enabledClockFormat"] boolValue] : NO);
	customtext = [prefs objectForKey:@"customtext"];
	enabledBPercent = (prefs && [prefs objectForKey:@"enabledBPercent"] ? [[prefs valueForKey:@"enabledBPercent"] boolValue] : NO);
	showUsedBP = (prefs && [prefs objectForKey:@"showUsedBP"] ? [[prefs valueForKey:@"showUsedBP"] boolValue] : NO);
}

%ctor{
	preferencesChanged();

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
									NULL, (CFNotificationCallback)preferencesChanged,
									CFSTR("me.lebao3105.sbartweakprefsUpdated"),
									NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	%init(SBarOverride);
}
