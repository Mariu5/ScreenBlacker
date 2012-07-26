//
//  AppDelegate.m
//  Screen Blacker
//
//  Created by Sean Dougall on 5/17/12.
//  Copyright (c) 2012 Figure 53. All rights reserved.
//

#import "AppDelegate.h"
#import "F53NSScreen.h"

@interface AppDelegate ()

- (void)_saveBackgroundImages;
- (void)_restoreBackgroundImages;

@end

#pragma mark -

@implementation AppDelegate

@synthesize window = _window;

@synthesize black = _black;

- (void)setBlack:(BOOL)black
{
    NSError *error = nil;
    if ( black )
    {
        _black = YES;
        [self _saveBackgroundImages];
        for ( NSScreen *screen in [NSScreen screens] )
        {
            NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:1.0], NSWorkspaceDesktopImageFillColorKey,
                                     [NSNumber numberWithInteger:NSImageScaleNone], NSWorkspaceDesktopImageScalingKey,
                                     nil];
            [[NSWorkspace sharedWorkspace] setDesktopImageURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForImageResource:@"black"]] forScreen:screen options:options error:&error];
            if ( error )
                NSLog( @"Error setting black image on %@: %@", screen, [error localizedDescription] );
        }
    }
    else
    {
        _black = NO;
        [self _restoreBackgroundImages];
    }
}

// TODO: handle display config updates

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	_originalURLs = [[NSMutableDictionary alloc] init];
	_originalOptions = [[NSMutableDictionary alloc] init];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	if ( self.black && NSRunAlertPanel( @"Keep black?", @"Would you like to keep your desktops black after quitting Screen Blacker, or revert to your previous background settings?", @"Revert", @"Keep black", nil ) == NSAlertDefaultReturn )
		self.black = NO;
}

- (void)dealloc
{
	[_originalURLs release];
	_originalURLs = nil;
	
	[_originalOptions release];
	_originalOptions = nil;
	
	[super dealloc];
}

- (void)_saveBackgroundImages
{
    for ( NSScreen *screen in [NSScreen screens] )
    {
        NSURL *url = [[NSWorkspace sharedWorkspace] desktopImageURLForScreen:screen];
        NSDictionary *options = [[NSWorkspace sharedWorkspace] desktopImageOptionsForScreen:screen];
        [_originalURLs setObject:url forKey:[NSNumber numberWithInteger:[screen displayID]]];
        [_originalOptions setObject:options forKey:[NSNumber numberWithInteger:[screen displayID]]];
    }
}

- (void)_restoreBackgroundImages
{
    NSError *error = nil;
    for ( NSNumber *screenID in [_originalURLs allKeys] )
    {
        NSScreen *screen = [NSScreen screenWithDisplayID:[screenID integerValue]];
        if ( screen )
        {
            [[NSWorkspace sharedWorkspace] setDesktopImageURL:[_originalURLs objectForKey:screenID] forScreen:screen options:[_originalOptions objectForKey:screenID] error:&error];
            if ( error )
                NSLog( @"Error restoring background image from %@ on screen %@", [_originalURLs objectForKey:screenID], screen );
        }
    }
}

@end
