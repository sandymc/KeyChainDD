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
* ScaledIconFactory.m
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
* Factory for various icons
*/

#import "ScaledIconFactory.h"


@implementation ScaledIconFactory

//static NSImage* keysOpenImage[3] = {nil,nil,nil};
static NSImage* keysOpenImage = nil;
static NSImage* keysClosedImage = nil;	
static NSImage* itemOkScaledImage = nil;	
static NSImage* itemBlockedScaledImage = nil;
static NSImage* smallLockedScaledImage = nil;
static NSImage* smallUnlockedScaledImage = nil;
static NSImage* smallDisabledScaledImage = nil;


+(void) cacheIcon:(NSImage **)icon named:(NSString *) iconName
{
	if (!(*icon)) {
		// Create and scale the image part of the attributed string
		(*icon) = [NSImage imageNamed: iconName];
		[*icon setDataRetained:YES];
		[*icon setScalesWhenResized:YES];
	}	
}


+(NSImage *)item_okIcon
{	
	[self cacheIcon:&itemOkScaledImage named:@"item_ok"];
	return itemOkScaledImage;
}

+(NSImage *)item_blockedIcon
{
	[self cacheIcon:&itemBlockedScaledImage named:@"item_blocked"];	
	return itemBlockedScaledImage;
}

+(NSImage *)small_lockedIcon
{
	[self cacheIcon:&smallLockedScaledImage named:@"Small Lock_Locked State"];	
	return smallLockedScaledImage;
}

+(NSImage *)small_unlockedIcon
{
	[self cacheIcon:&smallUnlockedScaledImage named:@"Small Lock_Unlocked State"];	
	return smallUnlockedScaledImage;
}

+(NSImage *)small_disabledIcon
{
	[self cacheIcon:&smallDisabledScaledImage named:@"Small Lock_Disabled State"];	
	return smallDisabledScaledImage;
}


+(NSAttributedString *)returnAttributedString:(NSImage **)icon named:(NSString *) iconName withString:(NSString *) nameString isEnabled:(bool)enabled
{
	NSTextAttachment *attachment;
	attachment = [[[NSTextAttachment alloc] init] autorelease];
	
	if (iconName) {
		NSTextAttachmentCell *cell = (NSTextAttachmentCell *) [attachment attachmentCell];
		[self cacheIcon:icon named:iconName];		
		[cell setImage: *icon];
	}
	else {
		NSTextAttachmentCell *cell = (NSTextAttachmentCell *) [attachment attachmentCell];
		[cell setImage: nil];
	}
	
	NSAttributedString *attrname;
	attrname = [[NSAttributedString alloc] initWithString: nameString];
	
	NSMutableAttributedString *iconString;
	iconString = (id)[NSMutableAttributedString attributedStringWithAttachment:attachment];
	[iconString appendAttributedString: attrname];
	
	if (!enabled) {
		[iconString beginEditing];
		[iconString addAttribute:NSForegroundColorAttributeName
					   value:[NSColor disabledControlTextColor]
					   range:NSMakeRange(1, [nameString length])];
		[iconString endEditing];
	}
	
	[attrname release];
	
	return (iconString);
}

+ (NSImage*) keysOpenImage
{
	//Cache some images......
	if (!keysOpenImage) keysOpenImage = [NSImage imageNamed: @"KeysOpen48"];
	return keysOpenImage;
}

+ (NSImage*) keysClosedImage
{
	if (!keysClosedImage) keysClosedImage = [NSImage imageNamed: @"KeysClosed48"];
	return keysClosedImage;
}

+(NSAttributedString *)item_okAttributedString:(NSString *) nameString isEnabled:(bool)enabled
{
	return [self returnAttributedString:&itemOkScaledImage named:@"item_ok" withString:nameString isEnabled:enabled];	
}

+(NSAttributedString *)item_blockedAttributedString:(NSString *) nameString isEnabled:(bool)enabled
{
	return [self returnAttributedString:&itemBlockedScaledImage named:@"item_blocked" withString:nameString isEnabled:enabled];	
}

+(NSAttributedString *)small_lockedAttributedString:(NSString *) nameString isEnabled:(bool)enabled
{
	return [self returnAttributedString:&smallLockedScaledImage named:@"Small Lock_Locked State" withString:nameString isEnabled:enabled];	
}

+(NSAttributedString *)small_unlockedAttributedString:(NSString *) nameString isEnabled:(bool)enabled
{
	return [self returnAttributedString:&smallUnlockedScaledImage named:@"Small Lock_Unlocked State" withString:nameString isEnabled:enabled];	
}

+(NSAttributedString *)small_disabledAttributedString:(NSString *) nameString isEnabled:(bool)enabled
{
	return [self returnAttributedString:&smallDisabledScaledImage named:@"Small Lock_Disabled State" withString:nameString isEnabled:enabled];	
}

+(NSAttributedString *)noIconAttributedString:(NSString *) nameString isEnabled:(bool)enabled
{
	return [self returnAttributedString:nil named:nil withString:nameString isEnabled:enabled];	
}
@end
