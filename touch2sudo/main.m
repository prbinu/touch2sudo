//
//  main.m
//  touch2sudo
//
//  Created by Binu Ramakrishnan on 12/30/18.
//  Copyright (c) 2018 NVIDIA CORPORATION. All rights reserved.
//

#import <dispatch/dispatch.h>
#import <Foundation/Foundation.h>
#import <LocalAuthentication/LocalAuthentication.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        if ((argc == 2) && (strncmp(argv[1], "-h", strlen("-h")) == 0)) {
            printf("Usage: touch2sudo -reason <reason>\n");
            printf("  -reason  The app-provided reason for requesting authentication,\n");
            printf("           which displays in the authentication dialog presented to the user\n");
            printf("  -h       Help!\n");
            return 1;
        }
        NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
        NSString *reason = ([standardDefaults stringForKey:@"reason"] != NULL) ?
        [standardDefaults stringForKey:@"reason"]: @"perform an action that requires authentication";
        
        // SSH_ASKPASS format
        if (([standardDefaults stringForKey:@"reason"] == NULL) && (argc == 2)) {
            NSString *arg = [NSString stringWithUTF8String: argv[1]];
            NSArray *listItems = [arg componentsSeparatedByString:@"Key fingerprint "];
            if ((listItems.count == 2) && ([listItems[1] hasPrefix:@"SHA256:"])) {
                reason = [reason stringByAppendingString:@"\n\n"];
                reason = [reason stringByAppendingString:listItems[0]];
                reason = [reason stringByAppendingString:@"\n\nKey fingerprint: "];
                reason = [reason stringByAppendingString:listItems[1]];
            }
        }

        __block int result = 1;
        LAContext *context = [[LAContext alloc] init];
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [context evaluatePolicy: kLAPolicyDeviceOwnerAuthentication localizedReason: reason
                          reply:^(BOOL success, NSError * _Nullable error) {
                              if (success) {
                                  result = 0;
                              }
                              else {
                                  NSLog(@"%s\n", error.localizedDescription.UTF8String);
                                  result = 1;
                              }
                              
                              dispatch_semaphore_signal(semaphore);
                          }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        return result;
    }
}

