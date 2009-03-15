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
* MainWinController.m
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
* Controller for the main window
*/

#import "MainWinController.h"
#import "ScaledIconFactory.h"
#import "ImageandTextCell.h"


@implementation MainWinController

- (id)init
{
    if (self == [super init])
    {
		[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
															   selector:@selector(closeOpenKeyChains:)
																   name:NSWorkspaceWillSleepNotification
																 object:nil];
		[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
															   selector:@selector(closeOpenKeyChains:)
																   name:NSWorkspaceWillPowerOffNotification
																 object:nil];
		[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
															   selector:@selector(closeOpenKeyChains:)
																   name:NSWorkspaceSessionDidResignActiveNotification
																 object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(appleKeychainLocked:)
													 name:@"AppleKeychainLocked" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(appleKeychainUnlocked:)
													 name:@"AppleKeychainUnlocked" 
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(appleKeychainChanged:)
													 name:@"AppleKeychainChanged" 
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(closeOpenKeyChains:)
													 name:@"KeychainDDTimeOut" 
												   object:nil];
#if __debug
		NSLog(@"mainWinController init");
#endif		
	}
	return self;
}


- (void) awakeFromNib {		
#if __debug
	NSLog(@"%s called", __FUNCTION__);
#endif	
//	[userIdToken setEditable:NO];
//	[passwordToken setEditable:NO];
//	bgColor = [userIdToken backgroundColor];
//	[userIdToken setEnabled:NO];
//	[passwordToken setEnabled:NO];
	//Configure the outlineview
	[myOutlineView setTarget:self];
	[myOutlineView setDoubleAction:@selector(lockButtonPress:)];
	[myOutlineView setAutosaveName:@"keychainDDOutline"];
	[myOutlineView setAutosaveTableColumns:YES];
	[myOutlineView setAutosaveExpandedItems:YES];
	
	// OutLineView only exists at this point
	// We only need this is we haven't used imageAndText cells in IF Builder
#ifdef NSTextFieldCellUsed
#ifndef useAttributedStringsForIcons
	NSArray *columns = [myOutlineView tableColumns];
    int index, count = [columns count];
    for (index = 0; index < count; index++) {
        NSTableColumn *column = [columns objectAtIndex:index];
		ImageAndTextCell *imageAndTextCell = [[[ImageAndTextCell alloc] init] autorelease];
		[column setDataCell:imageAndTextCell];
    }
#endif	
	NSArray *columnsArray = [myOutlineView tableColumns];	
	NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
	[ScaledIconFactory setFontSize:([layoutManager defaultLineHeightForFont:[[[columnsArray objectAtIndex:0] dataCell] font]]-1)];
	[layoutManager release];
#endif
		
	[userIdDragButton setUserIdFlag:YES];
	[passwordDragButton setUserIdFlag:NO];
	[userIdDragButton setEnabled:NO];
	[passwordDragButton setEnabled:NO];
	
	[myOutlineView setToolTip:@"Select an item by clicking with the mouse"];
}

// NSOutlineView methods
//
// These configure myOutlineView behavior
// Refer to the NSOutlineView documentation for additional information.
// These are delegate methods for NSOutlineView.......
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
    return YES;
}

// View controller methods
//
// MyDataSource also has some view controller functionality
// This covers the outline view and the tokens
//

- (void) processOutlineViewChange {
#if __debug
	NSLog(@"%s called", __FUNCTION__);
#endif	
	Node * item = [myOutlineView itemAtRow:[myOutlineView selectedRow]];
	
	[userIdDragButton setSelectedItem:item];
	[passwordDragButton setSelectedItem:item];
	
	if ([item hasUserIdPassword] && [item isUnlocked])
	{
		[miController setMiString:[item returnGenericItem]];
	}
	else {
		[miController setMiString:nil];
	}
		
	[self setLockButtonImage:item];
}

// First for the NSOutlineView
- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
	[self processOutlineViewChange]; 
}

