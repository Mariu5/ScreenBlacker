//
//  AppDelegate.h
//  Screen Blacker
//
//  Created by Sean Dougall on 5/17/12.
//  Copyright (c) 2012 Figure 53. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    NSMutableDictionary *_originalURLs;
    NSMutableDictionary *_originalOptions;
}

@property (assign) IBOutlet NSWindow *window;

@property (nonatomic, assign) BOOL black;

@end
