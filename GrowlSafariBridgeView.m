//
//  GrowlSafariBridgeView.m
//  GrowlSafariBridge
//
//  Created by uasi on 10/10/04.
//  Copyright 99cm.org 2010. All rights reserved.
//

#import "GrowlSafariBridgeView.h"
#import <Growl/GrowlApplicationBridge.h>


#define GSBNotification @"GSBNotification"


@interface GrowlSafariBridgeView (ExposedMethods)
- (BOOL)isGrowlInstalled;
- (BOOL)isGrowlRunning;
- (void)notifyWithTitle:(NSString *)title
            description:(NSString *)description;
- (void)notifyWithTitle:(NSString *)title
            description:(NSString *)description
               imageurl:(NSString *)imageurl
                options:(WebScriptObject *)options;
@end


@interface GrowlSafariBridgeView (Internal)
- (id)_initWithArguments:(NSDictionary *)arguments;
@end


@interface GrowlSafariBridgeDelegate : NSObject <GrowlApplicationBridgeDelegate>
- (NSDictionary *)registrationDictionaryForGrowl;
@end


@implementation GrowlSafariBridgeView

// WebPlugInViewFactory protocol

+ (NSView *)plugInViewWithArguments:(NSDictionary *)newArguments
{
    return [[[self alloc] _initWithArguments:newArguments] autorelease];
}

// WebPlugIn informal protocol

- (void)webPlugInInitialize
{
    [GrowlApplicationBridge setGrowlDelegate:[[GrowlSafariBridgeDelegate new] autorelease]];
}

- (void)webPlugInDestroy
{
}

- (id)objectForWebScript
{
    return self;
}

+ (NSString *)webScriptNameForSelector:(SEL)selector
{
    if (selector == @selector(notifyWithTitle:description:)) {
        return @"notify";
    }
    else if (selector == @selector(notifyWithTitle:description:imageurl:options:)) {
        return @"notifyWithOptions";
    }
    return nil;
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)selector
{
    if (selector == @selector(isGrowlInstalled) ||
        selector == @selector(isGrowlRunning) ||
        selector == @selector(notifyWithTitle:description:) ||
        selector == @selector(notifyWithTitle:description:imageurl:options:)) {
        return NO;
    }
    return YES;
}

@end


@implementation GrowlSafariBridgeView (ExposedMethods)

- (BOOL)isGrowlInstalled
{
    return [GrowlApplicationBridge isGrowlInstalled];
}

- (BOOL)isGrowlRunning
{
    return [GrowlApplicationBridge isGrowlRunning];
}

- (void)notifyWithTitle:(NSString *)title
            description:(NSString *)description
{
    [GrowlApplicationBridge notifyWithTitle:title
                                description:description
                           notificationName:GSBNotification
                                   iconData:nil
                                   priority:0
                                   isSticky:NO
                               clickContext:nil];
}

- (void)notifyWithTitle:(NSString *)title
            description:(NSString *)description
               imageurl:(NSString *)imageurl
                options:(id)options
{
    
    NSNumber *isSticky = nil;
    NSNumber *priority = nil;
    if (options != nil && [options isEqual:[WebUndefined undefined]]) {
        isSticky = [options valueForKey:@"isSticky"];
        priority = [options valueForKey:@"priority"];
    }
    if (isSticky == nil) {
        isSticky = [NSNumber numberWithBool:NO];
    }
    if (priority == nil) {
        priority = [NSNumber numberWithInt:0];
    }
    
    NSImage *image =  [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:imageurl]];
   
    [GrowlApplicationBridge notifyWithTitle:title
                                description:description
                           notificationName:GSBNotification
                                   iconData:[image TIFFRepresentation]
                                   priority:[priority intValue]
                                   isSticky:[isSticky boolValue]
                               clickContext:nil];
    
    [image release];
}

@end


@implementation GrowlSafariBridgeView (Internal)

- (id)_initWithArguments:(NSDictionary *)newArguments
{
    if (!(self = [super initWithFrame:NSZeroRect]))
        return nil;
    return self;
}

@end


@implementation GrowlSafariBridgeDelegate

- (NSDictionary *)registrationDictionaryForGrowl
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSArray arrayWithObject:GSBNotification], GROWL_NOTIFICATIONS_ALL,
            [NSArray arrayWithObject:GSBNotification], GROWL_NOTIFICATIONS_DEFAULT,
            nil];
}

@end

