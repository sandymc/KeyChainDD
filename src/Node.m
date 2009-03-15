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
* Node.m
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
* Base class for items
* Derived from the orgininal Apple example code
*/

#import "MyDataSource.h"
#import "Node.h"
#import "ScaledIconFactory.h"

@implementation Node

static Node *rootItem = nil;

+ (Node *)rootItem 
{
#if __debug
	NSLog([NSString stringWithFormat:@"^^^^%s (Id %x)", __FUNCTION__, self]);
#endif
    if (rootItem == nil) rootItem = [[Node alloc] init];
    return rootItem;       
}

-(id)init
{
    if (self == [super init])
    {
		/* display name for the NSOutlineView */
        nameString = [[NSMutableString alloc] initWithFormat:@"KeyChains"];
#if __debug		
		NSLog([NSString stringWithFormat:@"^^^^%s: %@ (Id %x)", __FUNCTION__, nameString, self]);
#endif
		/* an array of keychains */
        childNodes = nil;
		parentNode = nil;
		didUnlock = NO;
    }
    return self;
}

-(id)initWithPersistentObject:(id) object
{
	[self init];
	[nameString release];
	nameString = (NSMutableString *) object;
	[nameString retain];
#if __debug		
	NSLog([NSString stringWithFormat:@"^^^^%s: %@ (Id %x)", __FUNCTION__, nameString, self]);
#endif
	return self;
}
	

-(Node *) parentNode
{
	return parentNode;
}


-(void)refreshData
{
	/* an array of keychains */
	if (childNodes) [childNodes release];
	childNodes = [[NSMutableArray alloc] init];
	
}

-(void)refreshStatus
{
	NSEnumerator *nodeEnum = [childNodes objectEnumerator];
	id node = nil;	
	while (node = [nodeEnum nextObject]) {	
		[node refreshStatus];
	}	
}


-(id)childAtIndex:(int)index
{
#if __debug
	if ([self isKindOfClass:[Node class]]) {
		NSLog([NSString stringWithFormat:@"Node class %s: %@ (Id %x)", __FUNCTION__, nameString, self]);
	}
	else {
		NSLog([NSString stringWithFormat:@"Non-Node class %s: %@ (Id %x)", __FUNCTION__, nameString, self]);
	}
	if (!childNodes) {
		NSLog(@"ChildAtIndex null pointer");
	}
	if (![childNodes objectAtIndex:index]) {
		NSLog(@"ChildAtIndex objectAtIndex null pointer");
	}
#endif	
    return [[[childNodes objectAtIndex:index] retain] autorelease];
}

-(int)numberOfChildren:(NSOutlineView *)outlineView
{
#if __debug
	NSLog([NSString stringWithFormat:@"^^^^%s: %@ (Id %x)", __FUNCTION__, nameString, self]);
#endif
	if (!childNodes) {
		[self refreshData];
		[outlineView reloadItem:self];
	}
    return [childNodes count];
}

-(bool)isItemExpandable
{
	// Note here we might not actually have read any data..... 
    return (childNodes) ? (([childNodes count] == 0) ? NO : YES) : YES;
}

-(id)returnObjValue:(id)sender
{
    return [[nameString retain] autorelease];
}

static NSDictionary *attributeInfoNo = nil;
static NSDictionary *attributeInfoYes = nil;
- (NSDictionary *) getAttributeInfo:(bool)enabled
{
    if (nil == attributeInfoNo) {
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setLineBreakMode:NSLineBreakByTruncatingTail];
			attributeInfoYes = [[NSDictionary alloc] initWithObjectsAndKeys:style, NSParagraphStyleAttributeName, 
					[NSFont systemFontOfSize:[NSFont smallSystemFontSize]], NSFontAttributeName, 
					nil];
			attributeInfoNo = [[NSDictionary alloc] initWithObjectsAndKeys:style, NSParagraphStyleAttributeName, 
					[NSFont systemFontOfSize:[NSFont smallSystemFontSize]], NSFontAttributeName, 
					[NSColor disabledControlTextColor], NSForegroundColorAttributeName, 
					nil];
        [style release];
    }
	return enabled ? attributeInfoYes : attributeInfoNo;
}

-(NSAttributedString *)returnAttributedIconString:(id)sender
{
	NSAttributedString *iconString;
	if ([self isUnlocked]) {
		if ([self hasUserIdPassword]) {
			if ([self appHasAccess]) {
				iconString = [ScaledIconFactory item_okAttributedString:nameString isEnabled:YES]; 
			}
			else {
				iconString = [ScaledIconFactory item_blockedAttributedString:nameString isEnabled:NO]; 
			}
		}
		else {
			iconString = [ScaledIconFactory small_unlockedAttributedString:nameString isEnabled:YES]; 
		}
	}
	else {
		if ([self hasUserIdPassword]) {
			iconString = [ScaledIconFactory small_disabledAttributedString:nameString isEnabled:NO]; 
		}
		else {
			iconString = [ScaledIconFactory small_lockedAttributedString:nameString isEnabled:YES]; 
		}
	}
	
	return (iconString);
}

