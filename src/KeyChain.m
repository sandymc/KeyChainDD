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
* KeyChain.m
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
* Reprisents a keyChain item
*/


#import "KeyChain.h"
#import "KeyChainItem.h"
#include <Security/SecKeychain.h>
#include <Security/SecKeychainItem.h>
#include <Security/SecAccess.h>
#include <Security/SecTrustedApplication.h>
#include <Security/SecACL.h>


@implementation KeyChain

-(id)init
{
    if (self == [super init])
    {
		keyChainRef = nil;
    }
    return self;
}

-(void)refreshData
{
	[super refreshData];
    [self iterateChildren];
	
}

-(id)initWithKeyChainref:(SecKeychainRef)keyChain  parent:(Node *) parent {
	UInt32 pathLen = 300;
	char pathName[301];
	
    [self init];
	parentNode = parent;
	
	OSStatus status = SecKeychainGetPath (
										  keyChain,
										  &pathLen,
										  pathName
										  );
	if (status) {
		NSLog(@"KeyChainDD Warning - SecKeychainGetPath failed with error %d", status);
		keyChainRef = nil;
	}
	else {
		[nameString release];
		nameString = (NSMutableString *) [[[[[NSString alloc] initWithCString:pathName 
			encoding:NSUTF8StringEncoding] autorelease] stringByDeletingPathExtension] lastPathComponent];
		[nameString retain];
		keyChainRef = keyChain;
	}	
	return self;
	
}


-(void) iterateKeyChainByClass:(SecItemClass) secClass {
	SecKeychainSearchRef searchRef = nil;
	SecKeychainItemRef itemRef = nil;
	OSStatus status = 0;

	// get items reference from keychain
	status = SecKeychainSearchCreateFromAttributes(keyChainRef, secClass,
												   NULL,
												   &searchRef);
	
	if (status) {
		NSLog(@"KeyChainDD Warning - SecKeychainSearchCreateFromAttributes failed with error %d", status);
	}
	
	// iterate thru all items and create children
	int i = 0;
	while((status = SecKeychainSearchCopyNext(searchRef, &itemRef)) != errSecItemNotFound) {
		if (status) {
			NSLog(@"KeyChainDD Warning - SecKeychainSearchCopyNext failed with error %d", status);
		}
		else {
			KeyChainItem *keyChainItem = nil;			
			keyChainItem = [[KeyChainItem alloc] initWithKeyChainItemRef:itemRef parent:self];
			[childNodes insertObject:keyChainItem atIndex:i];
			[keyChainItem release];
			i++;
		}
		

	}
	if (searchRef) {
		CFRelease(searchRef);		
		searchRef = nil;
	}	
}


-(void)iterateChildren {
	[self iterateKeyChainByClass:kSecGenericPasswordItemClass];
	[self iterateKeyChainByClass:kSecInternetPasswordItemClass];	
}

-(bool)isUnlocked
{
	OSStatus status = 0;
	SecKeychainStatus keychainStatus;
	
	status  = SecKeychainGetStatus (
								   keyChainRef,
								   &keychainStatus
								   );
	return keychainStatus & kSecUnlockStateStatus;
}

-(bool)lock
{
	OSStatus status = SecKeychainLock (
							  keyChainRef
							  );
	if (!(status == 0)) {
		NSLog([NSString stringWithFormat:@"lock failed on item: %@: %i", (NSString *) [self returnObjValue:self], status]);
	}
	else {
		didUnlock = NO;
	}

	return (status == 0) ? YES : NO;
}

-(bool)unlock
{
	OSStatus status = SecKeychainUnlock (
									   keyChainRef,
										 0,
										 NULL,
										 FALSE
									   );
	if (!(status == 0)) {
		NSLog([NSString stringWithFormat:@"unlock failed on item: %@: %i", (NSString *) [self returnObjValue:self], status]);
	}
	else {
		didUnlock = YES;
	}
	return (status == 0) ? YES : NO;
}

-(void)dealloc {
	[super dealloc];
}

-(bool) createNewItem:(NSString *)label username:(NSString *)username password:(NSString *)password mi:(NSString *)mi {
	const char *comment = "created by KeyChainDD";
	OSStatus status = nil;
	// Its very important that when passing the lengths of strings to anything in the security API, THAT THE LENGTH
	// IS PASSED AS THE LENGTH OF THE UTF8 STRING, not the number of characters. So you can't pass [NSString length].
	// that will blow up on non-ascii characters, and yes, you will be passed non-ascii characters. So first 
	// convert to UTF8, then use strlen.......
	const char* utf8Label = [label UTF8String];
	const char* utf8Username = [username UTF8String];
	const char* utf8Mi = [mi UTF8String];
	
	NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
	SecKeychainAttribute attrs[] = {
		{ kSecLabelItemAttr, strlen(utf8Label), (char *) utf8Label },
		{ kSecAccountItemAttr, strlen(utf8Username), (char *) utf8Username },
		// kSecServiceItemAttr is the "where" in the Apple KeyChain utility
		{ kSecServiceItemAttr, strlen(utf8Label), (char *) utf8Label },
		{ kGenericKCItemAttr, strlen(utf8Mi), (char *) utf8Mi },
		{ kSecCommentItemAttr, strlen(comment), (char *)comment },
	};
	SecKeychainAttributeList attributes = { sizeof(attrs) / sizeof(attrs[0]), attrs };
		status = SecKeychainItemCreateFromContent(kSecGenericPasswordItemClass,
												  &attributes,
												  [passwordData length],
												  (void *)[passwordData bytes],
												  keyChainRef,
												  (SecAccessRef)NULL,
												  NULL);
	if (status != noErr) {
		NSLog(@"KeyChainDD Warning - SecKeychainItemCreateFromContent failed with error %d", status);
	}	
	return (status == noErr);
}

-(void) deleteItem
{
	// just delete and let the item changed notifications sort out the display, etc
	
	NSAlert *alert = [[NSAlert alloc] init];
	[alert addButtonWithTitle:@"Cancel"];
	[alert addButtonWithTitle:@"Delete anyway"];
	[alert setMessageText:@"Do you really want to delete the entire Keychain?"];
	[alert setInformativeText:@"This permanently and IRREVERSIBLY deletes the Keychain file from disk......"];
	[alert setAlertStyle:NSWarningAlertStyle];
	
	if ([alert runModal] == NSAlertSecondButtonReturn) {
		// Delete clicked
		OSStatus status = SecKeychainDelete(keyChainRef);	
		if (status != noErr) {
			NSLog(@"KeyChainDD Warning - SecKeychainDelete failed with error %d", status);
		}
	}
	[alert release];			
}


@end
