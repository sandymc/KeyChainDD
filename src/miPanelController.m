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
* miPanelController.m
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
* Controller for the memorable information panel
*/

#import "miPanelController.h"

@implementation miPanelController

#define kRows	2
#define kColumns	10

- (void) clearDisplay {

	int column;
	int row;
	for (row = 0; row < kRows; row++) {
		for (column = 0; column < kColumns; column++) {
			NSButtonCell *bcell = [buttonMatrix cellAtRow:row column:column];
			[bcell setTitle:@"●"];
			}
		}		
}


#if MAC_OS_X_VERSION_MIN_REQUIRED <= MAC_OS_X_VERSION_10_4
typedef unsigned int NSUInteger;
#endif

- (void) loadDisplay {
	
	if (miString) {
		int column;
		int row;
		for (row = 0; row < kRows; row++) {
			for (column = 0; column < kColumns; column++) {
				NSButtonCell *bcell = [buttonMatrix cellAtRow:row column:column];
				NSUInteger charNum = row*kColumns + column;
				if ([miString length] <= charNum) {
					[bcell setTitle:@"●"];
				}
				else {
					unichar unicodeChar = [miString characterAtIndex:charNum];	
					[bcell setTitle:[NSString stringWithCharacters:&unicodeChar length:1]];
				}
			}
		}
	}
	else {
		[self clearDisplay];
	}
}

- (void) updateDisplay {
	[self clearDisplay];
	if (plainTextMIDrawerCache) {
		[self loadDisplay];
	}
	else {
		[self clearDisplay];
	}
}

#if MAC_OS_X_VERSION_MIN_REQUIRED <= MAC_OS_X_VERSION_10_4
typedef float CGFloat;
#endif


- (void)setmiDrawerOffsets {
// This keeps the drawer at a constant size (as set in IB), and centered.....
// See the notes in awakeFromNib as to how and why the drawer sizing is done the way its done here......	
	NSSize parentSize = [[miDrawer parentWindow] frame].size;
#if __debug
    NSLog(@"miPanelController setmiDrawerOffsets %f %f %f", parentSize.width, frameSize.width, (parentSize.width - frameSize.width) / 2);
#endif

	[miDrawer setLeadingOffset:(parentSize.width - frameSize.width) / 2];
	[miDrawer setTrailingOffset:((parentSize.width - frameSize.width + 1)) /2];
}

- (void) cachePreferences {	
	// We are using 30 second ticks.......so multiply by two
	autoOpenMIDrawerCache = [[NSUserDefaults standardUserDefaults] boolForKey:@"autoOpenMIDrawer"];
	plainTextMIDrawerCache = [[NSUserDefaults standardUserDefaults] boolForKey:@"plainTextMIDrawer"];	
}



- (void) awakeFromNib {		
#if __debug
    NSLog(@"miPanelController awakeFromNib");
#endif
// Here we store the min size of the content for later use in the setmiDrawerOffsets.
// We then change the minimum width to 0, as if it gets left at the "real" width,
// the parent window insists on resizing to try to accomodate the drawer; the
// end result of that is that parent window grows larger and larger.......
    frameSize = [miDrawer minContentSize];
	NSSize newFrameSize = frameSize;
	newFrameSize.width = 0;
	
	[miDrawer setMinContentSize:newFrameSize];

	[self clearDisplay];
	[self setmiDrawerOffsets];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(drawerClosed:) 
												 name:@"NSDrawerDidCloseNotification" 
											   object:nil]; // tell me when the drawer closes
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(drawerOpened:) 
												 name:@"NSDrawerDidOpenNotification" 
											   object:nil]; // tell me when the drawer opens

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(userPreferencesChanged:)
												 name:@"UserPreferencesChanged" 
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(miDrawerTimeOut:)
												 name:@"MIDrawerTimeOut" 
											   object:nil];
	[self cachePreferences];	
	miString = nil;
}


- (void)windowDidResize:(NSNotification *)notification {
#if __debug
//    NSLog(@"miPanelController windowDidResize");
#endif
    [self setmiDrawerOffsets];
}

- (IBAction) matrixAction:(id)sender
{
	NSButton *theButton = [sender selectedCell];
	
#if __debug
	NSLog([NSString stringWithFormat:@"matrixAction: %@", [theButton stringValue]]);
#endif
	if (miString) {
		NSUInteger charNum = [sender selectedRow]*kColumns + [sender selectedColumn];
		if ([miString length] <= charNum) {
			[theButton setTitle:@"●"];
		}
		else {
			if ([[theButton title] isEqualToString:@"●"]) {
				unichar unicodeChar = [miString characterAtIndex:charNum];	
				[theButton setTitle:[NSString stringWithCharacters:&unicodeChar length:1]];
			}
			else {
				[theButton setTitle:@"●"];
			}
		}
	}
	else {
		[theButton setTitle:@"●"];
	}
}


- (void) setMiString:(NSString *) theString
{

	if (miString) {
		[miString release];
	}
	miString = theString;
	[miString retain];
	[self updateDisplay];
	if (autoOpenMIDrawerCache) {
		if ((miString != nil) && ([miString length] > 0)) {
			[miDrawer open:self];
		}
		else {
			[miDrawer close:self];
		}			
	}
}

- (void)drawerClosed:(NSNotification *)notification
{
    if ([notification object] == miDrawer) // if the drawer is my drawer
    {
#if __debug
		NSLog(@"miPanelController drawerClosed");
#endif
	[self clearDisplay];
    }
}

- (void)drawerOpened:(NSNotification *)notification
{
    if ([notification object] == miDrawer) // if the drawer is my drawer
    {
#if __debug
		NSLog(@"miPanelController drawerOpened");
#endif
		[self updateDisplay];
    }
}

- (void)userPreferencesChanged:(NSNotification *)notification
{
#if __debug
	NSLog(@"%s: %s", __FUNCTION__, [((NSString *) [notification object]) UTF8String]);
#endif
	[self cachePreferences];
	
	if ([((NSString *) [notification object]) isEqualToString:@"plainTextMIDrawer"]) {
		[self updateDisplay];
	}	
}

- (void)miDrawerTimeOut:(NSNotification *)notification
{
#if __debug
	NSLog(@"%s: %s", __FUNCTION__, [((NSString *) [notification object]) UTF8String]);
#endif
	[miDrawer close]; 	
}

@end
