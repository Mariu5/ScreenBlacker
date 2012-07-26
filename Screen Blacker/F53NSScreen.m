/**
 
 @file    F53NSScreen.m
 @date    Created on 10/13/08.
 
 Copyright (c) 2008-2011 Figure 53, LLC. All rights reserved.
 
**/

#import "F53NSScreen.h"
#import <IOKit/IOKitLib.h>
#import <IOKit/graphics/IOGraphicsLib.h>

@implementation NSScreen (F53NSScreen)

+ (NSScreen *) screenWithDisplayID: (CGDirectDisplayID) displayID
{
    for (NSScreen *screen in [NSScreen screens])
    {
        if ([screen displayID] == displayID)
            return screen;
    }
    
    return nil;
}

+ (NSScreen *) screenWithDisplayName: (NSString *) displayName
{
    for (NSScreen *screen in [NSScreen screens])
    {
        if ([[screen displayName] isEqual:displayName])
            return screen;
    }
    
    return nil;
}

+ (NSScreen *) screenWithSerialNumber: (NSString *) serialNumber
{
    for (NSScreen *screen in [NSScreen screens])
    {
        if ([[screen serialNumber] isEqual:serialNumber])
            return screen;
    }
    
    return nil;
}

- (CGDirectDisplayID) displayID
{
    return [[[self deviceDescription] objectForKey:@"NSScreenNumber"] unsignedIntValue];
}

- (NSString *) displayName
{
    NSString *displayName = nil;
    CGDirectDisplayID displayID = [self displayID];
    io_service_t displayPort = CGDisplayIOServicePort(displayID);
    
    if (displayPort == MACH_PORT_NULL)
        return nil;  // No physical device to get a name from.
    
    CFDictionaryRef infoDict = IODisplayCreateInfoDictionary(displayPort, kIODisplayOnlyPreferredName);
    CFDictionaryRef nameDict = CFDictionaryGetValue(infoDict, CFSTR(kDisplayProductName));
    if (nameDict == NULL)
        return @"Unnamed";
    CFIndex count = CFDictionaryGetCount(nameDict);
    
    if (count == 0) {
        displayName = @"Unnamed";
    } else {
        CFStringRef *keys =   (CFStringRef *)malloc(count * sizeof(CFStringRef *));
        CFStringRef *values = (CFStringRef *)malloc(count * sizeof(CFStringRef *));
        
        CFDictionaryGetKeysAndValues(nameDict, (const void **)keys, (const void **)values);
        displayName = [NSString stringWithString:(NSString *)values[0]];
        
        free(keys);
        free(values);
    }
    
    CFRelease(infoDict);
    
    return displayName;
}

- (NSString *) serialNumber
{
    CGDirectDisplayID displayID = [self displayID];
    io_service_t displayPort = CGDisplayIOServicePort(displayID);
    
    if (displayPort == MACH_PORT_NULL)
        return nil;  // No physical device to get a name from.
    
    CFDictionaryRef infoDict = IODisplayCreateInfoDictionary(displayPort, kIODisplayOnlyPreferredName);
    
    NSString *serialString = (NSString *)CFDictionaryGetValue(infoDict, CFSTR(kDisplaySerialString));
    
    if (serialString == nil || [serialString length] == 0)
    {
        serialString = [NSString stringWithFormat:@"%@", (NSNumber *)CFDictionaryGetValue(infoDict, CFSTR(kDisplaySerialNumber))];
    }
    
    CFRelease(infoDict);
    
    return serialString;
}

@end
