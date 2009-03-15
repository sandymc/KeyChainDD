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
* keychainDDInspector.m
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
* Inspector for KeyChain items
*/

#import "keychainDDInspector.h"

@implementation keychainDDInspector


- (void) awakeFromNib {	

#if __debug
	NSLog(@"awakeFromNib");
#endif
	[nameField setStringValue:@"start"];
	savedTextBackground = [[nameField backgroundColor] retain];
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
	
	if (newFlag) {
		//Create new item
		if ([myNode createNewItem:[nameField stringValue] username:[userIdField stringValue] password:[passwordFieldSecure stringValue] mi:[miFieldSecure stringValue]])
		{
		
		}
		else {
			NSAlert *alert = [[NSAlert alloc] init];
			[alert addButtonWithTitle:@"OK"];
			[alert setMessageText:@"Keychain item could not be created"];
			[alert setInformativeText:@"Try using the OS X Keychain Access Application"];
			[alert setAlertStyle:NSWarningAlertStyle];
			
			if ([alert runModal] == NSAlertFirstButtonReturn) {
				// OK clicked
			}
			[alert release];		
		}
	}
	else {
		// Edit existing node.......

		if ([myNode changeItemData:[nameField stringValue] username:[userIdField stringValue] password:[passwordFieldSecure stringValue] mi:[miFieldSecure stringValue]])
		{			
		}
		else {
			NSAlert *alert = [[NSAlert alloc] init];
			[alert addButtonWithTitle:@"OK"];
			[alert setMessageText:@"Keychain item could not be edited"];
			[alert setInformativeText:@"Try using the OS X Keychain Access Application"];
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
//	[NSApp stopModalWithCode:NSOKButton];
    [NSApp endSheet: inspectorPanel];
    [inspectorPanel orderOut: self];

	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	[[NSNotificationCenter defaultCenter]  postNotificationName:@"EnableMenus" object:nil];
	[pool release];
}

- (IBAction) plainTextButtonPress:(id)sender
{

#if __debug
	NSLog(@"plainTextButtonPress");
#endif

	if([plainTextButton state] == NSOnState) {
		[passwordField setHidden:NO];
		[miField setHidden:NO];
		[passwordFieldSecure setHidden:YES];
		[miFieldSecure setHidden:YES];
		[passwordField setStringValue:[passwordFieldSecure stringValue]];
		[miField setStringValue:[miFieldSecure stringValue]];	
	}
	else {
		[passwordField setHidden:YES];
		[miField setHidden:YES];
		[passwordFieldSecure setHidden:NO];
		[miFieldSecure setHidden:NO];
		[passwordFieldSecure setStringValue:[passwordField stringValue]];
		[miFieldSecure setStringValue:[miField stringValue]];
	}

}

- (void) setNode:(Node *) node createNew:(bool)createNew
{
#if __debug
	[nameField setStringValue:@"Null node"];
#endif
	[inspectorPanel makeFirstResponder:nameField];
	[applyButton setEnabled:NO];
	if (node) {
		myNode = node;
		newFlag = createNew;
		
		[passwordField setHidden:YES];
		[miField setHidden:YES];
		[passwordFieldSecure setHidden:NO];
		[miFieldSecure setHidden:NO];
		[plainTextButton setState:NSOffState];
		if (newFlag) 
		{
			[applyButton setStringValue:@"Create"];
			[nameField setStringValue:@""];
			[userIdField setStringValue:@""];
			[passwordFieldSecure setStringValue:@""];
			[miFieldSecure setStringValue:@""];
			[nameField setEditable:YES];
			[nameField setSelectable:YES];
			[userIdField setEnabled:YES];
			[passwordFieldSecure setEnabled:YES];
			[passwordField setEnabled:YES];
			[miFieldSecure setEnabled:YES];
			[miField setEnabled:YES];		
			[nameField setBackgroundColor:savedTextBackground];
			[userIdField setBackgroundColor:savedTextBackground];
			[passwordField setBackgroundColor:savedTextBackground];
			[passwordFieldSecure setBackgroundColor:savedTextBackground];
			[miFieldSecure setBackgroundColor:savedTextBackground];
		}
		else {
			// Existing node that we want to edit
			[applyButton setStringValue:@"Update"];
			[nameField setStringValue:[[node returnAttributedString:self] string]];
			if ([myNode hasUserIdPassword]) 
			{
				// Keychain item
				[nameField setEditable:YES];
				[nameField setSelectable:YES];
				[nameField setBackgroundColor:savedTextBackground];
				[userIdField setEnabled:YES];
				[passwordFieldSecure setEnabled:YES];
				[passwordField setEnabled:YES];
				[miFieldSecure setEnabled:YES];
				[miField setEnabled:YES];
				[nameField setBackgroundColor:savedTextBackground];
				[userIdField setBackgroundColor:savedTextBackground];
				[passwordField setBackgroundColor:savedTextBackground];
				[passwordFieldSecure setBackgroundColor:savedTextBackground];
				[miField setBackgroundColor:savedTextBackground];
				[miFieldSecure setBackgroundColor:savedTextBackground];
								
				[userIdField setStringValue:[myNode returnUserId]];
				[passwordFieldSecure setStringValue:[node returnPassword]];
				// returnGenericItem return an empty string if no generic item exists
				[miFieldSecure setStringValue:[node returnGenericItem]];
				
			}
			else 
			{
				// Keychain
				[nameField setEditable:NO];
				[nameField setSelectable:NO];
				[userIdField setEnabled:NO];
				[passwordFieldSecure setEnabled:NO];
				[passwordField setEnabled:NO];
				[miFieldSecure setEnabled:NO];
				[miField setEnabled:NO];
				[userIdField setStringValue:@""];
				[passwordFieldSecure setStringValue:@""];
				[miFieldSecure setStringValue:@""];
				[nameField setBackgroundColor:[inspectorPanel backgroundColor]];
				[userIdField setBackgroundColor:[inspectorPanel backgroundColor]];
				[passwordField setBackgroundColor:[inspectorPanel backgroundColor]];
				[passwordFieldSecure setBackgroundColor:[inspectorPanel backgroundColor]];
				[miField setBackgroundColor:[inspectorPanel backgroundColor]];
				[miFieldSecure setBackgroundColor:[inspectorPanel backgroundColor]];
			}		

		}

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
	else {
		NSLog(@"keychainDD error: attempting to edit a null node");
		}
	
}

- (void) controlTextDidChange: (NSNotification *) notification
{
	if ([notification object] == nameField) 
	{
#if __debug
		NSLog(@"textDidChange:nameField");
#endif
	}
	else if ([notification object] == passwordField) 
	{
		[passwordFieldSecure setStringValue:[passwordField stringValue]];
	}
	else if ([notification object] == passwordFieldSecure) 
	{
		[passwordField setStringValue:[passwordFieldSecure stringValue]];
	}
	else if ([notification object] == miField) 
	{
		[miFieldSecure setStringValue:[miField stringValue]];
	}
	else if ([notification object] == miFieldSecure) 
	{
		[miField setStringValue:[miFieldSecure stringValue]];
	}

	[applyButton setEnabled:YES];
}

@end
