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
* ServicePanelController.m
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
* Panel for services menu operation
*/

#import "ServicePanelController.h"
#import "NSKeychainApplication.h"
#import "Node.h"
#import "ImageandTextCell.h"
#import "ScaledIconFactory.h"


@implementation ServicePanelController


- (void) awakeFromNib {
#if __debug
	NSLog(@"%s called", __FUNCTION__);
#endif
	[NSApp setServicesProvider:self];
	[serviceOutlineView setTarget:self];
	[serviceOutlineView setDoubleAction:@selector(okButtonPress:)];
	[serviceOutlineView setAutosaveName:@"keychainDDOutline"];
	[serviceOutlineView setAutosaveTableColumns:YES];
	[serviceOutlineView setAutosaveExpandedItems:YES];	
	// OutLineView only exists at this point
	
// We only need this is we haven't used imageAndText cells in IF Builder
#ifdef NSTextFieldCellUsed
#ifndef useAttributedStringsForIcons
	NSArray *columns = [serviceOutlineView tableColumns];
    int index, count = [columns count];
    for (index = 0; index < count; index++) {
        NSTableColumn *column = [columns objectAtIndex:index];
		ImageAndTextCell *imageAndTextCell = [[[ImageAndTextCell alloc] init] autorelease];
		[column setDataCell:imageAndTextCell];
	}
#endif
	NSArray *columnsArray = [serviceOutlineView tableColumns];	
	NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
	[ScaledIconFactory setFontSize:([layoutManager defaultLineHeightForFont:[[[columnsArray objectAtIndex:0] dataCell] font]]-1)];
	[layoutManager release];
#endif	
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


#ifndef useAttributedStringsForIcons
// -------------------------------------------------------------------------------
//	outlineView:willDisplayCell
// -------------------------------------------------------------------------------
- (void)outlineView:(NSOutlineView *)olv willDisplayCell:(NSCell*)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{	 
#if __debug
//	NSLog(@"%s tableColumn identifier: %@", __FUNCTION__, [tableColumn identifier]);
#endif
	if ([tableColumn identifier] && [[tableColumn identifier] isEqualToString:@"Name"])
	{
		[(ImageAndTextCell*)cell setImage:[item iconImageOfSize: NSMakeSize(0, 0)]];
	}
}
#endif

- (IBAction) okButtonPress:(id)sender
{	
	cancelButtonPressed = NO;
	[NSApp stopModal];
	runLoop = NO;	
}


- (IBAction) cancelButtonPress:(id)sender
{
	cancelButtonPressed = YES;
	[NSApp stopModal];
	runLoop = NO;
}

- (void)ServiceCall:(NSPasteboard *)pboard
	  userData:(NSString *)userData
		 error:(NSString **)error
{
	Node * item = nil;
	[((NSKeychainApplication*) NSApp) startServicesCall];
	ProcessSerialNumber activeApp;
	GetFrontProcess(&activeApp);
#if __debug
	NSLog(@"UserId");
#endif
	item = [mainWindow getSelectedItem];
	if (!item) {
		// Here we want our own dialog box
		[NSApp activateIgnoringOtherApps:YES];
		[myPanel setLevel:NSPopUpMenuWindowLevel];

	#if USERUNSESSION
		runLoop = YES;
		cancelButtonPressed = YES;

		NSModalSession session = [NSApp beginModalSessionForWindow:myPanel];
		int result = NSRunContinuesResponse;
		
		// Loop until some result other than continues:
		while (runLoop)
		{
			// Run the window modally until there are no events to process:
			result = [NSApp runModalSession:session];
			
			// Give the main loop some time:
			[[NSRunLoop currentRunLoop] limitDateForMode:NSDefaultRunLoopMode];
		}
		
		[NSApp endModalSession:session];
	#else
		[NSApp runModalForWindow:myPanel];
	#endif		
		[myPanel orderOut:self];		
		item = [serviceOutlineView itemAtRow:[serviceOutlineView selectedRow]];
	}

	// If we cancel just return an empty string.....
	if (!cancelButtonPressed) {
		// If we want a silent return - as in for a cancel - we don't do a declaretypes,
		// and don't set the error parameter either........
		// Just like the whole call never happened
		// Returning a @"" results in an error......
		NSArray *types = [NSArray arrayWithObject:NSStringPboardType];
		[pboard declareTypes:types owner:nil];
		if ([userData isEqualToString:@"UserID"]) {
			[pboard setString:[item returnUserId] forType:NSStringPboardType];
		}
		else {
			[pboard setString:[item returnPassword] forType:NSStringPboardType];
		}	
	}	
	// End this services call.....
	SetFrontProcess(&activeApp);
	[((NSKeychainApplication*) NSApp) endServicesCall];	
    return;
}

@end
