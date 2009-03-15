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
* ScaledIconFactory.h
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

#import <Cocoa/Cocoa.h>


@interface ScaledIconFactory : NSObject {

}

+(NSImage *)item_okIcon;
+(NSImage *)item_blockedIcon;
+(NSImage *)small_lockedIcon;
+(NSImage *)small_unlockedIcon;
+(NSImage *)small_disabledIcon;

+ (NSImage*) keysOpenImage;
+ (NSImage*) keysClosedImage;

+(NSAttributedString *)item_okAttributedString:(NSString *) nameString isEnabled:(bool)enabled;
+(NSAttributedString *)item_blockedAttributedString:(NSString *) nameString isEnabled:(bool)enabled;
+(NSAttributedString *)small_lockedAttributedString:(NSString *) nameString isEnabled:(bool)enabled;
+(NSAttributedString *)small_unlockedAttributedString:(NSString *) nameString isEnabled:(bool)enabled;
+(NSAttributedString *)small_disabledAttributedString:(NSString *) nameString isEnabled:(bool)enabled;
+(NSAttributedString *)noIconAttributedString:(NSString *) nameString isEnabled:(bool)enabled;
@end
