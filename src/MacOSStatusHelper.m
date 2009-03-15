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
* MacOSStatusHelper.m
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
* Helper class to get human readable error messages from OS X status codes
*/

#import "MacOSStatusHelper.h"


@implementation MacOSStatusHelper


+ (NSString *) getErrorString:(OSStatus)status stringPrefix:(NSString *) prefix
{
	NSString *string;
	switch (status) {
		case errSecDuplicateKeychain:
			string = @"Keychain already exists";
			break;
		default:
			string = [NSString stringWithUTF8String:GetMacOSStatusErrorString(status)];
			if ((string == nil) || ([string length] < 1)) {
				string = @"Unknown Error";
			}
			break;
	}	
	if (prefix) {
		return [prefix stringByAppendingString:string];
	}
	else {
		return string;
	}	
}

+ (NSString *) getErrorDescription:(OSStatus)status stringPrefix:(NSString *) prefix
{
	NSString *string;
	switch (status) {
			//		case errSecDuplicateKeychain:
			//			string = @"Keychain already exists";
			//			break;
		default:
			string = [NSString stringWithUTF8String:GetMacOSStatusCommentString(status)];
			if ((string == nil) || ([string length] < 1)) {
				string = @"Unknown Error";
			}
			else {
				// Strip off some of the junk
				NSCharacterSet *characterSet = [NSCharacterSet uppercaseLetterCharacterSet];
				NSRange letterRangeUpper = [string rangeOfCharacterFromSet:characterSet];
				characterSet = [NSCharacterSet lowercaseLetterCharacterSet];
				NSRange letterRangeLower = [string rangeOfCharacterFromSet:characterSet];
				letterRangeUpper.location = letterRangeUpper.location > letterRangeLower.location ? 
											letterRangeLower.location : letterRangeUpper.location;
				letterRangeUpper.length = [string length] - letterRangeUpper.location;
				string = [string substringWithRange:letterRangeUpper];				
			}
			break;
	}	
	if (prefix) {
		return [prefix stringByAppendingString:string];
	}
	else {
		return string;
	}	
}

+ (NSString *) getLogString:(OSStatus)status calledFunction:(const char *)function stringPrefix:(NSString *) prefix
{
	if (prefix == nil) prefix = @"KeychainDD Error ";
	return [[self getErrorString:status stringPrefix:[prefix stringByAppendingString:[NSString stringWithUTF8String:function]]]
			stringByAppendingString:[self getErrorDescription:status stringPrefix:@": "]];	
}

+ (void) outputLogString:(OSStatus)status calledFunction:(const char *)function
{
	NSLog([self getLogString: status calledFunction:function stringPrefix:nil]);
}
@end
