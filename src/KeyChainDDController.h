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
* KeyChainDDController.h
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
* Controller
*/



#import <Cocoa/Cocoa.h>
#import <MainWinController.h>
#import <NewKeychainInspector.h>
#import "SplashScreenPanel.h"

@interface KeyChainDDController : NSObject
{
	IBOutlet NSWindow *window;
	IBOutlet NSMenu *mainMenu;
    IBOutlet MainWinController *winController;
	IBOutlet newKeychainInspector *newKeychainController;
	IBOutlet SplashScreenPanel *splashScreenPanel;
	BOOL disableMenus;
	int pboardCount;
	NSTimer *splashScreenTimer;
	int splashScreenCountDown;
}

- (void) windowWillClose:(NSNotification *)notification;

- (IBAction)performOpenPreferencesWindow:(id)sender;
- (IBAction)performNewPasswordItem:(id)sender;
- (IBAction)performNewKeychain:(id)sender;
- (IBAction)performDeleteKeychain:(id)sender;
- (IBAction)performGetInfo:(id)sender;
- (IBAction)performLockkeyChain:(id)sender;
- (IBAction)performKeyChainDDWeb:(id)sender;

- (void)disableMenuItems:(NSNotification *)notification;
- (void)enableMenuItems:(NSNotification *)notification;
- (void)itemOnPasteboard:(NSNotification *)notification;
- (void)appleKeychainLocked:(NSNotification *)notification;

//App delegate stuff
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication;
- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)anItem;

- (void)startSplashScreenPanel:(id)sender;

@end

