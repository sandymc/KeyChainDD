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
* DragButton.m
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
* Overrides to get a dragable button
*/

#import "DragButton.h"


@implementation DragButton

- (id)init
{
    if (self == [super init])
    {
		selectedItem = nil;
		userIdFlag = NO;
		trackingRect = nil;
#if __debug
		NSLog(@"DragButton init");
#endif		
	}
	return self;
}

- (void)setSelectedItem:(Node *)item
{
	selectedItem = item;
}

- (void)setUserIdFlag:(bool) flag
{
	userIdFlag = flag;
}


- (void) cachePreferences {	
	enablePasteCache = [[NSUserDefaults standardUserDefaults] boolForKey:@"enablePaste"];	
}

- (void) awakeFromNib {		
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(userPreferencesChanged:)
												 name:@"UserPreferencesChanged" 
											   object:nil];	
	[self cachePreferences];	
}

// ----------------------------------------------------------------------
//  draggingSourceOperationMaskForLocal:
// ----------------------------------------------------------------------
//  Indicates the type of drag operations we support.
//
- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
	if (isLocal)
	{
		return (NSDragOperationCopy);
	}
	else
	{
		return (NSDragOperationCopy);
	}
}

- (BOOL)shouldDelayWindowOrderingForEvent:(NSEvent *)theEvent
{
	return YES;
}

- (void)drawStringCenteredIn:(NSRect)r string:(NSString *) string withAttributes:(NSDictionary *) attributes
{
    NSPoint stringOrigin;
    NSSize stringSize;
    
    stringSize = [string sizeWithAttributes:attributes];
    stringOrigin.x = r.origin.x + (r.size.width - stringSize.width)/2;
    stringOrigin.y = r.origin.y + (r.size.height - stringSize.height)/2;
    [string drawAtPoint:stringOrigin withAttributes:attributes];
}

#if MAC_OS_X_VERSION_MIN_REQUIRED <= MAC_OS_X_VERSION_10_4
typedef unsigned int NSUInteger;
#endif

