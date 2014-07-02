//
//  AppDelegate.m
//  ConvertPlistToPngs_v2
//
//  Created by JunXie on 14-7-1.
//  Copyright xiejun 2014. All rights reserved.
//

#import "AppDelegate.h"
#import "HelloWorldLayer.h"
#import "ModelConvertPlistToPngs.h"

@interface ConvertPlistToPngs_v2AppDelegate () <NSOpenSavePanelDelegate>

@end

@implementation ConvertPlistToPngs_v2AppDelegate
@synthesize window=window_, glView=glView_;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];

	// enable FPS and SPF
	[director setDisplayStats:YES];
	
	// connect the OpenGL view with the director
	[director setView:glView_];

	// EXPERIMENTAL stuff.
	// 'Effects' don't work correctly when autoscale is turned on.
	// Use kCCDirectorResize_NoScale if you don't want auto-scaling.
	[director setResizeMode:kCCDirectorResize_AutoScale];
	
	// Enable "moving" mouse event. Default no.
	[window_ setAcceptsMouseMovedEvents:NO];
	
	// Center main window
	[window_ center];
	
	[director runWithScene:[HelloWorldLayer scene]];
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.canChooseDirectories = NO;
    panel.canChooseFiles = YES;
    //    panel.directoryURL = [NSURL URLWithString:NSHomeDirectory()];
    panel.allowedFileTypes = @[@"plist"];
    panel.delegate = self;
    [panel runModal];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) theApplication
{
	return YES;
}

- (void)dealloc
{
	[[CCDirector sharedDirector] end];
	[window_ release];
	[super dealloc];
}

#pragma mark AppDelegate - IBActions

- (IBAction)toggleFullScreen: (id)sender
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	[director setFullScreen: ! [director isFullScreen] ];
}

- (IBAction)openFile:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.canChooseDirectories = NO;
    panel.canChooseFiles = YES;
//    panel.directoryURL = [NSURL URLWithString:NSHomeDirectory()];
    panel.allowedFileTypes = @[@"plist"];
    panel.delegate = self;
    [panel runModal];
}

- (BOOL)panel:(id)sender validateURL:(NSURL *)url error:(NSError **)outError {
    NSLog(@"url = %@, error = %@", url, *outError);
    if ( url ) {
        [[ModelConvertPlistToPngs sharedInstance] handlePlistPath:url.path];
    }
    return YES;
}
@end
