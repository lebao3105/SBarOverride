#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
// #import <Alderis/Alderis.h>
#ifdef DEBUG_RLOG
#import <RemoteLog.h>
#endif

static BOOL enabled; /* main toggle */
static BOOL enabledCarrier; /* custom carrier text toggle */
static NSString *customCarriertext; /* custom carrier text */
static BOOL enabledClock; /* custom clock text toggle */
static BOOL enabledClockFormat; /* custom clock format toggle */
static NSString *customtext; /* custom clock text */
static NSInteger batteryOptions; /* is the name not clear enough? */
static BOOL showMinusSign; /* for the battery text */
static UIColor *batteryTextColor;

%group SBarOverride
%hook _UIStatusBarStringView

- (void) setText:(id) text {

	#ifdef DEBUG_RLOG
	RLog(text);
	#endif

	if ([text rangeOfString:@":"].location != NSNotFound) {
		if (enabledClock) {
			NSString *target = customtext;
			if (enabledClockFormat) {
				NSDateFormatter *df = [[NSDateFormatter alloc] init];
				[df setDateFormat:customtext];
				target = [df stringFromDate:[NSDate date]];
			}
			return %orig(target);
		}
	}
	
	else if ([text rangeOfString:@"%"].location != NSNotFound) {
		if ((batteryOptions > (NSInteger)0) && (batteryOptions != (NSInteger)2)) {
			UIDevice *mydev = [UIDevice currentDevice];
			[mydev setBatteryMonitoringEnabled:YES];
			int left = (int)([mydev batteryLevel] * 100);
			NSString *target = [NSString stringWithFormat:@"%d%%", 100 - left];
			if (showMinusSign)
				return %orig([@"-" stringByAppendingString:target]);
			return %orig(target);
		}
	}

	else if (enabledCarrier)
		return %orig(customCarriertext);
	
	return %orig(text);
}

// - (void)setColor: (id)color {
// 	if (batteryTextColor)
// 		return %orig(batteryTextColor);
// 	return %orig(color);
// }

%end

%hook _UIBatteryView

- (void)setChargePercent: (CGFloat)percent {
	if (enabled && (batteryOptions >= (NSInteger)2)) {
		UIDevice *mydev = [UIDevice currentDevice];
		[mydev setBatteryMonitoringEnabled:YES];
		return %orig(1.0 - [mydev batteryLevel]);
	}
	return %orig(percent);
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
	showMinusSign = (prefs && [prefs objectForKey:@"showMinusSign"] ? [[prefs valueForKey:@"showMinusSign"] boolValue] : YES);
	// batteryTextColor = [[UIColor alloc] initWithHbcp_propertyListValue: [prefs objectForKey:@"batteryTextColor"]];
}

%ctor{
	preferencesChanged();

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
									NULL, (CFNotificationCallback)preferencesChanged,
									CFSTR("me.lebao3105.sbartweakprefsUpdated"),
									NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	if (enabled)
		%init(SBarOverride);
}
