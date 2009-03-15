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
* MainWinController.h
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
* Controller for the main window
*/

#import <Cocoa/Cocoa.h>
#import "MyDataSource.h"
#import "DragButton.h"
#import "keychainDDInspector.h"
#import "miPanelController.h"

@interface MainWinController : NSObject {
	IBOutlet NSOutlineView *myOutlineView;
//	IBOutlet NSTokenField *userIdToken;
//	IBOutlet NSTokenField *passwordToken;
	IBOutlet NSButton *lockButton;
	IBOutlet DragButton *userIdDragButton;
	IBOutlet DragButton *passwordDragButton;
	IBOutlet NSTextField *helpField;
	IBOutlet NSPanel* myPanel;
	IBOutlet keychainDDInspector* inspectorController;
	IBOutlet miPanelController* miController;	
	NSColor *bgColor;


}
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item;
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item;
- (IBAction) lockButtonPress:(id)sender;
- (IBAction) useridButtonPress:(id)sender;
- (IBAction) passwordPress:(id)sender;
- (IBAction) addItemContextMenu:(id)sender;
- (IBAction) editItemContextMenu:(id)sender;
- (IBAction) deleteItemContextMenu:(id)sender;
- (void) setLockButtonImage:(Node *) item;
- (void)appleKeychainLocked:(NSNotification *)notification;
- (void)appleKeychainUnlocked:(NSNotification *)notification;
- (void)appleKeychainChanged:(NSNotification *)notification;
- (Node *)getSelectedItem;
- (void)showInspectorSheet:(Node *) node createNew:(bool)createNew;
- (void)closedownKeyChains;
@end
