//
//  ScopeView.h
//  ArduinoSerial
//
//  Created by iroth on 9/29/12.
//
//

#import <Cocoa/Cocoa.h>

#define kBufSize 2048

@interface ScopeView : NSView {
	int values[kBufSize];
	int refValues[kBufSize];
	Boolean waitForTrigger;
	Boolean triggerFound;
	int curScale;
}

- (void) startWaitForTrigger;
- (void) stopWaitForTrigger;
- (void) reTrigger;

- (void) pushValue: (int) val;
- (void) setScale: (int) scale;
- (void) copyToRef;

@end
