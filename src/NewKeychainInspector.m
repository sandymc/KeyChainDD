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
* NewKeychainInspector.m
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
* Inspector for KeyChains
*/

#import "NewKeychainInspector.h"
#import "MacOSStatusHelper.h"

@implementation newKeychainInspector

- (void) awakeFromNib {	

#if __debug
	NSLog(@"awakeFromNib");
#endif
}

- (IBAction) applyButtonPress:(id)sender
{
#if __debug
	NSLog(@"applyButtonPress");
#endif
    [NSApp endSheet: inspectorPanel];
    [inspectorPanel orderOut: self];
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	[[NSNotificationCenter defaultCenter]  postNotificationName:@"EnableMenus" object:nil];
	[pool release];	
	
	SecKeychainRef defaultKeychain;
	OSStatus status = SecKeychainCopyDefault (&defaultKeychain);
	
	UInt32 ioPathLength = KC_PATHLENGTH_MAX;
	char path[KC_PATHLENGTH_MAX];
	char pathName[KC_PATHLENGTH_MAX];
	const char *itemName = [[nameField stringValue] UTF8String];
	const char *utf8Password = [[passwordFieldSecure stringValue] UTF8String];
	status = SecKeychainGetPath (defaultKeychain,
								 &ioPathLength,
								 path);
	CFRelease(defaultKeychain);
	
	if ((status != noErr) || (path == NULL) || (ioPathLength < 1)) {
		NSAlert *alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle:@"Cancel"];
		[alert addButtonWithTitle:@"Try to create anyway"];
		[alert setMessageText:@"OS X does not have a default Keychain location specified"];
		[alert setInformativeText:@"KeyChainDD can create one in the default location for you, but this usually indicates that you have bigger problems; you should use the KeyChain Access app to create a new KeyChain"];
		[alert setAlertStyle:NSWarningAlertStyle];
		
		if ([alert runModal] == NSAlertSecondButtonReturn) {
			// Create anyway clicked
			// Assemble from scrath		
			char *userHome = getenv("HOME");		
			if(userHome == NULL) {
				// At this point, the user's system is seriously questionable......
				userHome = "";
			}
			snprintf(pathName, KC_PATHLENGTH_MAX, "%s/%s/%s.keychain", userHome, KC_DB_PATH, itemName);
			status = noErr;
		}
		[alert release];	
	}
	else {
		// We have already checked for a zero length string.....
		NSString *stringPath = [NSString stringWithUTF8String:path];		
		snprintf(pathName, KC_PATHLENGTH_MAX, "%s/%s.keychain", [[stringPath stringByDeletingLastPathComponent] UTF8String], 
				 itemName);	
	}
	
	if (status == noErr) {
		//Create new item		
		SecKeychainRef keychain;
		// According to manual, the SecKeychainRef *keychain parameter can be set to NULL. True, the function executes,
		// but it generates a parramerr(50). This is actually documented as expected behavior in the Darwin docs, but
		// not in the Apple Developer docs. To avoid this error, we pass a dummy keychain variable.......
		status = SecKeychainCreate (pathName,
									strlen(utf8Password),
									utf8Password,
									FALSE,
									NULL,
									&keychain);		
		if (status == noErr) {
			CFRelease(keychain);
		}
		else {
			
			[MacOSStatusHelper outputLogString:status 
								calledFunction:__FUNCTION__];
			NSAlert *alert = [[NSAlert alloc] init];
			[alert addButtonWithTitle:@"OK"];
			//		[alert addButtonWithTitle:@"Cancel"];
			[alert setMessageText:[MacOSStatusHelper getErrorString:status 
													   stringPrefix:@"Could not create keychain: "]];
			[alert setInformativeText:[MacOSStatusHelper getErrorDescription:status 
																stringPrefix:nil]];
			[alert setAlertStyle:NSWarningAlertStyle];			
			if ([alert runModal] == NSAlertFirstButtonReturn) {
				// OK clicked
			}
			[alert release];		
		}
	}
}

- (IBAction) cancelButtonPress:(id)sender
{
#if __debug
	NSLog(@"cancelButtonPress");
#endif
    [NSApp endSheet: inspectorPanel];
    [inspectorPanel orderOut: self];

	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	[[NSNotificationCenter defaultCenter]  postNotificationName:@"EnableMenus" object:nil];
	[pool release];
}

- (void) showInspector
{
#if __debug
	[nameField setStringValue:@"Null node"];
#endif
	[inspectorPanel makeFirstResponder:nameField];
	[applyButton setEnabled:NO];
	[nameField setStringValue:@""];
	[passwordFieldSecure setStringValue:@""];
	[passwordRetypeFieldSecure setStringValue:@""];
	
	[NSApp beginSheet: inspectorPanel
	   modalForWindow: [NSApp keyWindow]
		modalDelegate: self
	   didEndSelector: nil
		  contextInfo: nil];
	
	// Sheet is up here.
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	[[NSNotificationCenter defaultCenter]  postNotificationName:@"DisableMenus" object:nil];
	[pool release];
	// Return processing to the event loop		
}

- (void) controlTextDidChange: (NSNotification *) notification
{
	if (([notification object] == passwordRetypeFieldSecure) || ([notification object] == passwordFieldSecure))
	{
		if (([[passwordRetypeFieldSecure stringValue] length] > 0) && 
			([[passwordRetypeFieldSecure stringValue] isEqualToString:[passwordFieldSecure stringValue]]))
		{
			[applyButton setEnabled:YES];
			[passwordsMatchImage setImage: [NSImage imageNamed: @"item_ok2"]];
		}
		else
		{
			[applyButton setEnabled:NO];
			[passwordsMatchImage setImage: [NSImage imageNamed: @"item_blocked2"]];
		}		
	}
}

@end
