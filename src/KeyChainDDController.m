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
* KeyChainDDController.m
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
* Controller
*/


#import "KeyChainDDController.h"
#import "NSKeychainApplication.h"
#include <Security/SecKeychain.h>
#include <Security/SecKeychainItem.h>
#include <Security/SecAccess.h>
#include <Security/SecTrustedApplication.h>
#include <Security/SecACL.h>
#import "PrefsWindowController.h"

OSStatus keychain_locked(SecKeychainEvent keychainEvent, SecKeychainCallbackInfo *info, void *context);
OSStatus keychain_unlocked(SecKeychainEvent keychainEvent, SecKeychainCallbackInfo *info, void *context);
OSStatus keychain_changed(SecKeychainEvent keychainEvent, SecKeychainCallbackInfo *info, void *context);

#define kNumStartsToNag 50
const float splashScreenDelayInSeconds = 1.0;
const int splashScreenStartValue = 230;
const int splashScreenFadeDelay = 90;

@implementation KeyChainDDController


- (id)init
{

    if (self == [super init])
    {
		// Now we need to register the various defaults for the preferences 
		
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		NSMutableDictionary *appDefaults = [NSMutableDictionary dictionary];
		
		[appDefaults setObject:@"NO" forKey:@"alwaysOnTop"];
		[appDefaults setObject:@"NO" forKey:@"autoOpenMIDrawer"];
		[appDefaults setObject:@"NO" forKey:@"plainTextMIDrawer"];
		[appDefaults setObject:[NSNumber numberWithInt:25] forKey:@"keychainTimeOut"];
		[appDefaults setObject:[NSNumber numberWithInt:25] forKey:@"MIDrawerTimeOut"];
		[appDefaults setObject:@"NO" forKey:@"enablePaste"];
		[appDefaults setObject:[NSNumber numberWithInt:0] forKey:@"numberOfStarts"];

		[userDefaults registerDefaults:appDefaults];
		
		// And now configure observers such that we can handle cached preferences
		[userDefaults addObserver:self
					   forKeyPath:@"alwaysOnTop"
						  options:(NSKeyValueObservingOptionNew |
								   NSKeyValueObservingOptionOld)
						  context:NULL];	
		[userDefaults addObserver:self
					   forKeyPath:@"autoOpenMIDrawer"
						  options:(NSKeyValueObservingOptionNew |
								   NSKeyValueObservingOptionOld)
						  context:NULL];	
		[userDefaults addObserver:self
					   forKeyPath:@"plainTextMIDrawer"
						  options:(NSKeyValueObservingOptionNew |
								   NSKeyValueObservingOptionOld)
						  context:NULL];	
		[userDefaults addObserver:self
					   forKeyPath:@"keychainTimeOut"
						  options:(NSKeyValueObservingOptionNew |
								   NSKeyValueObservingOptionOld)
						  context:NULL];	
		[userDefaults addObserver:self
					   forKeyPath:@"MIDrawerTimeOut"
						  options:(NSKeyValueObservingOptionNew |
								   NSKeyValueObservingOptionOld)
						  context:NULL];
		[userDefaults addObserver:self
					   forKeyPath:@"enablePaste"
						  options:(NSKeyValueObservingOptionNew |
								   NSKeyValueObservingOptionOld)
						  context:NULL];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(disableMenuItems:)
													 name:@"DisableMenus" 
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(enableMenuItems:)
													 name:@"EnableMenus" 
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(itemOnPasteboard:)
													 name:@"ItemOnPasteboard" 
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(appleKeychainLocked:)
													 name:@"AppleKeychainLocked" object:nil];
		pboardCount = INT_MAX;
		splashScreenPanel = nil;
	}	
	return self;
}