// Then for the buttons.....
- (void) setLockButtonImage:(Node *) item
{
	if (item && [item isUnlocked]) {
		[lockButton setImage:[ScaledIconFactory keysOpenImage]];
	}
	else {
		[lockButton setImage:[ScaledIconFactory keysClosedImage]];
	}
	if ([item hasUserIdPassword] && [item isUnlocked]) {
		if ([item appHasAccess]) {
//			[userIdToken setBackgroundColor:[NSColor greenColor]];
//			[passwordToken setBackgroundColor:[NSColor greenColor]];
			[helpField setStringValue:@"Drag and Drop, or click the key to lock"];
			[myOutlineView setToolTip:@"Drag and Drop, or click the key to lock"];
//			[userIdToken setEnabled:YES];
//			[passwordToken setEnabled:YES];
			[userIdDragButton setEnabled:YES];
			[passwordDragButton setEnabled:YES];
		}
		else {
//			[userIdToken setBackgroundColor:[NSColor yellowColor]];
//			[passwordToken setBackgroundColor:[NSColor yellowColor]];
			[helpField setStringValue:@"Keychain unlocked, but KeychainDD does not have access. Click the key to grant access"];
			[myOutlineView setToolTip:@"Keychain unlocked, but KeychainDD does not have access. Click the key to grant access"];
//			[userIdToken setEnabled:NO];
//			[passwordToken setEnabled:NO];
			[userIdDragButton setEnabled:YES];
			[passwordDragButton setEnabled:NO];
		}
	}
	else {
//		[userIdToken setBackgroundColor:bgColor];
//		[passwordToken setBackgroundColor:bgColor];	
//		[userIdToken setEnabled:NO];
//		[passwordToken setEnabled:NO];
		[userIdDragButton setEnabled:NO];
		[passwordDragButton setEnabled:NO];
		if ([item hasUserIdPassword]) {
			if ([item isUnlocked]) {
				[helpField setStringValue:@"Drag a UserId or Password"];
				[myOutlineView setToolTip:@"Drag a UserId or Password"];
			}
			else {
				[helpField setStringValue:@"Click the key to unlock"];
				[myOutlineView setToolTip:@"Click the key to unlock"];
			}
		}
		else {
			[helpField setStringValue:@"Select a UserId/Password item or click to unlock the Keychain"];
			[myOutlineView setToolTip:@"Select a UserId/Password item or click to unlock the Keychain"];
		}
	}

}	


#ifndef useAttributedStringsForIcons
// -------------------------------------------------------------------------------
//	outlineView:willDisplayCell
// -------------------------------------------------------------------------------
- (void)outlineView:(NSOutlineView *)olv willDisplayCell:(NSCell*)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{	 
//	NSLog([NSString stringWithFormat:@"tableColumn identifier: %@", [tableColumn identifier]]);
	if ([tableColumn identifier] && [[tableColumn identifier] isEqualToString:@"Name"])
	{
		[(ImageAndTextCell*)cell setImage:[item iconImageOfSize: NSMakeSize(0.0, 0.0)]];
	}
}
#endif

/*
- (BOOL)tokenField:(NSTokenField *)tokenField writeRepresentedObjects:(NSArray *)objects toPasteboard:(NSPasteboard *)pboard {
	
#if __debug
	if (tokenField == userIdToken) NSLog(@"writeRepresentedObjects: userId");
	if (tokenField == passwordToken) NSLog(@"writeRepresentedObjects: password");
#endif
	Node * item = [myOutlineView itemAtRow:[myOutlineView selectedRow]];
	
	[pboard declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:nil];
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:objects];
	if (tokenField == userIdToken) [pboard setString:[item returnUserId] forType:NSStringPboardType];
	else if (tokenField == passwordToken) [pboard setString:[item returnPassword] forType:NSStringPboardType];
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	// Note: Alloc'd here - have to release on end of message.........
	NSNumber *pBoardCount = [[NSNumber alloc] initWithInt:[pboard changeCount]];
	[[NSNotificationCenter defaultCenter]  postNotificationName:@"ItemOnPasteboard" 
														 object:self 
													   userInfo: [NSDictionary dictionaryWithObject: pBoardCount forKey: @"pBoardCount"]];
	[pool release];
	return nil != data;	   
}
*/

