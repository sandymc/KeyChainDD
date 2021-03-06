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
* keychainDDInspector.h
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
* Inspector for KeyChain items
*/

#import <Cocoa/Cocoa.h>
#import <Node.h>

@interface keychainDDInspector: NSObject {

	IBOutlet NSButton *applyButton;
	IBOutlet NSButton *cancelButton;
	IBOutlet NSButton *plainTextButton;
	
	IBOutlet NSTextField *nameField;
	IBOutlet NSTextField *userIdField;
	IBOutlet NSTextField *passwordField;
	IBOutlet NSSecureTextField *passwordFieldSecure;
	IBOutlet NSTextField *miField;
	IBOutlet NSSecureTextField *miFieldSecure;
	Node *myNode;
	bool newFlag;
	NSColor *savedTextBackground;
	IBOutlet NSPanel* inspectorPanel;	
}

- (IBAction) applyButtonPress:(id)sender;
- (IBAction) cancelButtonPress:(id)sender;
- (IBAction) plainTextButtonPress:(id)sender;

- (void) setNode:(Node *) node createNew:(bool)createNew;
@end
