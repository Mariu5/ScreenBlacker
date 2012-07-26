/**
 
 @file    F53NSScreen.h
 @date    Created on 10/13/08.
 
 Copyright (c) 2008 Figure 53, LLC. All rights reserved.
 
**/

#import <Cocoa/Cocoa.h>


@interface NSScreen (F53NSScreen)

+ (NSScreen *) screenWithDisplayID: (CGDirectDisplayID) displayID;
+ (NSScreen *) screenWithDisplayName: (NSString *) displayName;
+ (NSScreen *) screenWithSerialNumber: (NSString *) serialNumber;

- (CGDirectDisplayID) displayID;
- (NSString *) displayName;
- (NSString *) serialNumber;

@end
