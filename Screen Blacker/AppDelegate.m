//
//  AppDelegate.m
//  Screen Blacker
//
//  Created by Sean Dougall on 5/17/12.
//
//  Copyright (c) 2012 Figure 53 LLC, http://figure53.com
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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
    _black = !_black;
    NSError *error = nil;
    if ( _black )
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
    
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    _statusItem.image = [NSImage imageNamed:@"switch-off.png"];
    [_statusItem.image setTemplate:YES];
    
    _statusItem.highlightMode = NO;
    
    [_statusItem setAction:@selector(setBlack:)];
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
    _statusItem.image = [NSImage imageNamed:@"switch-on.png"];
}

- (void)_restoreBackgroundImages
{
    NSError *error = nil;
    for ( NSNumber *screenID in [_originalURLs allKeys] )
    {
        NSScreen *screen = [NSScreen screenWithDisplayID:(CGDirectDisplayID)[screenID integerValue]];
        if ( screen )
        {
            [[NSWorkspace sharedWorkspace] setDesktopImageURL:[_originalURLs objectForKey:screenID] forScreen:screen options:[_originalOptions objectForKey:screenID] error:&error];
            if ( error )
                NSLog( @"Error restoring background image from %@ on screen %@", [_originalURLs objectForKey:screenID], screen );
        }
    }
    _statusItem.image = [NSImage imageNamed:@"switch-off.png"];
}

@end
