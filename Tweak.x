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
static NSInteger batteryOptions;

@interface _UIStatusBarStringView: UILabel
@property (nonatomic, assign, readwrite) BOOL isCarrier;
@end

@interface _UIBatteryView: UIView
@end

%group SBarOverride
%hook _UIStatusBarStringView

- (void) setText:(id) text {

	if (enabled == YES) {
		#ifdef DEBUG_RLOG
		RLog(text);
		#endif

		if (enabledCarrier && [self isCarrier])
			return %orig(customCarriertext);

		if (enabledClock) {
			if ([text rangeOfString:@":"].location != NSNotFound) {
				NSString *target;
				if (enabledClockFormat == YES) {
					NSDateFormatter *df = [[NSDateFormatter alloc] init];
					NSDate *date = [NSDate date];
					[df setDateFormat:customtext];
					target = [df stringFromDate:date];
				} else {
					target = customtext;
				}
				return %orig(target);
			}
		}
		
		if (batteryOptions > (NSInteger)0) {
			if ([text rangeOfString:@"%"].location != NSNotFound) {
				UIDevice *mydev = [UIDevice currentDevice];
				[mydev setBatteryMonitoringEnabled:YES];
				int left = (int)([mydev batteryLevel] * 100);
				NSString *target = [NSString stringWithFormat:@"-%d%%", 100 - left];
				return %orig(target);
			}
		}
	}
	
	return %orig;
}

%end

%hook _UIBatteryView

- (void)setChargePercent: (CGFloat)percent {
	if (enabled && (batteryOptions >= (NSInteger)2)) {
		UIDevice *mydev = [UIDevice currentDevice];
		[mydev setBatteryMonitoringEnabled:YES];
		return %orig(1.0 - [mydev batteryLevel]);
	}
	return %orig;
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
	batteryOptions = (prefs && [prefs objectForKey:@"batteryOptions"] ? [[prefs valueForKey:@"batteryOptions"] integerValue] : 0);
}

%ctor{
	preferencesChanged();

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
									NULL, (CFNotificationCallback)preferencesChanged,
									CFSTR("me.lebao3105.sbartweakprefsUpdated"),
									NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	%init(SBarOverride);
}