- (IBAction) lockButtonPress:(id)sender
{
#if __debug
	NSLog(@"%s called", __FUNCTION__);
#endif	
	Node * item = [myOutlineView itemAtRow:[myOutlineView selectedRow]];
	if ([item isUnlocked]) {
		if ([item appHasAccess]) {
			[item lock];
		}
		else {
			// This initiates a application access cycle.......
			[item returnPassword];
		}
	}
	else {
		[item unlock];
	}
	[self processOutlineViewChange]; 	
}

- (IBAction) useridButtonPress:(id)sender
{
#if __debug
	NSLog(@"%s called", __FUNCTION__);
#endif	
}

- (IBAction) passwordPress:(id)sender
{
#if __debug
	NSLog(@"%s called", __FUNCTION__);
#endif	
}


- (void)showInspectorSheet:(Node *) node createNew:(bool)createNew

	// User has asked to see the custom display. Display it.
{
	if (node == nil) {
		node = [self getSelectedItem];
	}		
	if (!inspectorController) {
		//Check the ProgressSheet instance variable to make sure the custom sheet does not already exist.
		[NSBundle loadNibNamed: @"Inspector" owner: self];
	}	

	[inspectorController setNode:node createNew:createNew];
}

- (IBAction) addItemContextMenu:(id)sender
{

#if __debug
	NSLog(@"%s called", __FUNCTION__);
#endif	
	[self showInspectorSheet:nil createNew:YES];
	[myOutlineView reloadData];

}


- (IBAction) editItemContextMenu:(id)sender
{

#if __debug
	NSLog(@"%s called", __FUNCTION__);
#endif
	[self showInspectorSheet:nil createNew:NO];
	[myOutlineView reloadData];
}

- (IBAction) deleteItemContextMenu:(id)sender
{

#if __debug
	NSLog(@"%s called", __FUNCTION__);
#endif
	[[self getSelectedItem] deleteItem];
	[myOutlineView reloadData];
}

// Utility methods
//
// This allows us to be smart about clearing the pasteboard 
// This covers the outline view and the tokens
//


- (Node *)getSelectedItem
{
	return [myOutlineView selectedRow] >=0 ? [myOutlineView itemAtRow:[myOutlineView selectedRow]] : nil;	
}

// Notification handlers
//
// These intercept and handle the various notification lying around
// 
//

- (void)appleKeychainLocked:(NSNotification *)notification
{
#if __debug
	NSLog(@"%s called", __FUNCTION__);
#endif
	Node * item = [self getSelectedItem];		
	[self setLockButtonImage:item];
	[myOutlineView reloadData];
	[self processOutlineViewChange];
}

- (void)appleKeychainUnlocked:(NSNotification *)notification
{
#if __debug
	NSLog(@"%s called", __FUNCTION__);
#endif
	Node * item = [self getSelectedItem];		
	[self setLockButtonImage:item];
	[myOutlineView reloadData];
}

- (void)appleKeychainChanged:(NSNotification *)notification
{
#if __debug
	NSLog(@"%s called", __FUNCTION__);
#endif
	[[KeyChainManager rootItem] refreshData];
	[myOutlineView reloadData];
}


- (void)closeOpenKeyChains:(NSNotification *)notification {
#if __debug
	NSLog(@"%s called", __FUNCTION__);
#endif
	[[KeyChainManager rootItem] lockAll];
}

- (void)closedownKeyChains
{
	[[KeyChainManager rootItem] lockAll];	
}

@end