// This has to be mouseDown - mouseDrag isn't passed to buttons......
// Also, note that mouseUp events are eaten .................................
- (void)mouseDown:(NSEvent*)event
{	   	
#if __debug
	NSLog(@"MouseDrag");
#endif		
	/*------------------------------------------------------
	 catch mouse down events in order to start drag
	 --------------------------------------------------------*/
    if (selectedItem) {
		//get the Pasteboard used for drag and drop operations
		NSPasteboard* dragPasteboard=[NSPasteboard pasteboardWithName:NSDragPboard];
		
		//add the image types we can send the data as
		[dragPasteboard declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:self];
		if (userIdFlag) [dragPasteboard setString:[selectedItem returnUserId] forType:NSStringPboardType];
		else [dragPasteboard setString:[selectedItem returnPassword] forType:NSStringPboardType];
		if (enablePasteCache) {
			NSPasteboard *pBoard = [NSPasteboard pasteboardWithName:NSGeneralPboard];
			[pBoard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
			if (userIdFlag) {
				[pBoard setString:[selectedItem returnUserId] forType:NSStringPboardType];
			}
			else {
				[pBoard setString:[selectedItem returnPassword] forType:NSStringPboardType];
			}	
			NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
			// Note: Alloc'd here - have to release on end of message.........
			NSNumber *pBoardCount = [[NSNumber alloc] initWithInt:[pBoard changeCount]];
			[[NSNotificationCenter defaultCenter]  postNotificationName:@"ItemOnPasteboard" 
																 object:self 
															   userInfo: [NSDictionary dictionaryWithObject: pBoardCount forKey: @"pBoardCount"]];
			[pool release];
		}
		
		// Build a semi-transparent drag image
		
		NSImage* dragImage = nil;
		NSPoint imageLocation;
		
		if ([self image]) {
			// If this button has an image, then use the image
			dragImage=[[NSImage alloc] initWithSize:[[self image] size]]; 
			[dragImage lockFocus]; //draw inside of our dragImage
			//draw our original image as 50% transparent
			[[self image] dissolveToPoint: NSZeroPoint fraction: .5];
			[dragImage unlockFocus]; //finished drawing
			[dragImage setScalesWhenResized:YES]; //we want the image to resize
			[dragImage setSize:[self bounds].size]; //change to the size we are displaying
			imageLocation = [self bounds].origin;
			imageLocation.y += [self bounds].size.height;
		}
		else {
			// If it doesn't have an image, render text......
			NSSize s = [[self title] sizeWithAttributes:[[self attributedStringValue] attributesAtIndex:0 effectiveRange:nil]];
			dragImage = [[NSImage alloc] initWithSize:s];
			NSRect imageBounds;
			imageBounds.origin = NSMakePoint(0,0);
			imageBounds.size = s;
			[dragImage lockFocus];
			[self drawStringCenteredIn:imageBounds string:[self title] withAttributes:[[self attributedStringValue] attributesAtIndex:0 effectiveRange:nil]];
			[dragImage unlockFocus];
			imageLocation = [self bounds].origin;
			imageLocation.y += [self bounds].size.height/2 + s.height/2;
			imageLocation.x += s.width/2;
		}
		
		
		[self dragImage: dragImage //image to be displayed under the mouse
					 at: imageLocation //point to start drawing drag image
				 offset: NSZeroSize //no offset, drag starts at mousedown location
				  event: event //mousedown event
			 pasteboard: dragPasteboard //pasteboard to pass to receiver
				 source: self //object where the image is coming from
			  slideBack: YES]; //if the drag fails slide the icon back
		
		if (dragImage) [dragImage release];
	}
}

//- (BOOL)acceptsFirstMouse:(NSEvent *)event {
    /*------------------------------------------------------
	accept activation click as click in window
    --------------------------------------------------------*/
//    return NO;//so source doesn't have to be the active window
//}


-(void)resetCursorRects
{
    [self discardCursorRects];
    [self addCursorRect:[self visibleRect] cursor:[NSCursor openHandCursor]];
	
}

- (void)viewDidMoveToWindow {
    // trackingRect is an NSTrackingRectTag instance variable
    // eyeBox is a region of the view (instance variable)
#if __debug
	NSLog(@"viewDidMoveToWindow");
#endif	
    trackingRect = [self addTrackingRect:[self visibleRect] owner:self userData:NULL assumeInside:NO];	
    // remove the existing cursor rects
	[[self window] invalidateCursorRectsForView:self];
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
    if ( [self window] && trackingRect ) {
        [self removeTrackingRect:trackingRect];
    }
}


- (void)setFrame:(NSRect)frame {
    [super setFrame:frame];
    if (trackingRect) [self removeTrackingRect:trackingRect];
    trackingRect = [self addTrackingRect:[self visibleRect] owner:self userData:NULL assumeInside:NO];
}

- (void)setBounds:(NSRect)bounds {
    [super setBounds:bounds];
    if (trackingRect) [self removeTrackingRect:trackingRect];
    trackingRect = [self addTrackingRect:[self visibleRect] owner:self userData:NULL assumeInside:NO];
}


- (void)mouseEntered:(NSEvent *)theEvent {
#if __debug
	NSLog(@"mouseEntered");
#endif	
	if ([self isEnabled]) [self highlight:YES];
}

//- (void)mouseMoved:(NSEvent *)theEvent {}

- (void)mouseExited:(NSEvent *)theEvent {
#if __debug
	NSLog(@"mouseExited");
#endif	
	[self setIntValue:1];
	[self highlight:NO];
}

- (void)userPreferencesChanged:(NSNotification *)notification
{
#if __debug
	NSLog(@"%s: %s", __FUNCTION__, [((NSString *) [notification object]) UTF8String]);
#endif
	[self cachePreferences];
}

@end
