//
//  EENotification.cpp
//  ee_core
//
//  Created by Zinge on 3/28/17.
//
//

#import "ee/notification/EENotification.h"
#import "ee/core/internal/EEDictionaryUtils.h"
#import "ee/core/internal/EEJsonUtils.h"
#import "ee/core/internal/EEMessageBridge.h"

#import <UIKit/UIKit.h>

@implementation EENotification

NSString* const k__notification_schedule = @"__notification_schedule";
NSString* const k__notification_unschedule = @"__notification_unschedule";
NSString* const k__notification_unschedule_all =
    @"__notification_unschedule_all";
NSString* const k__notification_clear_all = @"__notification_clear_all";

- (id)init {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    [self registerHandlers];
    [self registerForLocalNotifications];
    return self;
}

- (void)dealloc {
    [self deregisterHandlers];
    [super dealloc];
}

+ (NSCalendarUnit)parseInterval:(int)interval {
    if (interval == 0) {
        return 0;
    }
    if (interval <= 1) {
        return NSCalendarUnitSecond;
    }
    if (interval <= 60) {
        return NSCalendarUnitMinute;
    }
    if (interval <= 3600) {
        return NSCalendarUnitHour;
    }
    if (interval <= 86400) {
        return NSCalendarUnitDay;
    }
    return NSCalendarUnitEra;
}

- (void)registerHandlers {
    EEMessageBridge* bridge = [EEMessageBridge getInstance];

    [bridge registerHandler:^(NSString* msg) {
        NSDictionary* dict = [EEJsonUtils convertStringToDictionary:msg];
        NSString* title = [dict objectForKey:@"title"];
        NSString* body = [dict objectForKey:@"body"];
        NSNumber* delay = [dict objectForKey:@"delay"];
        NSNumber* interval = [dict objectForKey:@"interval"];
        NSNumber* tag = [dict objectForKey:@"tag"];

        [self schedule:title
                  body:body
                 delay:(NSTimeInterval)[delay intValue]
              interval:[EENotification parseInterval:[interval intValue]]
                   tag:tag];
        return [EEDictionaryUtils emptyResult];
    } tag:k__notification_schedule];

    [bridge registerHandler:^(NSString* msg) {
        [self unscheduleAll];
        return [EEDictionaryUtils emptyResult];
    } tag:k__notification_unschedule_all];

    [bridge registerHandler:^(NSString* msg) {
        NSDictionary* dict = [EEJsonUtils convertStringToDictionary:msg];
        NSNumber* tag = [dict objectForKey:@"tag"];

        [self unschedule:tag];
        return [EEDictionaryUtils emptyResult];
    } tag:k__notification_unschedule];

    [bridge registerHandler:^(NSString* msg) {
        [self clearAll];
        return [EEDictionaryUtils emptyResult];
    } tag:k__notification_clear_all];
}

- (void)deregisterHandlers {
    EEMessageBridge* bridge = [EEMessageBridge getInstance];

    [bridge deregisterHandler:k__notification_schedule];
    [bridge deregisterHandler:k__notification_unschedule_all];
    [bridge deregisterHandler:k__notification_unschedule];
}

- (void)registerForLocalNotifications {
    UIApplication* application = [UIApplication sharedApplication];
    if ([application
            respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType allNotificationTypes =
            (UIUserNotificationTypeSound | UIUserNotificationTypeAlert |
             UIUserNotificationTypeBadge);
        UIUserNotificationSettings* settings =
            [UIUserNotificationSettings settingsForTypes:allNotificationTypes
                                              categories:nil];
        [application registerUserNotificationSettings:settings];
    }
}

- (UILocalNotification*)create:(NSDate*)fireDate
                      interval:(NSCalendarUnit)interval
                         title:(NSString*)title
                          body:(NSString*)body {
    UILocalNotification* notification =
        [[[UILocalNotification alloc] init] autorelease];
    if (notification == nil) {
        return nil;
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.2) {
        [notification setAlertTitle:title];
    }

    [notification setFireDate:fireDate];
    [notification setRepeatInterval:interval];

    // http://stackoverflow.com/questions/5985468/iphone-differences-among-time-zone-convenience-methods?noredirect=1&lq=1
    [notification setTimeZone:[NSTimeZone localTimeZone]];

    [notification setSoundName:UILocalNotificationDefaultSoundName];
    [notification setAlertBody:body];
    return notification;
}

- (void)schedule:(NSString*)title
            body:(NSString*)body
           delay:(NSTimeInterval)delay
        interval:(NSCalendarUnit)interval
             tag:(NSNumber*)tag {
    UILocalNotification* notification =
        [self create:[NSDate dateWithTimeIntervalSinceNow:delay]
            interval:interval
               title:title
                body:body];
    if (notification == nil) {
        return;
    }

    NSDictionary* dict =
        [NSDictionary dictionaryWithObject:tag forKey:@"notification_tag"];
    [notification setUserInfo:dict];

    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (void)unschedule:(NSNumber*)tag {
    UIApplication* application = [UIApplication sharedApplication];
    NSArray* notifications = [application scheduledLocalNotifications];

    for (UILocalNotification* notification in notifications) {
        id notificationTag =
            [[notification userInfo] objectForKey:@"notification_tag"];
        if (notificationTag == nil) {
            continue;
        }
        if (![notificationTag isKindOfClass:[NSNumber class]]) {
            [application cancelLocalNotification:notification];
            continue;
        }
        if ([notificationTag isEqualToNumber:tag]) {
            [application cancelLocalNotification:notification];
        }
    }
}

- (void)unscheduleAll {
    UIApplication* application = [UIApplication sharedApplication];
    NSArray* notifications = [application scheduledLocalNotifications];

    if ([notifications count] > 0) {
        [application cancelAllLocalNotifications];
    }
}

- (void)clearAll {
    // http://stackoverflow.com/questions/8682051/ios-application-how-to-clear-notifications
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

@end