- (void)splashTimerFireMethod:(id)unused
{
	if (splashScreenCountDown > 0) {
		splashScreenCountDown--;
		if (splashScreenCountDown < (splashScreenStartValue - splashScreenFadeDelay)) {
			[splashScreenPanel setAlphaValue:(float)splashScreenCountDown/(splashScreenStartValue - splashScreenFadeDelay)];
		}
	}
	else {
		if (splashScreenTimer) {
			[splashScreenTimer invalidate];
			splashScreenTimer = nil;
		}
		if (splashScreenPanel) {
			[splashScreenPanel release];
			splashScreenPanel = nil;
		}
	}
}

- (void)startSplashScreenPanel:(id)sender
{
#if __debug
	NSLog(@"%s called", __FUNCTION__);
#endif
	if (!splashScreenPanel) [NSBundle loadNibNamed:@"SplashScreen" owner:self];	
	[splashScreenPanel orderFront:self];
	splashScreenCountDown = splashScreenStartValue;
	splashScreenTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 
														 target:self 
													   selector:@selector(splashTimerFireMethod:) 
													   userInfo:nil 
														repeats:YES];
}

- (void) awakeFromNib {			
#if __debug
	NSLog(@"%s called", __FUNCTION__);
#endif
	if ([window respondsToSelector:@selector(setBottomCornerRounded:)]) {
		[window performSelector:@selector(setBottomCornerRounded:) withObject:NO];
	}
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"alwaysOnTop"]) {
		[window setLevel:NSFloatingWindowLevel];
	}
	disableMenus = NO;
}

//App delegate stuff
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
#if __debug
	NSLog(@"%s called", __FUNCTION__);
#endif
	int state = [((NSKeychainApplication*) NSApp) getState];
	if ((state == KDDApplicationInit) || (state == KDDApplicationStartFromServices)) {
		return NO;
	}
	else {
		return YES;	
	}
}

