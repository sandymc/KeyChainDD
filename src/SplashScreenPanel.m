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
* SplashScreenPanel.m
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
* Splash screen panel
*/

#import "SplashScreenPanel.h"


@implementation SplashScreenPanel

- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)styleMask backing:(NSBackingStoreType)backingType defer:(BOOL)flag
{
	return [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:backingType defer:flag];
}


- (void) awakeFromNib {
#if __debug
NSLog(@"%s called", __FUNCTION__);
#endif

	[self center];
	[self setLevel:NSFloatingWindowLevel];
	[self setOpaque:NO];
	[self setBackgroundColor: [NSColor grayColor]];
	/*
	// To find out what's actually in the Dictionary.......
	NSDictionary *test = [[NSBundle mainBundle] infoDictionary];	
	NSEnumerator *enumerator = [test keyEnumerator];
	id key;	
	while ((key = [enumerator nextObject])) {
		NSLog(@"key: %@, value: %@", key, [test objectForKey:key]);
	}
	*/
	
	NSString *bundleString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
	if (bundleString) [versionText setStringValue:[@"Version " stringByAppendingString:bundleString]];
	bundleString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSHumanReadableCopyright"];
	if (bundleString) [copyrightText setStringValue:bundleString];
	NSString *creditsPath;
	if ((creditsPath = [[NSBundle mainBundle] pathForResource:@"Credits" ofType:@"rtf"]) && [creditsText readRTFDFromFile:creditsPath]) {
		// Ok
	}
	else {
		[creditsText insertText:@"Lead Developer: Sandy McGuffog"];		
		}
}

// This detects basically anything, and closes the window. But doesn't release it......
- (void) sendEvent: (NSEvent *) anEvent
{
	switch ([anEvent type]) {
		case NSKeyDown:
		case NSLeftMouseDown:
		case NSRightMouseDown:
		case NSLeftMouseDragged:
		case NSRightMouseDragged:
		case NSTabletPoint:
		case NSOtherMouseDown:
#if __debug
			NSLog(@"%s called", __FUNCTION__);
#endif			
		[self orderOut:self];
			break;
		default:
			break;
	}
	[super sendEvent: anEvent];
}

@end
