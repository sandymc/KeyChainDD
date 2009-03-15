/* ==================================================
* keyChainDD - Drag and drop Password Managerfor OS X
* ===================================================
*
* Project Info:  http://sourceforge.net/projects/keychaindd/
* Project Lead:  Sandy McGuffog (sandy.cornerfix@gmail.com or <sandymcg at users.sourceforge.net>);
*
* (C) Copyright 2008, 2009, by Sandy McGuffog and Contributors.
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
* ImageAndTextCell.h
* ---------------
* (C) Copyright 2008, 2009, by Sandy McGuffog and Contributors.
*
* Original code from tnefDD
*
* ImageAndTextCell is based on the ideas contained in various versions of ImageAndTextCell
* classes in Apple's developer examples. It combines various of these, and adds the ability 
* to:
* a) support multiple columns
* b) Allign text and image accross multiple columns
* c) Flexibly resixe images to suit the column sizing 
* d) understand FSNodes
*
* Original Author:  Sandy McGuffog;
* Contributor(s):   -;
* Based on code drawn from:
* a) Pierre d'Herbemont's VideoLan code;
* b) Steve Palmer's Vienna project;
* c) Various of the Apple developer example implementations by Chuck Pisula, Corbin Dunn and others
*
*
*
*
* Changes
* -------
* 14 Aug 2008 : Original version;
* 9 September 2008 : tnefDD 0.9.0.1 - Fix Tiger compatibility bug
* 3 March 2009 : Improvement for keyChainDD - auto size of images, etc;
*
*/

/*
* Image and texy cell implementation for tnefDD.
*/


#import <Cocoa/Cocoa.h>

@interface ImageAndTextCell : NSTextFieldCell
{
@private
	NSImage *image;
}

- (void)setImage:(NSImage *)anImage;
- (NSImage*)image;

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView*)controlView;
- (NSSize)cellSize;

@end