- (void)applicationWillBecomeActive:(NSNotification *)aNotification
{
#if __debug
	NSLog(@"%s called", __FUNCTION__);
#endif
	if ([((NSKeychainApplication*) NSApp) activeCall] == KDDApplicationStartFromServices) {
		NSLog(@"[window miniaturize:self]");		
//		[window miniaturize:self];
	}
	else {
		[window orderFront:self];
	}
	[mainMenu update];
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
#if __debug
	NSLog(@"application applicationDidFinishLaunching");		
#endif
	SecKeychainAddCallback(&keychain_locked, kSecLockEventMask, nil);
	SecKeychainAddCallback(&keychain_unlocked, kSecUnlockEventMask, nil);
	SecKeychainAddCallback(&keychain_changed,
						   kSecAddEventMask |
						   kSecDeleteEventMask |
						   kSecUpdateEventMask |
						   kSecKeychainListChangedMask,
						   nil);	
	//Uncomment to start everytime......
//	[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"numberOfStarts"];
	
	int numStarts = [[NSUserDefaults standardUserDefaults] integerForKey:@"numberOfStarts"];
	if (numStarts <= kNumStartsToNag)
	{
		if (numStarts == 0)
		{
			// Try to make sure that we show up in the services menu immediately
			NSUpdateDynamicServices();
			
			//Say hi....
			[self performSelector:@selector(startSplashScreenPanel:) 
					   withObject:nil 
					   afterDelay:splashScreenDelayInSeconds];
		}
		else if (numStarts >= kNumStartsToNag) {
			NSAlert *alert = [[NSAlert alloc] init];
			[alert addButtonWithTitle:@"Take me to the donations page"];
			[alert addButtonWithTitle:@"Sorry - I'm not interested"];
			[alert addButtonWithTitle:@"Remind me later"];
			[alert setMessageText:@"You've used KeyChainDD more than 50 times now"];
			[alert setInformativeText:@"You should REALLY think about donating to the project. But hey, if you don't want to, don't worry, this screen won't ever show again."];
			[alert setAlertStyle:NSInformationalAlertStyle];
			
			switch ([alert runModal]) {
				case NSAlertFirstButtonReturn:
					if (![[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://KeyChainDD.sourceforge.net"]]) 
					{
						NSLog(@"Open of http://keychaindd.sourceforge.net failed.");
					}
					break;
				case NSAlertThirdButtonReturn:
					[[NSUserDefaults standardUserDefaults] setInteger:numStarts - ((numStarts>>3) > 2 ? numStarts>>3 : 2)
															   forKey:@"numberOfStarts"];					
				default:
					break;
			}
			[alert release];	
			[[NSUserDefaults standardUserDefaults] setInteger:kNumStartsToNag+1
													   forKey:@"numberOfStarts"];
		}
		[[NSUserDefaults standardUserDefaults] setInteger:numStarts + 1
												   forKey:@"numberOfStarts"];
	}	
}


- (void)windowWillClose:(NSNotification *)notification
{
#if __debug
	NSLog(@"%s called", __FUNCTION__);
#endif
	// If the progragram is ending, we want to close any open keychains......so do a timeout
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	[[NSNotificationCenter defaultCenter]  postNotificationName:@"KeychainDDTimeOut" object:nil userInfo:nil deliverImmediately:YES];
	[pool release];
}

- (void) clearPasteBoard
{	
#if __debug
	NSLog(@"%s called", __FUNCTION__);
#endif
	NSPasteboard *pBoard = [NSPasteboard pasteboardWithName:NSGeneralPboard];
	
	if (pBoard && ([pBoard changeCount] == pboardCount)) {
		// Here we clear the pasteboard if it hasn't changed since we put sensitive stuff on it
#if __debug
		NSLog(@"pBoard clear");	
#endif
		[pBoard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
		[pBoard setString:@"" forType:NSStringPboardType];
	}
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)app 
{
#if __debug
	NSLog(@"%s called", __FUNCTION__);
#endif
	
    NSUserDefaults *userDefaults;
	userDefaults = [NSUserDefaults standardUserDefaults];
	
	SecKeychainRemoveCallback (&keychain_locked);
	SecKeychainRemoveCallback (&keychain_unlocked);
	SecKeychainRemoveCallback (&keychain_changed);
	
	[self clearPasteBoard];	
	[winController closedownKeyChains];
	return NSTerminateNow;	
}

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)anItem
{
	// NOTE: This is only called for user interface items actually connected to a method
	// in our code - no connection, no call...........
#if __debug
	NSLog(@"%s called", __FUNCTION__);
#endif	
	SEL theAction = [anItem action];
	
	if (theAction == @selector(terminate:))
	{
		return YES;
	}
	else if (theAction == @selector(performKeyChainDDWeb:))
	{
		return YES;
	}
	else if (disableMenus) {
		return NO;
	}
	else {
		if (theAction == @selector(performOpenPreferencesWindow:))
		{
			return YES;
		}
		else if (theAction == @selector(performNewPasswordItem:))
		{
			if ([winController getSelectedItem]) {
				return YES;
			}
			else {
				return NO;
			}
		}
		else if (theAction == @selector(performNewKeychain:))
		{
			return YES;
		}
		else if (theAction == @selector(performDeleteKeychain:))
		{
			if ([winController getSelectedItem]) {
				return YES;
			}
			else {
				return NO;
			}		
		}
		else if (theAction == @selector(performGetInfo:))
		{
			if ([winController getSelectedItem]) {
				return YES;
			}
			else {
				return NO;
			}
		}
		else if (theAction == @selector(performLockkeyChain:))
		{
			if ([winController getSelectedItem]) {
				return YES;
			}
			else {
				return NO;
			}
		}
		else {
			return NO;
		}
	}
}


- (IBAction)performOpenPreferencesWindow:(id)sender
{
	PrefsWindowController *pControl = (PrefsWindowController *) [PrefsWindowController sharedPrefsWindowController];	
	[pControl showWindow:nil];
}


- (IBAction)performNewPasswordItem:(id)sender
{
#if __debug
	NSLog(@"%s called", __FUNCTION__);
#endif
	[winController showInspectorSheet:nil createNew:YES];
}

- (IBAction)performNewKeychain:(id)sender
{
#if __debug
	NSLog(@"%s called", __FUNCTION__);
#endif	
	if (!newKeychainController) {
		//Check the ProgressSheet instance variable to make sure the custom sheet does not already exist.
		[NSBundle loadNibNamed: @"NewKeychain" owner: self];
	}	
	[newKeychainController showInspector];
}

- (IBAction)performDeleteKeychain:(id)sender
{
#if __debug
	NSLog(@"%s called", __FUNCTION__);
#endif
	[[winController getSelectedItem] deleteItem];
}

- (IBAction)performGetInfo:(id)sender
{
#if __debug
	NSLog(@"%s called", __FUNCTION__);
#endif
	[winController showInspectorSheet:nil createNew:NO];
}

- (IBAction)performLockkeyChain:(id)sender
{
#if __debug
	NSLog(@"%s called", __FUNCTION__);
#endif
	[[winController getSelectedItem] lock];
}

- (IBAction)performKeyChainDDWeb:(id)sender
{
#if __debug
	NSLog(@"%s called", __FUNCTION__);
#endif
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://KeyChainDD.sourceforge.net"]];
}


- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
#if __debug
	NSLog(@"observeValueForKeyPath %s", [keyPath UTF8String]);	
#endif
	//    if ([keyPath isEqual:@"keychainTimeOut"]) {
	//		NSLog(@"observeValueForKeyPath hit");
	//	}
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	[[NSNotificationCenter defaultCenter]  postNotificationName:@"UserPreferencesChanged" object:keyPath];
	[pool release];
	
	if ([keyPath isEqual:@"alwaysOnTop"]) {
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"alwaysOnTop"]) {
			[window setLevel:NSFloatingWindowLevel];
		}
		else {
			[window setLevel:NSNormalWindowLevel];
		}
	}	
    // We dont have a real superclass, so no need to call super
}

