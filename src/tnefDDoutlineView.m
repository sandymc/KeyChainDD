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
* ---------------
* tnefDDoutlineView.m
* ---------------
* (C) Copyright 2009, by Sandy McGuffog and Contributors.
*
* Original Author:  Sandy McGuffog;
* Contributor(s):   -;
*
* Changes
* -------
* 14 Aug 2008 : Original version;
*
*/

/*
* Subclass of NSOutlineView for tnefDD
* Overrides menuForEvent such that if a right click occurs, the item that was
* right-clicked becomes selected, if it wasn't before 
* This based on the original tnefDD Version
*/

#import "tnefDDoutlineView.h"


@implementation tnefDDoutlineView

- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	if ([theEvent type] == NSRightMouseDown)
	{
		// Get current selection
		NSIndexSet *selectedRowIndexes = [self selectedRowIndexes];
		
		// Find the row that was right clicked
		NSPoint mousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
		int row = [self rowAtPoint:mousePoint];
		
		// Is this row already part of the selection?
		if (![selectedRowIndexes containsIndex:row])
		{
			[self selectRow:row byExtendingSelection:NO];
		}
		// if already selected, no change.
	}
	
	return [super menuForEvent:theEvent];
}

@end
