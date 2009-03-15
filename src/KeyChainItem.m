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
* KeyChainItem.m
* -------------------------------------
* (C) Copyright 2009, by Sandy McGuffog and Contributors.
*
* Original Author:  Sandy McGuffog;
* CheckAccessToApp code derived in part from Simon Fell's SF3 code
* Contributor(s):   -;
*
* Changes
* -------
* 3 March 2009 : Original version;
*
*/

/*
* Reprisents an item in a keychain
* CheckAccessToApp code derived in part from Simon Fell's SF3 code
*/



#import "KeyChainItem.h"
#include <Security/SecKeychain.h>
#include <Security/SecKeychainItem.h>
#include <Security/SecAccess.h>
#include <Security/SecTrustedApplication.h>
#include <Security/SecACL.h>


@implementation KeyChainItem


-(NSMutableString *) buffer2NSString:(const char *)buffer length:(UInt32)length
{
	char passwordBuffer[1024];
	if (length > 1023) {
		length = 1023; // save room for trailing \0
	}
	strncpy (passwordBuffer, buffer, length);
	passwordBuffer[length] = '\0';

//	return 	[[NSString stringWithCString:passwordBuffer encoding:NSUTF8StringEncoding] retain];
	return 	[NSString stringWithCString:passwordBuffer encoding:NSUTF8StringEncoding];
}



-(id)init
{
    if (self == [super init])
    {
		keyChainItemRef = nil;
    }
    return self;
}

//////////
//
// numberOfChildren
//
// Called by our NSOutlineView data source object. Returns the number of objects in our array.
//
//////////

-(bool)isItemExpandable
{
	// Note here we might not actually have read any data..... 
    return NO;
}

-(id)initWithKeyChainItemRef:(SecKeychainItemRef)keyChainItem  parent:(Node *) parent {
	
	[self init];
	parentNode = parent;
	
	// obtain attributes from KeychainItem
	SecKeychainAttribute attributes[2];
	attributes[0].tag = kSecLabelItemAttr;
	attributes[1].tag = kAccountKCItemAttr;
	
	SecKeychainAttributeList attrList = {2, attributes};
	
	OSStatus status = SecKeychainItemCopyContent(keyChainItem,
										NULL,
										&attrList,
										NULL, NULL);
	
	if (status) {
		NSLog(@"KeyChainDD Warning - Could not copy keychain item......");	
	}
	else {
		if (keyChainItemRef) {
			CFRelease(keyChainItemRef);
			keyChainItemRef = nil;
		}
		keyChainItemRef = keyChainItem;
		[nameString release];
		nameString = [[self buffer2NSString:attributes[0].data 
									length:attributes[0].length] retain];
		SecKeychainItemFreeContent(&attrList, NULL);
	}	
	
	return self;
	
}

-(bool)hasUserIdPassword
{
	return YES;
}

-(bool)isUnlocked
{	
	return [parentNode isUnlocked];
}

-(bool)lock
{
	return [parentNode lock];
}

-(bool)unlock
{
	return (didUnlock = [parentNode unlock]);
}


-(NSString *)returnUserId
{
	NSString *retVal = nil;
	
	// We want the account name attribute
	SecKeychainAttribute attributes[1];
	attributes[0].tag = kAccountKCItemAttr;
	
	SecKeychainAttributeList attrList = {1, attributes};
	
	OSStatus status = SecKeychainItemCopyContent(keyChainItemRef, NULL, &attrList, NULL, NULL);
	if (status == noErr) {
		// attr.data is the account (username) and outdata is the password
		retVal = [self buffer2NSString:attributes[0].data 
								length:attributes[0].length];
		SecKeychainItemFreeContent(&attrList, NULL);
	}
	else {
		NSLog([NSString stringWithFormat:@"return UserId failed on item: %@: %i", (NSString *) [self returnObjValue:self], status]);
		retVal = nil;
	}
	return retVal;
}

