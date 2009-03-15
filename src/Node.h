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
* Node.h
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

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface Node : NSObject {
    NSMutableArray *childNodes;		// array of children objects
    NSMutableString *nameString;	// name string to display for this item
	Node *parentNode;
	bool didUnlock;
}

-(id)init;
-(id)initWithPersistentObject:(id)name;
-(Node *)parentNode;
-(void)refreshData;
-(void)refreshStatus;
-(bool)isItemExpandable;
-(int)numberOfChildren:(NSOutlineView *)outlineView;
-(id)childAtIndex:(int)index;
-(id)returnObjValue:(id)sender;
-(NSAttributedString *)returnAttributedString:(id)sender;
-(NSAttributedString *)returnAttributedIconString:(id)sender;
-(NSImage *)iconImageOfSize:(NSSize)size;
-(void)dealloc;
-(id)returnTypeValue:(id)sender;
-(bool)hasUserIdPassword;
-(bool)isUnlocked;
-(bool)unlock;
-(bool)lock;
-(void)lockAll;
-(NSString *)returnUserId;
-(NSString *)returnPassword;
-(NSString *)returnGenericItem;
-(bool)appHasAccess;
-(id)persistentObjectForItem;
-(bool)isEqual:(id)anObject;
-(bool) changeItemData:(NSString *)label username:(NSString *)username password:(NSString *)password mi:(NSString *)mi;
-(bool) createNewItem:(NSString *)label username:(NSString *)username password:(NSString *)password mi:(NSString *)mi;
-(void) deleteItem;

@end