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
* MyDataSource.m
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
* Datasource KeyChain items
*/

#include <Carbon/Carbon.h>
#include <Cocoa/Cocoa.h>

#import "MyDataSource.h"
#import "NSKeychainApplication.h"
#import "ImageAndTextCell.h"

@implementation MyDataSource

// NSOutlineView Data Source methods
//
// This class implements all the required NSOutlineView data source functions
// Refer to the NSOutlineView documentation for additional information.
// These are delegate methods for NSOutlineViewDataSource.......


- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
//	NSLog([NSString stringWithFormat:@"numberOfChildrenOfItem1: %@", (NSString *) [item returnObjValue:self]]);

	if (item == nil) item = [KeyChainManager rootItem];
//	NSLog([NSString stringWithFormat:@"numberOfChildrenOfItem2: %@: %i", (NSString *) [item returnObjValue:self], [item numberOfChildren:outlineView]]);
	
    return [item numberOfChildren:outlineView];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
	if (item == nil) item = [KeyChainManager rootItem];
	return [item isItemExpandable];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item {
//	NSLog([NSString stringWithFormat:@"childofItem1: %@", (NSString *) [item returnObjValue:self]]);
	if (item == nil) item = [KeyChainManager rootItem];
//	NSLog([NSString stringWithFormat:@"childofItem2: %@: %i: %@", (NSString *) [item returnObjValue:self], index, (NSString *) [[item childAtIndex:index] returnObjValue:self]]);
    return [item childAtIndex:index];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
	
	if (item == nil) item = [KeyChainManager rootItem];
	
	if ([outlineView outlineTableColumn] == tableColumn) {
		// Column 0
#ifndef useAttributedStringsForIcons
		return [item returnAttributedString:self];
#else
		return [item returnAttributedIconString:self];
#endif
	}
	else {
		//Column 1
		return [item returnTypeValue:self];
	}
}



// myOutlineView persistance methods
//
// These methods implements all the required NSOutlineView functions to allow the expansion status to be persistent
// Refer to the NSOutlineView documentation for additional information.
//
// These are actually part of the DataSource specifications....... 

- (id)outlineView:(NSOutlineView *)outlineView persistentObjectForItem:(id)item
{
	return [(Node*)item persistentObjectForItem];
}

- (id)outlineView:(NSOutlineView *)outlineView itemForPersistentObject:(id)object
{
	return [[[Node alloc] initWithPersistentObject:object] autorelease];
}

@end