-(NSString *)returnPassword
{
	UInt32 length; 
	void *outData = nil;
	NSString *retVal = nil;
	int i;
	
	// We want the account name attribute
	SecKeychainAttribute attributes[1];
	attributes[0].tag = kAccountKCItemAttr;
	
	SecKeychainAttributeList attrList = {1, attributes};
	
	OSStatus status = SecKeychainItemCopyContent(keyChainItemRef, NULL, &attrList, &length, &outData);
	if (status == noErr) {
		// attr.data is the account (username) and outdata is the password
		retVal = [self buffer2NSString:outData 
									length:length];
		// Erase the password
		if (outData) for (i = 0; i < length; i++) ((char *)outData)[i] = 0;
	}
	else {
		NSLog([NSString stringWithFormat:@"return Password failed on item: %@: %i", (NSString *) [self returnObjValue:self], status]);
		retVal = nil;
	}
	if (outData) {
		SecKeychainItemFreeContent(&attrList, outData);
	}
	return retVal;
}

-(NSString *)returnGenericItem
{
	NSString *retVal = nil;
	
	// We want the account name attribute
	SecKeychainAttribute attributes[1];
	attributes[0].tag = kGenericKCItemAttr;
	
	SecKeychainAttributeList attrList = {1, attributes};
	
	OSStatus status = SecKeychainItemCopyContent(keyChainItemRef, NULL, &attrList, NULL, NULL);
	if (status == noErr) {
		// attr.data is the Generic Item and outdata is the password
		// we use the generic item as the challenge item
		retVal = [self buffer2NSString:attributes[0].data 
								length:attributes[0].length];
		SecKeychainItemFreeContent(&attrList, NULL);
	}
	else {
		NSLog([NSString stringWithFormat:@"return GenericItem failed on item: %@: %i", (NSString *) [self returnObjValue:self], status]);
		retVal = nil;
	}
	return retVal;
}


BOOL checkAccessToAcl(SecACLRef acl, NSData *thisAppHash) {
	NSArray *apps;
	NSString *desc;
	CSSM_ACL_KEYCHAIN_PROMPT_SELECTOR ps;
	OSStatus status = SecACLCopySimpleContents(acl, (CFArrayRef *)&apps, (CFStringRef *)&desc, &ps);
	BOOL retVal = NO;
	if (status == noErr) {
		// If the app list is null, anyone can access the entry
		if (apps == nil) {
			retVal = YES;	
		} else {
			// Iterate the apps in the ACL
			NSData *aData;
			SecTrustedApplicationRef a;
			NSEnumerator *e = [apps objectEnumerator];
			while ((!retVal) && (a = (SecTrustedApplicationRef)[e nextObject])) {
				SecTrustedApplicationCopyData(a, (CFDataRef *)&aData);
				if ([aData isEqualToData:thisAppHash]) retVal = YES;
				CFRelease(aData);
			}
			CFRelease(apps);
		}
		CFRelease(desc);
	} else {
		NSLog(@"KeyChainDD Warning - SecACLCopySimpleContents failed with error %d", status);
	}
	return retVal;
}


