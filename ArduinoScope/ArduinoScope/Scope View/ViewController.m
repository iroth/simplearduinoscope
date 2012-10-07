//
//  ViewController.m
//  ArduinoSerial
//
//  Created by Pat O'Keefe on 4/30/09.
//  Copyright 2009 POP - Pat OKeefe Productions. All rights reserved.
//
//	Portions of this code were derived from Andreas Mayer's work on AMSerialPort. 
//	AMSerialPort was absolutely necessary for the success of this project, and for
//	this, I thank Andreas. This is just a glorified adaptation to present an interface
//	for the ambitious programmer and work well with Arduino serial messages.
//  
//	AMSerialPort is Copyright 2006 Andreas Mayer.
//



#import "ViewController.h"
#import "AMSerialPortList.h"
#import "AMSerialPortAdditions.h"


@implementation ViewController

//@synthesize serialSelectMenu;
//@synthesize textField;
@synthesize scopeView;
@synthesize waitForTrigger;
@synthesize scaleUpButton;
@synthesize scaleDownButton;
@synthesize scaleLabel;

- (void)awakeFromNib
{
	
	[sendButton setEnabled:NO];
	
	/// set up notifications
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddPorts:) name:AMSerialPortListDidAddPortsNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRemovePorts:) name:AMSerialPortListDidRemovePortsNotification object:nil];
	
	/// initialize port list to arm notifications
	[AMSerialPortList sharedPortList];
	[self listDevices];
	
	curScale = 1;
	[scaleDownButton setEnabled:NO];
	[scaleUpButton setEnabled:YES];
	[scaleLabel setStringValue:@"x 1"];
	
}

- (IBAction)attemptConnect:(id)sender {
	
	[serialScreenMessage setStringValue:@"Attempting to Connect..."];
	[self initPort];
	
}

	
# pragma mark Serial Port Stuff
	
- (void)initPort
{
	NSString *deviceName = [serialSelectMenu titleOfSelectedItem];
	if (![deviceName isEqualToString:[port bsdPath]]) {
		[port close];
		
		[self setPort:[[[AMSerialPort alloc] init:deviceName withName:deviceName type:(NSString*)CFSTR(kIOSerialBSDModemType)] autorelease]];
		[port setDelegate:self];
		
		if ([port open]) {
			
			//Then I suppose we connected!
			NSLog(@"successfully connected");

			[connectButton setEnabled:NO];
			[sendButton setEnabled:YES];
			[serialScreenMessage setStringValue:@"Connection Successful!"];

			//TODO: Set appropriate baud rate here. 
			
			//The standard speeds defined in termios.h are listed near
			//the top of AMSerialPort.h. Those can be preceeded with a 'B' as below. However, I've had success
			//with non standard rates (such as the one for the MIDI protocol). Just omit the 'B' for those.
		
			// [port setSpeed:B38400];
			[port setSpeed:B115200];
			

			// listen for data in a separate thread
			[port readDataInBackground];
			
			
		} else { // an error occured while creating port
			
			NSLog(@"error connecting");
			[serialScreenMessage setStringValue:@"Error Trying to Connect..."];
			[self setPort:nil];
			
		}
	}
}

- (void)serialPortReadData:(NSDictionary *)dataDictionary
{
	
	AMSerialPort *sendPort = [dataDictionary objectForKey:@"serialPort"];
	NSData *data = [dataDictionary objectForKey:@"data"];
	
	if ([data length] > 0) {
		
		unsigned char *d = (unsigned char *) [data bytes];
		for (int i = 0 ; i < [data length] ; i ++) {
			int v = (int) d[i];
			[scopeView pushValue:v];
		}
		[scopeView setNeedsDisplay:YES];
		
		// continue listening
		[sendPort readDataInBackground];

	} else { 
		// port closed
		NSLog(@"Port was closed on a readData operation...not good!");
	}
	
}

- (void)listDevices
{
	// get an port enumerator
	NSEnumerator *enumerator = [AMSerialPortList portEnumerator];
	AMSerialPort *aPort;
	[serialSelectMenu removeAllItems];
	
	while (aPort = [enumerator nextObject]) {
		[serialSelectMenu insertItemWithTitle:[aPort bsdPath] atIndex:0];
//		[serialSelectMenu addItemWithTitle:[aPort bsdPath]];
	}
}

- (IBAction)send:(id)sender
{
	
	NSString *sendString = [[textField stringValue] stringByAppendingString:@"\r"];
	
	 if(!port) {
	 [self initPort];
	 }
	 
	 if([port isOpen]) {
	 [port writeString:sendString usingEncoding:NSUTF8StringEncoding error:NULL];
	 }
}

- (AMSerialPort *)port
{
	return port;
}

- (void)setPort:(AMSerialPort *)newPort
{
	id old = nil;
	
	if (newPort != port) {
		old = port;
		port = [newPort retain];
		[old release];
	}
}

	
# pragma mark Notifications
	
- (void)didAddPorts:(NSNotification *)theNotification
{
	NSLog(@"A port was added");
	[self listDevices];
}

- (void)didRemovePorts:(NSNotification *)theNotification
{
	NSLog(@"A port was removed");
	[self listDevices];
}

// GUI actions

- (IBAction)waitForTriggerClicked:(id)sender {

	if (waitForTrigger.state == NSOnState) {
		[scopeView startWaitForTrigger];
	}
	else {
		[scopeView stopWaitForTrigger];
	}

}

- (IBAction)scaleUpPushed:(id)sender {
	if (curScale < 20) {
		curScale++;
		[scopeView setScale:curScale];
		if (curScale >= 20) {
			[scaleUpButton setEnabled:NO];
		}
		[scaleDownButton setEnabled:YES];
		[scaleLabel setStringValue:[NSString stringWithFormat:@"x %d", curScale]];
	}
}

- (IBAction)scaleDownPushed:(id)sender {
	if (curScale > 1) {
		curScale--;
		[scopeView setScale:curScale];
		if (curScale <= 1) {
			[scaleDownButton setEnabled:NO];
		}
		[scaleUpButton setEnabled:YES];
		[scaleLabel setStringValue:[NSString stringWithFormat:@"x %d", curScale]];
	}
}

- (IBAction)copyToRefPressed:(id)sender {
	[scopeView copyToRef];
}

- (IBAction)retriggerPressed:(id)sender {
	[waitForTrigger setState:NSOnState];
	[scopeView reTrigger];
}

@end
