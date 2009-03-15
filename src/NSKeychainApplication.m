/* ==================================================
* keyChainDD - Drag and drop Password Managerfor OS X
* ===================================================
*
* Project Info:  http://sourceforge.net/projects/keychaindd/
* Project Lead:  Sandy McGuffog (sandy.cornerfix@gmail.com or <sandymcg at users.sourceforge.net>);
*
* (C) Copyright 2009, by Sandy McGuffog and Contributors.
*
* This program is free software; you can redistribute it and/or modify it under the terms
* of the GNU General Public License as published by the Free Software Foundation;
* either version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
* without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
* See the GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License along with this
* library; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
* Boston, MA 02111-1307, USA.
*
* -------------------------------------
* NSKeychainApplication.m
* -------------------------------------
* (C) Copyright 2009, by Sandy McGuffog and Contributors.
*
* Original Author:  Sandy McGuffog;
* Contributor(s):   -;
*
* Changes
* -------
* 3 March 2009 : Original version;
*
*/

/*
* Application class with Services menu implementation
*/

#import "NSKeychainApplication.h"


@implementation NSKeychainApplication


- (void) cachePreferences {	
	
	float temp;
	
	// We are using 30 second ticks.......so multiply by two
	temp = 1.0 + 0.006*pow(((float) [[NSUserDefaults standardUserDefaults] integerForKey:@"keychainTimeOut"]), 2.0);
	keychainTimeOutCache = (int) (temp*2.0);
	temp = 1.0 + 0.006*pow(((float) [[NSUserDefaults standardUserDefaults] integerForKey:@"MIDrawerTimeOut"]), 2.0);
	MIDrawerTimeOutCache = (int) (temp*2.0);
	
}

- (id)init
{
    if (self == [super init])
    {
		applicationState = KDDApplicationInit;
		// Set for 30 Second ticks
		lockTimer = [NSTimer scheduledTimerWithTimeInterval: 30 
														   target: self 
														 selector: @selector(timedLock:) 
														 userInfo: 0 
														  repeats: YES];
		keyChainTimerVal = 0;
		MIDrawerTimerVal = 0;
#if __debug
		NSLog(@"KeyChainDD init");
#endif
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(userPreferencesChanged:)
													 name:@"UserPreferencesChanged" object:nil];
		
		[self cachePreferences];
		
    }
    return self;		
}

// Application deligate stuff...

- (int)requestUserAttention:(NSRequestUserAttentionType)requestType
{
	// No bouncing in the dock....
	return 0;
}


- (void) sendEvent:(NSEvent*)event
{	
	switch ([event type]) {
		case	NSLeftMouseDown:
		case	NSRightMouseDown:
		case	NSLeftMouseDragged:
		case	NSRightMouseDragged:
		case	NSKeyDown:
			keyChainTimerVal = 0;
			MIDrawerTimerVal = 0;
	}

	[super sendEvent:event];
}


- (void) timedLock: (id)sender
{
	
	if (keyChainTimerVal >= keychainTimeOutCache) {		
	#if __debug
			NSLog(@"KeyChaintimedLock");
	#endif
		[[NSNotificationCenter defaultCenter]  postNotificationName:@"KeychainDDTimeOut" object:nil];
		keyChainTimerVal = -1;
	}
	if (MIDrawerTimerVal >= MIDrawerTimeOutCache) {
#if __debug
		NSLog(@"MIDrawertimedLock");
#endif
		[[NSNotificationCenter defaultCenter]  postNotificationName:@"MIDrawerTimeOut" object:nil];
		MIDrawerTimerVal = -1;
	}
	keyChainTimerVal++;
	MIDrawerTimerVal++;
}
	

- (void)logState
{
	switch (applicationState) {
		case KDDApplicationInit:
			NSLog(@"KDDApplicationInit");
			break;
		case KDDApplicationStartFromServices:
			NSLog(@"KDDApplicationStartFromServices");
			break;
		case KDDApplicationStartFromCommand:
			NSLog(@"KDDApplicationStartFromCommand");
			break;
		case KDDApplicationRunning:
			NSLog(@"KDDApplicationRunning");
			break;
				}
}	

// Application state tracking

- (int) startServicesCall
{
#if __debug
	NSLog(@"startServicesCall");
#endif
	int oldState = applicationState;
	switch (applicationState) {
		case KDDApplicationInit:
			applicationState = KDDApplicationStartFromServices;
			break;
		case KDDApplicationStartFromServices:
			applicationState = KDDApplicationStartFromServices;
			break;
		case KDDApplicationStartFromCommand:
			applicationState = KDDApplicationStartFromCommand;
			break;
		case KDDApplicationRunning:
			applicationState = KDDApplicationRunning;
			break;
				}	
	
#if __debug
	[self logState];
#endif
	return oldState;
}

- (int) endServicesCall
{
#if __debug
	NSLog(@"endServicesCall");
#endif
	int oldState = applicationState;
	switch (applicationState) {
		case KDDApplicationInit:
			applicationState = KDDApplicationStartFromServices;
			break;
		case KDDApplicationStartFromServices:
			applicationState = KDDApplicationInit;
			break;
		case KDDApplicationStartFromCommand:
			applicationState = KDDApplicationStartFromCommand;
			break;
		case KDDApplicationRunning:
			applicationState = KDDApplicationRunning;
			break;
				}	
	
#if __debug
	[self logState];
#endif
	return oldState;
}


- (int) activeCall
{
	int oldState = applicationState;
#if __debug
	NSLog(@"activeCall");
#endif
	switch (applicationState) {
		case KDDApplicationInit:
			applicationState = KDDApplicationStartFromCommand;
			break;
		case KDDApplicationStartFromServices:
			applicationState = KDDApplicationStartFromServices;
			break;
		case KDDApplicationStartFromCommand:
			applicationState = KDDApplicationRunning;
			break;
		case KDDApplicationRunning:
			applicationState = KDDApplicationRunning;
			break;
				}	

#if __debug
	[self logState];
#endif
	return oldState;
}

- (int) getState
{
	return applicationState;
}

// Notification handlers
//
// These intercept and handle the various notification lying around
// 
//

- (void)userPreferencesChanged:(NSNotification *)notification
{
#if __debug
	NSLog(@"%s: %s", __FUNCTION__, [((NSString *) [notification object]) UTF8String]);
#endif
	[self cachePreferences];

}


@end
