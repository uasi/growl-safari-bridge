//
//  GrowlSafariBridgeView.m
//  GrowlSafariBridge
//
//  Created by uasi on 10/10/04.
//  Copyright isdead.info 2011. All rights reserved.
//

#import "GrowlSafariBridgeView.h"
#import <Growl/GrowlApplicationBridge.h>


#define GSBNotification @"GSBNotification"


@interface GrowlSafariBridgeView (ExposedMethods)
- (BOOL)isGrowlInstalled;
- (BOOL)isGrowlRunning;
- (void)notifyWithTitle:(NSString *)title
            description:(NSString *)description
                options:(WebScriptObject *)options;

// NOTE:
// Defined only for backward compatibility
- (void)_notifyWithTitle:(NSString *)title
             description:(NSString *)description
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
    if (selector == @selector(notifyWithTitle:description:options:)) {
        return @"notify";
    }

    // invokeUndefinedMethodFromWebScript:withArguments: で notifyWithOptions を
    // notify に飛ばしたほうがいいんだけど、なぜか invoke〜 が呼ばれないので別に定義
    if (selector == @selector(_notifyWithTitle:description:options:)) {
        return @"notifyWithOptions";
    }
    return nil;
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)selector
{
    if (selector == @selector(isGrowlInstalled) ||
        selector == @selector(isGrowlRunning) ||
        selector == @selector(notifyWithTitle:description:options:) ||
        selector == @selector(_notifyWithTitle:description:options:)) {
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
                options:(id)options
{
    if (title == nil || ![title isKindOfClass:[NSString class]]) {
        title = [title description];
    }
    if (description == nil || ![description isKindOfClass:[NSString class]]) {
        description = [description description];
    }
    
    if (options == nil || [options isEqual:[WebUndefined undefined]]) {
        [GrowlApplicationBridge notifyWithTitle:title
                                    description:description
                               notificationName:GSBNotification
                                       iconData:nil
                                       priority:0
                                       isSticky:NO
                                   clickContext:nil];
        return;
    }
    
    NSNumber *isSticky = [options valueForKey:@"isSticky"];
    NSNumber *priority = [options valueForKey:@"priority"];
    NSString *imageURL = [options valueForKey:@"imageUrl"];
    NSData *iconData = nil;
    
    if (isSticky == nil || ![isSticky isKindOfClass:[NSNumber class]]) {
        isSticky = [NSNumber numberWithBool:NO];
    }
    if (priority == nil || ![priority isKindOfClass:[NSNumber class]]) {
        priority = [NSNumber numberWithInt:0];
    }
    
    if (imageURL != nil && [imageURL isKindOfClass:[NSString class]]) {
        NSImage *image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:imageURL]];
        if (image != nil) {
            iconData = [image TIFFRepresentation];
            [image release];
        }
    }
    
    [GrowlApplicationBridge notifyWithTitle:title
                                description:description
                           notificationName:GSBNotification
                                   iconData:iconData
                                   priority:[priority intValue]
                                   isSticky:[isSticky boolValue]
                               clickContext:nil];
}

- (void)_notifyWithTitle:(NSString *)title
             description:(NSString *)description
                 options:(WebScriptObject *)options
{
    NSLog(@"GrowlSafariBridge: notifyWithOptions() is deprecated");
    [self notifyWithTitle:title
              description:description
                  options:options];
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