-(bool)appHasAccess
{
// The Code below worked under 10.4 (Tiger). Regretably, Leopard (10.5) breaks it
// So replaced by ACL access code derived from Simon Fell's SF3 project
// However, this is modified from Simon's code - under Leopard, if a keychain is 
// copied from another machine, and then OS X grants access, it does so via an acl 
// authorized for CSSM_ACL_AUTHORIZATION_ENCRYPT. Not clear why, but that's what happens
// Simon's code searched only for DECRYPT, which is fine if the items was created on this
// machine, but not otherwise.
  
//	UInt32 length; 
//	void *outData = nil;
//	bool retVal = NO;
//	OSStatus status;
//	Boolean oldInteractionState;
//	int i;
//	
//	if ([self isUnlocked]) {	
//		// Save the old state to restore it......
//		status = SecKeychainGetUserInteractionAllowed (&oldInteractionState);
//		status = SecKeychainSetUserInteractionAllowed (FALSE);
//		// We want the account name attribute
//		SecKeychainAttribute attributes[1];
//		attributes[0].tag = kAccountKCItemAttr;
//		
//		SecKeychainAttributeList attrList = {1, attributes};
//		
//		status = SecKeychainItemCopyContent(keyChainItemRef, NULL, &attrList, &length, &outData);
//		// Erase the password
//		if (outData) for (i = 0; i < length; i++) ((char *)outData)[i] = 0;
//		SecKeychainSetUserInteractionAllowed (oldInteractionState);
//		// According to the docs, with user interaction not allowed, we should get errSecInteractionRequired.
//		// Unfortunately, not the case - we get errSecAuthFailed
//		// so just check for any error......
//		if (status == noErr) {
//			// attr.data is the account (username) and outdata is the password
//			retVal = YES;
//		}
//		else {
//			retVal = NO;
//		}
//		if (outData) {
//			SecKeychainItemFreeContent(&attrList, outData);
//		}
//	}
//	else {
//		retVal = NO;
//	}
//	
//	return retVal;

	SecTrustedApplicationRef app;
	// First create a trusted application object
	OSStatus status = SecTrustedApplicationCreateFromPath(NULL, &app);
	if (status != noErr) {
		NSLog(@"KeyChainDD Warning - SecTrustedApplicationCreateFromPath failed with error %d", status);
		return NO;
	}
	NSData *thisAppHash;
	BOOL res = NO;
	// Now get KeyChainDD's cryptographic hash
	status = SecTrustedApplicationCopyData(app, (CFDataRef *)&thisAppHash);
	if (status == noErr) {
		SecAccessRef access;
		// Get the keychain's access object
		status = SecKeychainItemCopyAccess(keyChainItemRef, &access);
		if (status == noErr) {
			NSArray *acls;
			// Now get the list of all ACLs in the access object
			status = SecAccessCopyACLList(access, (CFArrayRef *)&acls);
			if (status == noErr) {
				SecACLRef acl;
				CSSM_ACL_AUTHORIZATION_TAG tags[50];
				uint32 tagCount;
				// Iterate through the lists
				NSEnumerator *e = [acls objectEnumerator];
				while ((!res) && (acl = (SecACLRef)[e nextObject])) {
					// We need to have access to the acl
					if (checkAccessToAcl(acl, thisAppHash)) {
						tagCount = 50;
						status = SecACLGetAuthorizations (acl, tags, &tagCount);
						if (status == noErr) {
							// We also need to have teh acl authorised for something useful
							// Note that the ENCRYPT setting makes no sense, but that's what OSX set to show you can access a password
							while ((!res) && --tagCount >= 0) {
								res = res || (tags[tagCount] == CSSM_ACL_AUTHORIZATION_DECRYPT) || (tags[tagCount] == CSSM_ACL_AUTHORIZATION_ENCRYPT);
							}
						}
						else {
							NSLog(@"KeyChainDD Warning - SecACLGetAuthorizations failed with error %d", status);
						}
					}
				}
				CFRelease(acls);
			} 
			else {
				NSLog(@"KeyChainDD Warning - SecAccessCopyACLList failed with error %d", status);
			}
			CFRelease(access);
		} 
		else {
			NSLog(@"KeyChainDD Warning - SecKeychainItemCopyAccess failed with error %d", status);
		}
		CFRelease(thisAppHash);
	} 
	else {
		NSLog(@"KeyChainDD Warning - SecTrustedApplicationCopyData failed with error %d", status);
	}
	CFRelease(app);
	return res;	
}

- (bool) changeItemData:(NSString *)label username:(NSString *)username password:(NSString *)password mi:(NSString *)mi {
	OSStatus status = nil;
	if ([self hasUserIdPassword]) {
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
			{ kGenericKCItemAttr, strlen(utf8Mi), (char *) utf8Mi }
		};
		SecKeychainAttributeList attributes = { sizeof(attrs) / sizeof(attrs[0]), attrs };
		status = SecKeychainItemModifyAttributesAndData(keyChainItemRef,
														&attributes,
														[passwordData length],
														(void *)[passwordData bytes]);
		if (status != noErr) {
			NSLog(@"KeyChainDD Warning - SecKeychainItemModifyAttributesAndData failed with error %d", status);
		}
	}
	else {
		status = 1000;
		}
	
	return (status == noErr);
}

-(bool) createNewItem:(NSString *)label username:(NSString *)username password:(NSString *)password mi:(NSString *)mi
{
	return [parentNode createNewItem:label username:username password:password mi:mi];
}

-(void) deleteItem
{
	// just delete and let the item changed notificattions sort out the display, etc
	OSStatus status = SecKeychainItemDelete(keyChainItemRef);	
	if (status != noErr) {
		NSLog(@"KeyChainDD Warning - SecKeychainItemDelete failed with error %d", status);
	}
}


-(int)length{
	int i = 0;
	return i;
}


-(void)dealloc {
	[super dealloc];
}





@end
