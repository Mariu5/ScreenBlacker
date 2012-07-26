//
//  F53NSScreen.m
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
