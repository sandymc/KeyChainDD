/* ==================================================
* keyChainDD - Drag and drop Password Managerfor OS X
* ===================================================
*
* Project Info:  http://sourceforge.net/projects/keychaindd/
* Project Lead:  Sandy McGuffog (sandy.cornerfix@gmail.com or <sandymcg at users.sourceforge.net>);
*
* (C) Copyright 2007, 2008, 2009, by Sandy McGuffog and Contributors.
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
* ---------------
* PrefsWindowController.h
* ---------------
* (C) Copyright 2007, by Sandy McGuffog and Contributors.
*
* Original Author:  Sandy McGuffog;
* Contributor(s):   -;
*
*
* Changes
* -------
* 1 Sept 2007 : 0.9.1.0 Mac version
* 3 March 2009 : KeyChainDD version;
*
*/

/*
 * The preference window form for CornerFix for the Mac.
 * Derived from Dave Batton's DBPrefsWindowController
 *  http://www.Mere-Mortal-Software.com/blog/
 */

#import <Cocoa/Cocoa.h>
#import "DBPrefsWindowController.h"

@interface PrefsWindowController : DBPrefsWindowController {
	IBOutlet NSView *generalPrefsView;
	IBOutlet NSView *timeOutPrefsView;
}


@end