//-(NSAttributedString *)returnAttributedString:(NSString *) nameString isEnabled:(bool)enabled
//{			
//	iconString = [[NSAttributedString alloc] initWithString:nameString attributes:[self getInfo:enabled]];
//}


-(NSAttributedString *)returnAttributedString:(id)sender
{
	NSAttributedString *iconString;
	if ([self isUnlocked]) {
		if ([self hasUserIdPassword]) {
//			iconString = [ScaledIconFactory noIconAttributedString:nameString isEnabled:[self appHasAccess]]; 
			iconString = [[NSAttributedString alloc] initWithString:nameString attributes:[self getAttributeInfo:[self appHasAccess]]];
		}
		else {
//			iconString = [ScaledIconFactory noIconAttributedString:nameString isEnabled:YES]; 
			iconString = [[NSAttributedString alloc] initWithString:nameString attributes:[self getAttributeInfo:YES]];
		}
	}
	else {
//		iconString = [ScaledIconFactory noIconAttributedString:nameString isEnabled:![self hasUserIdPassword]]; 
		iconString = [[NSAttributedString alloc] initWithString:nameString attributes:[self getAttributeInfo:![self hasUserIdPassword]]];
	}
	[iconString autorelease];
	
	return (iconString);
}


- (NSImage *)iconImageOfSize:(NSSize)size {
    NSImage *nodeImage = nil;
	
	if ([self isUnlocked]) {
		if ([self hasUserIdPassword]) {
			if ([self appHasAccess]) {
				nodeImage = [ScaledIconFactory item_okIcon]; 
			}
			else {
				nodeImage = [ScaledIconFactory item_blockedIcon]; 
			}
		}
		else {
			nodeImage = [ScaledIconFactory small_unlockedIcon]; 
		}
	}
	else {
		if ([self hasUserIdPassword]) {
			nodeImage = [ScaledIconFactory small_disabledIcon]; 
		}
		else {
			nodeImage = [ScaledIconFactory small_lockedIcon]; 
		}
	}
	
	if (size.width != 0.0) {
		// If size is zero, leave at native size
		// Note however that NSImage will show the size as 0,0
		// until an setsize is done
		[nodeImage setSize:size];
	}

	return nodeImage;
}


-(id)returnTypeValue:(id)sender
{
    return [@"" autorelease];
}

-(void)dealloc
{
    [childNodes release];
    [nameString release];
    if (rootItem != nil)
    {
        [rootItem release];
    }
	[super dealloc];
}

-(bool)hasUserIdPassword
{
	return NO;
}

-(bool)isUnlocked
{
	return NO;
}

-(bool)unlock
{
	return NO;
}

-(bool)lock
{
	return NO;
}

-(void)lockAll
{
	if (didUnlock) [self lock];
	if (childNodes) {
		NSEnumerator *objectEnum = [childNodes objectEnumerator];
		Node * node = nil;
		while (node = [objectEnum nextObject]) {
			[node lockAll];
		}	
	}
}

-(NSString *)returnUserId
{
	return nil;
}

-(NSString *)returnPassword
{
	return nil;
}

-(NSString *)returnGenericItem
{
	return nil;
}

-(bool)appHasAccess
{
	return YES;
}

- (bool) changeItemData:(NSString *)label username:(NSString *)username password:(NSString *)password mi:(NSString *)mi
{
	return NO;
}

-(bool) createNewItem:(NSString *)label username:(NSString *)username password:(NSString *)password mi:(NSString *)mi
{
	return NO;
}

-(void) deleteItem
{
	//We don't know how to do this till we know what it is......
	
}


-(id)persistentObjectForItem
{
	
	return nameString;
	
}

-(bool)isEqual:(id)anObject
{
#if __debug
	NSLog(@"^^^^^^^^^^^^^^^^^^^^^^^ IsEqual called");

	if ([nameString isEqualToString:(NSString *)[(Node *)anObject returnObjValue:self]]) {
		NSLog(@"isEqual returned true");
	}
#endif
	return [nameString isEqualToString:(NSString *)[(Node *)anObject returnObjValue:self]];
}

// hash MUST be implemented. isEqual is only called if the hashes are equal.......... 
-(unsigned)hash
{
#if __debug
	NSLog([NSString stringWithFormat:@"^^^^Hash: %@ (Id %x): %x", nameString, self, [nameString hash]]);
#endif
	return [nameString hash];
}


@end

