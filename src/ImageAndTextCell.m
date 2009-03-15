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



#import "ImageAndTextCell.h"

@implementation ImageAndTextCell


#define kImageOriginXOffset 3
#define kImageOriginYOffset 1

#define kTextOriginXOffset	2
#define kTextOriginYOffset	0
#define kTextHeightAdjust	0
#define kImageSizeReduction 2



// -------------------------------------------------------------------------------
//	init:
// -------------------------------------------------------------------------------
- (id)init
{
#if __debug
	NSLog(@"%s called", __FUNCTION__);
#endif	
    if (self = [super init]) {

	}
	return self;
}

// -------------------------------------------------------------------------------
//	initWithCoder:
// -------------------------------------------------------------------------------
// Archiving support not really used here BUT this is what gets called for
// anything that's in the NIB - i.e. set in Interface Builder 
- (id)initWithCoder:(NSCoder*)coder
{
#if __debug
//	NSLog(@"%s called", __FUNCTION__);
#endif	
    if (self = [super initWithCoder:coder]) {

	}
    return self;
}

// -------------------------------------------------------------------------------
//	dealloc:
// -------------------------------------------------------------------------------
- (void)dealloc
{
    [image release];
    image = nil;
    [super dealloc];
}

// -------------------------------------------------------------------------------
//	copyWithZone:zone
// -------------------------------------------------------------------------------
// This is total black magic, copied from Apple's developer examples.......
- (id)copyWithZone:(NSZone*)zone
{
    ImageAndTextCell *cell = (ImageAndTextCell*)[super copyWithZone:zone];
    cell->image = [image retain];
    return cell;
}

// -------------------------------------------------------------------------------
//	setImage:anImage
// -------------------------------------------------------------------------------
- (void)setImage:(NSImage*)newImage
{
#if __debug
//	NSLog(@"%s called", __FUNCTION__);
#endif	
    if (newImage != image)
	{
        if (image) [image release];
        image = [newImage retain];
		[image setScalesWhenResized:YES];
     }
}



// -------------------------------------------------------------------------------
//	image:
// -------------------------------------------------------------------------------
- (NSImage*)image
{
    return image;
}

// -------------------------------------------------------------------------------
//	isGroupCell:
// -------------------------------------------------------------------------------
- (BOOL)isGroupCell
{
    return ([self image] == nil && [[self title] length] > 0);
}


// -------------------------------------------------------------------------------
//	titleRectForBounds:cellRect
//
//	Returns the proper bound for the cell's title while being edited
// -------------------------------------------------------------------------------
- (NSRect)titleRectForBounds:(NSRect)cellRect
{	
	if (image != nil) {
		// This sets the rect such that text alligns horisontally accross colums
		NSRect imageFrame;
		NSDivideRect(cellRect, &imageFrame, &cellRect, 3 + [image size].width, NSMinXEdge);

		imageFrame.origin.x += kImageOriginXOffset;
		imageFrame.origin.y -= kImageOriginYOffset;
		imageFrame.size = [image size];
		
		imageFrame.origin.y += ceil((cellRect.size.height - imageFrame.size.height) / 2);
		
		NSRect newFrame = cellRect;
		newFrame.origin.x += kTextOriginXOffset;
		newFrame.origin.y += kTextOriginYOffset;
		newFrame.size.height -= kTextHeightAdjust;

		return newFrame;
	}
	else {
		return cellRect;
	}
}

#if MAC_OS_X_VERSION_MIN_REQUIRED <= MAC_OS_X_VERSION_10_4
typedef double CGFloat;
#endif
// -------------------------------------------------------------------------------
//	drawWithFrame:cellFrame:controlView:
// -------------------------------------------------------------------------------
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView*)controlView
{
#if __debug
//	NSLog(@"%s called", __FUNCTION__);
#endif
if (image != nil)
	{
		// Scale the image to fit
		// We can do scaling here because of the way that NSImage caches reprisentations;
		// otherwise, this would be wildly inefficient.....
		NSSize scaledImageSize = cellFrame.size;
		scaledImageSize.height -= kImageSizeReduction;
		if (scaledImageSize.height != [image size].height) {
			scaledImageSize.width = scaledImageSize.height;		
			[image setSize:scaledImageSize];
		}
			
		// the cell has an image: draw the normal item cell
        NSRect imageFrame;
        NSDivideRect(cellFrame, &imageFrame, &cellFrame, 3 + [image size].width, NSMinXEdge);
 
        imageFrame.origin.x += kImageOriginXOffset;
		imageFrame.origin.y -= kImageOriginYOffset;
        imageFrame.size = [image size];
		
        if ([controlView isFlipped])
            imageFrame.origin.y += ceil((cellFrame.size.height + imageFrame.size.height) / 2);
        else
            imageFrame.origin.y += ceil((cellFrame.size.height - imageFrame.size.height) / 2);
		[image compositeToPoint:imageFrame.origin operation:NSCompositeSourceOver];

		NSRect newFrame = cellFrame;
		newFrame.origin.x += kTextOriginXOffset;
		newFrame.origin.y += kTextOriginYOffset;
		newFrame.size.height -= kTextHeightAdjust;
		[super drawWithFrame:newFrame inView:controlView];
    }
	else
	{
		if ([self isGroupCell])
		{
			// Center the text in the cellFrame, and call super to do the work of actually drawing. 
			CGFloat yOffset = floor((NSHeight(cellFrame) - [[self attributedStringValue] size].height) / 2.0);
			cellFrame.origin.y += yOffset;
			cellFrame.size.height -= (kTextOriginYOffset*yOffset);
			[super drawWithFrame:cellFrame inView:controlView];
		}
	}
}

// -------------------------------------------------------------------------------
//	cellSize:
// -------------------------------------------------------------------------------
- (NSSize)cellSize
{
#if __debug
//	NSLog(@"%s called", __FUNCTION__);
#endif	
    NSSize cellSize = [super cellSize];
    cellSize.width += (image ? [image size].width : 0) + 3;
    return cellSize;
}

#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_4

// -------------------------------------------------------------------------------
//	hitTestForEvent:
// -------------------------------------------------------------------------------
- (NSUInteger)hitTestForEvent:(NSEvent *)event inRect:(NSRect)cellFrame ofView:(NSView *)controlView {
    NSPoint point = [controlView convertPoint:[event locationInWindow] fromView:nil];
    // If we have an image, we need to see if the user clicked on the image portion.
    if (image != nil) {
        NSRect imageFrame;
        NSDivideRect(cellFrame, &imageFrame, &cellFrame, 3 + imageSize.width, NSMinXEdge);
        
        imageFrame.origin.x += 3;
        imageFrame.size = imageSize;
        // If the point is in the image rect, then it is a content hit
        if (NSMouseInRect(point, imageFrame, [controlView isFlipped])) {
            // We consider this just a content area. It is not trackable, nor it it editable text. If it was, we would or in the additional items.
            // By returning the correct parts, we allow NSTableView to correctly begin an edit when the text portion is clicked on.
            return NSCellHitContentArea;
        }        
    }
    // At this point, the cellFrame has been modified to exclude the portion for the image. Let the superclass handle the hit testing at this point.
    return [super hitTestForEvent:event inRect:cellFrame ofView:controlView];    
}
#endif
@end






