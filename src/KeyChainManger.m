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
* KeyChainManager.m
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
* Manages a collection of nodes
*/

#import "KeyChainManager.h"
#include <Security/SecKeychain.h>
#include <Security/SecKeychainItem.h>
#include <Security/SecAccess.h>
#include <Security/SecTrustedApplication.h>
#include <Security/SecACL.h>



@implementation KeyChainManager

static KeyChainManager *rootItem = nil;

+ (Node *)rootItem 
{
    if (rootItem == nil) rootItem = [[KeyChainManager alloc] init];
    
    return rootItem;       
}


-(id)init
{
    [super init];
	searchList = nil;
    return self;
}


-(void)refreshData
{
	[super refreshData];
    [self iterateChildren];
	
}


-(void)iterateChildren
{
	if (searchList != nil) CFRelease((CFArrayRef)searchList);
	
	OSStatus status = SecKeychainCopySearchList((CFArrayRef*)(&searchList));
	if (status) {
		NSLog(@"KeyChainDD Error - SecKeychainCopySearchList failed");	
	}
	else {
		NSEnumerator *objectEnum = [searchList objectEnumerator];
		id object = nil;
		int i = 0;
		while (object = [objectEnum nextObject]) {
			if (SecKeychainGetTypeID () == CFGetTypeID(object)) {
				SecKeychainRef item = (SecKeychainRef) object;
				KeyChain *keyChainItem = [[KeyChain alloc] initWithKeyChainref:item parent:self];
				[childNodes insertObject:keyChainItem atIndex:i];
				[keyChainItem release]; // Arrays retain their object autmatically
				i++;
			}
			else {
				NSLog(@"KeyChainDD Warning - Non-Keychain item in the default search list......");	
			}
		}
	}				
}

-(void)dealloc {
	[super dealloc];
	if (searchList != nil) CFRelease((CFArrayRef*)(&searchList));
}
	

@end

