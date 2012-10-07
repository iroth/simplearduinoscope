//
//  ScopeView.m
//  ArduinoSerial
//
//  Created by iroth on 9/29/12.
//
//

#import "ScopeView.h"

@implementation ScopeView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		waitForTrigger = NO;
		triggerFound = NO;
    }
    
    return self;
}


- (void) pushValue: (int) val{

	if (waitForTrigger) {
		if (! triggerFound) {
			if (val < 128) {
				triggerFound = YES;
			}
			else {
				return;
			}
		}
		else { // trigger was found, just make sure we stop when trigger is at left
			if (values[0] < 128) {
				return;
			}
		}
	}
	int w = (int) self.frame.size.width;
	for (int i = 0 ; i < w ; i++) {
		values[i] = values[i+1];
	}
	values[w-1] = val;
}

- (void) startWaitForTrigger {
	waitForTrigger = YES;
	triggerFound = NO;
}

- (void) stopWaitForTrigger {
	waitForTrigger = NO;
}

- (void) reTrigger {

	for (int i = 0 ; i < kBufSize ; i++) {	// reset values
		values[i] = 255;
	}
	waitForTrigger = YES;
	triggerFound = NO;
	[self setNeedsDisplay:YES];

}

- (int) getY: (int) ind forRef: (Boolean) isRef {
//	int h = (int) self.frame.size.height;
	return isRef ? (int)(255 - refValues[ind]) : (int)(255 - values[ind]);
}

- (void) drawBGGrid {
	int w = (int) self.frame.size.width;
	int h = (int) self.frame.size.height;

	NSPoint m = {0, 0};
	NSPoint l = {0, h};

	for (int x = 0 ; x < w ; x += 10) {
		NSBezierPath * path = [NSBezierPath bezierPath];
		[path setLineWidth: 1];
		m.x = x;
		l.x = x;
		[path  moveToPoint: m];
		[path lineToPoint: l];
		if (x % 50 == 0)
			[[NSColor cyanColor] set];
		else
			[[NSColor lightGrayColor] set];
		[path stroke];
	}
}

- (void) drawGraphWithOffset: (int) yOff forRef: (Boolean) isRef {
	
	NSBezierPath * path = [NSBezierPath bezierPath];
	[path setLineWidth: 1];
	
	int w = (int) self.frame.size.width;
	NSPoint startPoint = {0, [self getY:yOff forRef:isRef]};
	[path  moveToPoint: startPoint];
	for (int i = 1 ; i < w ; i ++) {
		NSPoint midPoint = {i * curScale, yOff + [self getY:i forRef:isRef]};
		[path lineToPoint:midPoint];
	}
	if (isRef) {
		[[NSColor whiteColor] set];
	}
	else {
		[[NSColor yellowColor] set];
	}
	[path stroke];
}

- (void)drawRect:(NSRect)dirtyRect
{
	[[NSColor darkGrayColor] set];
	NSRectFill(self.bounds);
	[self drawBGGrid];
	[self drawGraphWithOffset:20 forRef:NO];
	[self drawGraphWithOffset:320 forRef:YES];
}

- (void) setScale:(int)scale {
	curScale = scale;
	[self setNeedsDisplay:YES];
}

- (void) copyToRef {
	for (int i = 0 ; i < kBufSize ; i++) {
		refValues[i] = values[i];
	}
	[self setNeedsDisplay:YES];
}

@end
