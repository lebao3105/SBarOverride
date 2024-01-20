#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "UIColor+SBO.h"

#ifdef DEBUG_RLOG
#import <RemoteLog.h>
#endif

BOOL enabled; /* main toggle */
BOOL enabledCarrier; /* custom carrier text toggle */
NSString *customCarriertext; /* custom carrier text */
BOOL enabledClock; /* custom clock text toggle */
BOOL enabledClockFormat; /* custom clock format toggle */
NSString *customtext; /* custom clock text */
NSInteger batteryOptions; /* is the name not clear enough? */
BOOL showMinusSign; /* for the battery text */
/* Colors */
UIColor *carrierTextColor;
UIColor *clockTextColor;
UIColor *batteryTextColor;

@interface _UIStatusBarStringView: UILabel
@property (nonatomic) int SBO_kindOfLabel;
@end

%group SBarOverride
%hook _UIStatusBarStringView

// you will know what does it do
%property (nonatomic) int SBO_kindOfLabel;

- (void) setText:(id) text {

	#ifdef DEBUG_RLOG
	RLog(text);
	#endif

	if ([text rangeOfString:@":"].location != NSNotFound) {
		if (enabledClock) {
			self.SBO_kindOfLabel = 0;
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
			self.SBO_kindOfLabel = 1;
			UIDevice *mydev = [UIDevice currentDevice];
			[mydev setBatteryMonitoringEnabled:YES];
			int left = (int)([mydev batteryLevel] * 100);
			NSString *target = [NSString stringWithFormat:@"%d%%", 100 - left];
			if (showMinusSign)
				return %orig([@"-" stringByAppendingString:target]);
			return %orig(target);
		}
	}

	else if (enabledCarrier) {
		self.SBO_kindOfLabel = 2;
		return %orig(customCarriertext);
	}
	
	return %orig(text);
}

- (void)setTextColor: (id)color {
	switch (self.SBO_kindOfLabel) {
		case 0:
			if (carrierTextColor) return %orig(carrierTextColor);
		case 1:
			if (batteryTextColor) return %orig(batteryTextColor);
		case 2:
			if (clockTextColor) return %orig(clockTextColor);
	}
	return %orig(color);
}

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
	// do these checks to avoid SpringBoard to crash
	if ([prefs objectForKey:@"carrierTextColor"])
		carrierTextColor = [UIColor colorFromHexString: [prefs objectForKey:@"carrierTextColor"]];
	if ([prefs objectForKey:@"clockTextColor"])
		clockTextColor = [UIColor colorFromHexString: [prefs objectForKey:@"clockTextColor"]];
	if ([prefs objectForKey:@"batteryTextColor"])
		batteryTextColor = [UIColor colorFromHexString: [prefs objectForKey:@"batteryTextColor"]];
}

%ctor{
	preferencesChanged();

	// CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
	// 								NULL, (CFNotificationCallback)preferencesChanged,
	// 								CFSTR("me.lebao3105.sbartweakprefsUpdated"),
	// 								NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

	if (enabled)
		%init(SBarOverride);
}
