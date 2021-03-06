//
//  EEFacebookRequestDelegate.cpp
//  ee_x_mobile_facebook
//
//  Created by eps on 3/20/18.
//

#import "ee/facebook/internal/EEFacebookRequestDelegate.h"
#import "ee/core/internal/EEJsonUtils.h"
#import "ee/core/EEIMessageBridge.h"

@implementation EEFacebookRequestDelegate {
    int tag_;
    id<EEIMessageBridge> bridge_;
}

+ (instancetype)delegateWithBridge:(id<EEIMessageBridge>)bridge tag:(int)tag {
    EEFacebookRequestDelegate* delegate = [[[self alloc] init] autorelease];
    delegate->bridge_ = bridge;
    delegate->tag_ = tag;
    return delegate;
}

- (NSString* _Nonnull)k__onSuccess {
    return [@"FacebookRequestDelegate_onSuccess_"
        stringByAppendingString:[@(tag_) stringValue]];
}

- (NSString* _Nonnull)k__onFailure {
    return [@"FacebookRequestDelegate_onFailure_"
        stringByAppendingString:[@(tag_) stringValue]];
}

- (NSString* _Nonnull)k__onCancel {
    return [@"FacebookRequestDelegate_onCancel_"
        stringByAppendingString:[@(tag_) stringValue]];
}

- (void)gameRequestDialog:(FBSDKGameRequestDialog*)gameRequestDialog
    didCompleteWithResults:(NSDictionary*)results {
    [bridge_ callCpp:[self k__onSuccess]
             message:[EEJsonUtils convertDictionaryToString:results]];
    [self release];
}

- (void)gameRequestDialog:(FBSDKGameRequestDialog*)gameRequestDialog
         didFailWithError:(NSError*)error {
    [bridge_ callCpp:[self k__onFailure] message:[error localizedDescription]];
    [self release];
}

- (void)gameRequestDialogDidCancel:(FBSDKGameRequestDialog*)gameRequestDialog {
    [bridge_ callCpp:[self k__onCancel]];
    [self release];
}

@end