- (void)disableMenuItems:(NSNotification *)notification
{
#if __debug
	NSLog(@"%s called", __FUNCTION__);
#endif
	disableMenus = YES;
}

- (void)enableMenuItems:(NSNotification *)notification
{
#if __debug
	NSLog(@"%s called", __FUNCTION__);
#endif
	disableMenus = NO;
}

- (void)itemOnPasteboard:(NSNotification *)notification
{
#if __debug
	NSLog(@"%s called", __FUNCTION__);
#endif	
	NSNumber *pBoardCountMessage = [[notification userInfo]
						   objectForKey:@"pBoardCount"];
	pboardCount = [pBoardCountMessage intValue];
	[pBoardCountMessage release];
}

- (void)appleKeychainLocked:(NSNotification *)notification
{
#if __debug
	NSLog(@"%s called", __FUNCTION__);
#endif
	[self clearPasteBoard];
}

OSStatus keychain_locked(SecKeychainEvent keychainEvent, SecKeychainCallbackInfo *info, void *context)
{
#if __debug
	NSLog(@"%s called", __FUNCTION__);
#endif
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	[[NSNotificationCenter defaultCenter]  postNotificationName:@"AppleKeychainLocked" object:nil];
	[pool release];
	return 0;
}

OSStatus keychain_unlocked(SecKeychainEvent keychainEvent, SecKeychainCallbackInfo *info, void *context)
{
#if __debug
	NSLog(@"%s called", __FUNCTION__);
#endif
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	[[NSNotificationCenter defaultCenter]  postNotificationName:@"AppleKeychainUnlocked" object:nil];
	[pool release];
	return 0;
}

OSStatus keychain_changed(SecKeychainEvent keychainEvent, SecKeychainCallbackInfo *info, void *context)
{
#if __debug
	NSLog(@"%s called", __FUNCTION__);
#endif
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	[[NSNotificationCenter defaultCenter]  postNotificationName:@"AppleKeychainChanged" object:nil];
	[pool release];
	return 0;
}

@end
