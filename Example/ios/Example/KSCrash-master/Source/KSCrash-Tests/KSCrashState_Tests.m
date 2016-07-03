//
//  KSCrashState_Tests.m
//
//  Created by Karl Stenerud on 2012-02-05.
//
//  Copyright (c) 2012 Karl Stenerud. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall remain in place
// in this source code.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//


#import "FileBasedTestCase.h"
#import "XCTestCase+KSCrash.h"

#import "KSCrashState.h"


@interface KSCrashState_Tests : FileBasedTestCase@end


@implementation KSCrashState_Tests

- (void) testInitRelaunch
{
    KSCrash_State context = {0};
    NSString* stateFile = [self.tempPath stringByAppendingPathComponent:@"state.json"];

    kscrashstate_init([stateFile cStringUsingEncoding:NSUTF8StringEncoding],
                      &context);

    XCTAssertTrue(context.applicationIsInForeground, @"");
    XCTAssertFalse(context.applicationIsActive, @"");

    XCTAssertEqual(context.activeDurationSinceLastCrash, 0.0, @"");
    XCTAssertEqual(context.backgroundDurationSinceLastCrash, 0.0, @"");
    XCTAssertEqual(context.launchesSinceLastCrash, 1, @"");
    XCTAssertEqual(context.sessionsSinceLastCrash, 1, @"");

    XCTAssertEqual(context.activeDurationSinceLaunch, 0.0, @"");
    XCTAssertEqual(context.backgroundDurationSinceLaunch, 0.0, @"");
    XCTAssertEqual(context.sessionsSinceLaunch, 1, @"");

    XCTAssertFalse(context.crashedThisLaunch, @"");
    XCTAssertFalse(context.crashedLastLaunch, @"");

    memset(&context, 0, sizeof(context));
    kscrashstate_init([stateFile cStringUsingEncoding:NSUTF8StringEncoding],
                      &context);

    XCTAssertTrue(context.applicationIsInForeground, @"");
    XCTAssertFalse(context.applicationIsActive, @"");

    XCTAssertEqual(context.activeDurationSinceLastCrash, 0.0, @"");
    XCTAssertEqual(context.backgroundDurationSinceLastCrash, 0.0, @"");
    XCTAssertEqual(context.launchesSinceLastCrash, 2, @"");
    XCTAssertEqual(context.sessionsSinceLastCrash, 2, @"");

    XCTAssertEqual(context.activeDurationSinceLaunch, 0.0, @"");
    XCTAssertEqual(context.backgroundDurationSinceLaunch, 0.0, @"");
    XCTAssertEqual(context.sessionsSinceLaunch, 1, @"");

    XCTAssertFalse(context.crashedThisLaunch, @"");
    XCTAssertFalse(context.crashedLastLaunch, @"");
}

- (void) testInitCrash
{
    KSCrash_State context = {0};
    NSString* stateFile = [self.tempPath stringByAppendingPathComponent:@"state.json"];

    kscrashstate_init([stateFile cStringUsingEncoding:NSUTF8StringEncoding],
                      &context);
    KSCrash_State checkpoint0 = context;

    usleep(1);
    kscrashstate_notifyAppCrash();
    KSCrash_State checkpointC = context;

    XCTAssertTrue(checkpointC.applicationIsInForeground ==
                 checkpoint0.applicationIsInForeground, @"");
    XCTAssertTrue(checkpointC.applicationIsActive ==
                 checkpoint0.applicationIsActive, @"");

    XCTAssertTrue(checkpointC.activeDurationSinceLastCrash ==
                 checkpoint0.activeDurationSinceLastCrash, @"");
    XCTAssertTrue(checkpointC.backgroundDurationSinceLastCrash ==
                 checkpoint0.backgroundDurationSinceLastCrash, @"");
    XCTAssertTrue(checkpointC.launchesSinceLastCrash ==
                 checkpoint0.launchesSinceLastCrash, @"");
    XCTAssertTrue(checkpointC.sessionsSinceLastCrash ==
                 checkpoint0.sessionsSinceLastCrash, @"");

    XCTAssertTrue(checkpointC.activeDurationSinceLaunch ==
                 checkpoint0.activeDurationSinceLaunch, @"");
    XCTAssertTrue(checkpointC.backgroundDurationSinceLaunch ==
                 checkpoint0.backgroundDurationSinceLaunch, @"");
    XCTAssertTrue(checkpointC.sessionsSinceLaunch ==
                 checkpoint0.sessionsSinceLaunch, @"");

    XCTAssertTrue(checkpointC.crashedThisLaunch, @"");
    XCTAssertFalse(checkpointC.crashedLastLaunch, @"");

    memset(&context, 0, sizeof(context));
    kscrashstate_init([stateFile cStringUsingEncoding:NSUTF8StringEncoding],
                      &context);

    XCTAssertTrue(context.applicationIsInForeground, @"");
    XCTAssertFalse(context.applicationIsActive, @"");

    XCTAssertEqual(context.activeDurationSinceLastCrash, 0.0, @"");
    XCTAssertEqual(context.backgroundDurationSinceLastCrash, 0.0, @"");
    XCTAssertEqual(context.launchesSinceLastCrash, 1, @"");
    XCTAssertEqual(context.sessionsSinceLastCrash, 1, @"");

    XCTAssertEqual(context.activeDurationSinceLaunch, 0.0, @"");
    XCTAssertEqual(context.backgroundDurationSinceLaunch, 0.0, @"");
    XCTAssertEqual(context.sessionsSinceLaunch, 1, @"");

    XCTAssertFalse(context.crashedThisLaunch, @"");
    XCTAssertTrue(context.crashedLastLaunch, @"");
}

- (void) testActRelaunch
{
    KSCrash_State context = {0};
    NSString* stateFile = [self.tempPath stringByAppendingPathComponent:@"state.json"];

    kscrashstate_init([stateFile cStringUsingEncoding:NSUTF8StringEncoding],
                      &context);
    KSCrash_State checkpoint0 = context;

    usleep(1);
    kscrashstate_notifyAppActive(true);
    KSCrash_State checkpoint1 = context;

    XCTAssertTrue(checkpoint1.applicationIsInForeground ==
                 checkpoint0.applicationIsInForeground, @"");
    XCTAssertTrue(checkpoint1.applicationIsActive !=
                 checkpoint0.applicationIsActive, @"");
    XCTAssertTrue(checkpoint1.applicationIsActive, @"");

    XCTAssertTrue(checkpoint1.activeDurationSinceLastCrash ==
                 checkpoint0.activeDurationSinceLastCrash, @"");
    XCTAssertTrue(checkpoint1.backgroundDurationSinceLastCrash ==
                 checkpoint0.backgroundDurationSinceLastCrash, @"");
    XCTAssertTrue(checkpoint1.launchesSinceLastCrash ==
                 checkpoint0.launchesSinceLastCrash, @"");
    XCTAssertTrue(checkpoint1.sessionsSinceLastCrash ==
                 checkpoint0.sessionsSinceLastCrash, @"");

    XCTAssertTrue(checkpoint1.activeDurationSinceLaunch ==
                 checkpoint0.activeDurationSinceLaunch, @"");
    XCTAssertTrue(checkpoint1.backgroundDurationSinceLaunch ==
                 checkpoint0.backgroundDurationSinceLaunch, @"");
    XCTAssertTrue(checkpoint1.sessionsSinceLaunch ==
                 checkpoint0.sessionsSinceLaunch, @"");

    XCTAssertFalse(checkpoint1.crashedThisLaunch, @"");
    XCTAssertFalse(checkpoint1.crashedLastLaunch, @"");

    usleep(1);
    memset(&context, 0, sizeof(context));
    kscrashstate_init([stateFile cStringUsingEncoding:NSUTF8StringEncoding],
                      &context);

    XCTAssertTrue(context.applicationIsInForeground, @"");
    XCTAssertFalse(context.applicationIsActive, @"");

    XCTAssertEqual(context.activeDurationSinceLastCrash, 0.0, @"");
    XCTAssertEqual(context.backgroundDurationSinceLastCrash, 0.0, @"");
    XCTAssertEqual(context.launchesSinceLastCrash, 2, @"");
    XCTAssertEqual(context.sessionsSinceLastCrash, 2, @"");

    XCTAssertEqual(context.activeDurationSinceLaunch, 0.0, @"");
    XCTAssertEqual(context.backgroundDurationSinceLaunch, 0.0, @"");
    XCTAssertEqual(context.sessionsSinceLaunch, 1, @"");

    XCTAssertFalse(context.crashedThisLaunch, @"");
    XCTAssertFalse(context.crashedLastLaunch, @"");
}

- (void) testActCrash
{
    KSCrash_State context = {0};
    NSString* stateFile = [self.tempPath stringByAppendingPathComponent:@"state.json"];

    kscrashstate_init([stateFile cStringUsingEncoding:NSUTF8StringEncoding],
                      &context);
    usleep(1);
    kscrashstate_notifyAppActive(true);
    KSCrash_State checkpoint0 = context;

    usleep(1);
    kscrashstate_notifyAppCrash();
    KSCrash_State checkpointC = context;

    XCTAssertTrue(checkpointC.applicationIsInForeground ==
                 checkpoint0.applicationIsInForeground, @"");
    XCTAssertTrue(checkpointC.applicationIsActive ==
                 checkpoint0.applicationIsActive, @"");

    XCTAssertTrue(checkpointC.activeDurationSinceLastCrash >
                 checkpoint0.activeDurationSinceLastCrash, @"");
    XCTAssertTrue(checkpointC.backgroundDurationSinceLastCrash ==
                 checkpoint0.backgroundDurationSinceLastCrash, @"");
    XCTAssertTrue(checkpointC.launchesSinceLastCrash ==
                 checkpoint0.launchesSinceLastCrash, @"");
    XCTAssertTrue(checkpointC.sessionsSinceLastCrash ==
                 checkpoint0.sessionsSinceLastCrash, @"");

    XCTAssertTrue(checkpointC.activeDurationSinceLaunch >
                 checkpoint0.activeDurationSinceLaunch, @"");
    XCTAssertTrue(checkpointC.backgroundDurationSinceLaunch ==
                 checkpoint0.backgroundDurationSinceLaunch, @"");
    XCTAssertTrue(checkpointC.sessionsSinceLaunch ==
                 checkpoint0.sessionsSinceLaunch, @"");

    XCTAssertTrue(checkpointC.crashedThisLaunch, @"");
    XCTAssertFalse(checkpointC.crashedLastLaunch, @"");

    memset(&context, 0, sizeof(context));
    kscrashstate_init([stateFile cStringUsingEncoding:NSUTF8StringEncoding],
                      &context);

    XCTAssertTrue(context.applicationIsInForeground, @"");
    XCTAssertFalse(context.applicationIsActive, @"");

    XCTAssertEqual(context.activeDurationSinceLastCrash, 0.0, @"");
    XCTAssertEqual(context.backgroundDurationSinceLastCrash, 0.0, @"");
    XCTAssertEqual(context.launchesSinceLastCrash, 1, @"");
    XCTAssertEqual(context.sessionsSinceLastCrash, 1, @"");

    XCTAssertEqual(context.activeDurationSinceLaunch, 0.0, @"");
    XCTAssertEqual(context.backgroundDurationSinceLaunch, 0.0, @"");
    XCTAssertEqual(context.sessionsSinceLaunch, 1, @"");

    XCTAssertFalse(context.crashedThisLaunch, @"");
    XCTAssertTrue(context.crashedLastLaunch, @"");
}

- (void) testActDeactRelaunch
{
    KSCrash_State context = {0};
    NSString* stateFile = [self.tempPath stringByAppendingPathComponent:@"state.json"];

    kscrashstate_init([stateFile cStringUsingEncoding:NSUTF8StringEncoding],
                      &context);
    usleep(1);
    kscrashstate_notifyAppActive(true);
    KSCrash_State checkpoint0 = context;

    usleep(1);
    kscrashstate_notifyAppActive(false);
    KSCrash_State checkpoint1 = context;

    XCTAssertTrue(checkpoint1.applicationIsInForeground ==
                 checkpoint0.applicationIsInForeground, @"");
    XCTAssertTrue(checkpoint1.applicationIsActive !=
                 checkpoint0.applicationIsActive, @"");
    XCTAssertFalse(checkpoint1.applicationIsActive, @"");

    XCTAssertTrue(checkpoint1.activeDurationSinceLastCrash >
                 checkpoint0.activeDurationSinceLastCrash, @"");
    XCTAssertTrue(checkpoint1.backgroundDurationSinceLastCrash ==
                 checkpoint0.backgroundDurationSinceLastCrash, @"");
    XCTAssertTrue(checkpoint1.launchesSinceLastCrash ==
                 checkpoint0.launchesSinceLastCrash, @"");
    XCTAssertTrue(checkpoint1.sessionsSinceLastCrash ==
                 checkpoint0.sessionsSinceLastCrash, @"");

    XCTAssertTrue(checkpoint1.activeDurationSinceLaunch >
                 checkpoint0.activeDurationSinceLaunch, @"");
    XCTAssertTrue(checkpoint1.backgroundDurationSinceLaunch ==
                 checkpoint0.backgroundDurationSinceLaunch, @"");
    XCTAssertTrue(checkpoint1.sessionsSinceLaunch ==
                 checkpoint0.sessionsSinceLaunch, @"");

    XCTAssertFalse(checkpoint1.crashedThisLaunch, @"");
    XCTAssertFalse(checkpoint1.crashedLastLaunch, @"");

    usleep(1);
    memset(&context, 0, sizeof(context));
    kscrashstate_init([stateFile cStringUsingEncoding:NSUTF8StringEncoding],
                      &context);
    KSCrash_State checkpointR = context;

    XCTAssertTrue(checkpointR.applicationIsInForeground, @"");
    XCTAssertFalse(checkpointR.applicationIsActive, @"");

    // We don't save after going inactive, so this will still be 0.
    XCTAssertEqual(checkpointR.activeDurationSinceLastCrash, 0.0, @"");
    XCTAssertEqual(checkpointR.backgroundDurationSinceLastCrash, 0.0, @"");
    XCTAssertEqual(checkpointR.launchesSinceLastCrash, 2, @"");
    XCTAssertEqual(checkpointR.sessionsSinceLastCrash, 2, @"");

    XCTAssertEqual(checkpointR.activeDurationSinceLaunch, 0.0, @"");
    XCTAssertEqual(checkpointR.backgroundDurationSinceLaunch, 0.0, @"");
    XCTAssertEqual(checkpointR.sessionsSinceLaunch, 1, @"");

    XCTAssertFalse(checkpointR.crashedThisLaunch, @"");
    XCTAssertFalse(checkpointR.crashedLastLaunch, @"");
}

- (void) testActDeactCrash
{
    KSCrash_State context = {0};
    NSString* stateFile = [self.tempPath stringByAppendingPathComponent:@"state.json"];

    kscrashstate_init([stateFile cStringUsingEncoding:NSUTF8StringEncoding],
                      &context);
    usleep(1);
    kscrashstate_notifyAppActive(true);
    usleep(1);
    kscrashstate_notifyAppActive(false);
    KSCrash_State checkpoint0 = context;

    usleep(1);
    kscrashstate_notifyAppCrash();
    KSCrash_State checkpointC = context;

    XCTAssertTrue(checkpointC.applicationIsInForeground ==
                 checkpoint0.applicationIsInForeground, @"");
    XCTAssertTrue(checkpointC.applicationIsActive ==
                 checkpoint0.applicationIsActive, @"");

    XCTAssertTrue(checkpointC.activeDurationSinceLastCrash ==
                 checkpoint0.activeDurationSinceLastCrash, @"");
    XCTAssertTrue(checkpointC.backgroundDurationSinceLastCrash ==
                 checkpoint0.backgroundDurationSinceLastCrash, @"");
    XCTAssertTrue(checkpointC.launchesSinceLastCrash ==
                 checkpoint0.launchesSinceLastCrash, @"");
    XCTAssertTrue(checkpointC.sessionsSinceLastCrash ==
                 checkpoint0.sessionsSinceLastCrash, @"");

    XCTAssertTrue(checkpointC.activeDurationSinceLaunch ==
                 checkpoint0.activeDurationSinceLaunch, @"");
    XCTAssertTrue(checkpointC.backgroundDurationSinceLaunch ==
                 checkpoint0.backgroundDurationSinceLaunch, @"");
    XCTAssertTrue(checkpointC.sessionsSinceLaunch ==
                 checkpoint0.sessionsSinceLaunch, @"");

    XCTAssertTrue(checkpointC.crashedThisLaunch, @"");
    XCTAssertFalse(checkpointC.crashedLastLaunch, @"");

    memset(&context, 0, sizeof(context));
    kscrashstate_init([stateFile cStringUsingEncoding:NSUTF8StringEncoding],
                      &context);

    XCTAssertTrue(context.applicationIsInForeground, @"");
    XCTAssertFalse(context.applicationIsActive, @"");

    XCTAssertEqual(context.activeDurationSinceLastCrash, 0.0, @"");
    XCTAssertEqual(context.backgroundDurationSinceLastCrash, 0.0, @"");
    XCTAssertEqual(context.launchesSinceLastCrash, 1, @"");
    XCTAssertEqual(context.sessionsSinceLastCrash, 1, @"");

    XCTAssertEqual(context.activeDurationSinceLaunch, 0.0, @"");
    XCTAssertEqual(context.backgroundDurationSinceLaunch, 0.0, @"");
    XCTAssertEqual(context.sessionsSinceLaunch, 1, @"");

    XCTAssertFalse(context.crashedThisLaunch, @"");
    XCTAssertTrue(context.crashedLastLaunch, @"");
}

- (void) testActDeactBGRelaunch
{
    KSCrash_State context = {0};
    NSString* stateFile = [self.tempPath stringByAppendingPathComponent:@"state.json"];

    kscrashstate_init([stateFile cStringUsingEncoding:NSUTF8StringEncoding],
                      &context);
    usleep(1);
    kscrashstate_notifyAppActive(true);
    usleep(1);
    kscrashstate_notifyAppActive(false);
    KSCrash_State checkpoint0 = context;

    usleep(1);
    kscrashstate_notifyAppInForeground(false);
    KSCrash_State checkpoint1 = context;

    XCTAssertTrue(checkpoint1.applicationIsInForeground !=
                 checkpoint0.applicationIsInForeground, @"");
    XCTAssertTrue(checkpoint1.applicationIsActive ==
                 checkpoint0.applicationIsActive, @"");
    XCTAssertFalse(checkpoint1.applicationIsInForeground, @"");

    XCTAssertTrue(checkpoint1.activeDurationSinceLastCrash ==
                 checkpoint0.activeDurationSinceLastCrash, @"");
    XCTAssertTrue(checkpoint1.backgroundDurationSinceLastCrash ==
                 checkpoint0.backgroundDurationSinceLastCrash, @"");
    XCTAssertTrue(checkpoint1.launchesSinceLastCrash ==
                 checkpoint0.launchesSinceLastCrash, @"");
    XCTAssertTrue(checkpoint1.sessionsSinceLastCrash ==
                 checkpoint0.sessionsSinceLastCrash, @"");

    XCTAssertTrue(checkpoint1.activeDurationSinceLaunch ==
                 checkpoint0.activeDurationSinceLaunch, @"");
    XCTAssertTrue(checkpoint1.backgroundDurationSinceLaunch ==
                 checkpoint0.backgroundDurationSinceLaunch, @"");
    XCTAssertTrue(checkpoint1.sessionsSinceLaunch ==
                 checkpoint0.sessionsSinceLaunch, @"");

    XCTAssertFalse(checkpoint1.crashedThisLaunch, @"");
    XCTAssertFalse(checkpoint1.crashedLastLaunch, @"");

    usleep(1);
    memset(&context, 0, sizeof(context));
    kscrashstate_init([stateFile cStringUsingEncoding:NSUTF8StringEncoding],
                      &context);
    KSCrash_State checkpointR = context;

    XCTAssertTrue(checkpointR.applicationIsInForeground, @"");
    XCTAssertFalse(checkpointR.applicationIsActive, @"");

    XCTAssertTrue(checkpointR.activeDurationSinceLastCrash > 0, @"");
    XCTAssertEqual(checkpointR.backgroundDurationSinceLastCrash, 0.0, @"");
    XCTAssertEqual(checkpointR.launchesSinceLastCrash, 2, @"");
    XCTAssertEqual(checkpointR.sessionsSinceLastCrash, 2, @"");

    XCTAssertEqual(checkpointR.activeDurationSinceLaunch, 0.0, @"");
    XCTAssertEqual(checkpointR.backgroundDurationSinceLaunch, 0.0, @"");
    XCTAssertEqual(checkpointR.sessionsSinceLaunch, 1, @"");

    XCTAssertFalse(checkpointR.crashedThisLaunch, @"");
    XCTAssertFalse(checkpointR.crashedLastLaunch, @"");
}

- (void) testActDeactBGTerminate
{
    KSCrash_State context = {0};
    NSString* stateFile = [self.tempPath stringByAppendingPathComponent:@"state.json"];

    kscrashstate_init([stateFile cStringUsingEncoding:NSUTF8StringEncoding],
                      &context);
    usleep(1);
    kscrashstate_notifyAppActive(true);
    usleep(1);
    kscrashstate_notifyAppActive(false);
    usleep(1);
    kscrashstate_notifyAppInForeground(false);
    KSCrash_State checkpoint0 = context;
    usleep(1);
    kscrashstate_notifyAppTerminate();

    usleep(1);
    memset(&context, 0, sizeof(context));
    kscrashstate_init([stateFile cStringUsingEncoding:NSUTF8StringEncoding],
                      &context);
    KSCrash_State checkpointR = context;

    XCTAssertTrue(checkpointR.applicationIsInForeground, @"");
    XCTAssertFalse(checkpointR.applicationIsActive, @"");

    XCTAssertTrue(checkpointR.backgroundDurationSinceLastCrash >
                 checkpoint0.backgroundDurationSinceLastCrash, @"");
    XCTAssertEqual(checkpointR.launchesSinceLastCrash, 2, @"");
    XCTAssertEqual(checkpointR.sessionsSinceLastCrash, 2, @"");

    XCTAssertEqual(checkpointR.activeDurationSinceLaunch, 0.0, @"");
    XCTAssertEqual(checkpointR.backgroundDurationSinceLaunch, 0.0, @"");
    XCTAssertEqual(checkpointR.sessionsSinceLaunch, 1, @"");

    XCTAssertFalse(checkpointR.crashedThisLaunch, @"");
    XCTAssertFalse(checkpointR.crashedLastLaunch, @"");
}

- (void) testActDeactBGCrash
{
    KSCrash_State context = {0};
    NSString* stateFile = [self.tempPath stringByAppendingPathComponent:@"state.json"];

    kscrashstate_init([stateFile cStringUsingEncoding:NSUTF8StringEncoding],
                      &context);
    usleep(1);
    kscrashstate_notifyAppActive(true);
    usleep(1);
    kscrashstate_notifyAppActive(false);
    usleep(1);
    kscrashstate_notifyAppInForeground(false);
    KSCrash_State checkpoint0 = context;

    usleep(1);
    kscrashstate_notifyAppCrash();
    KSCrash_State checkpointC = context;

    XCTAssertTrue(checkpointC.applicationIsInForeground ==
                 checkpoint0.applicationIsInForeground, @"");
    XCTAssertTrue(checkpointC.applicationIsActive ==
                 checkpoint0.applicationIsActive, @"");

    XCTAssertTrue(checkpointC.activeDurationSinceLastCrash ==
                 checkpoint0.activeDurationSinceLastCrash, @"");
    XCTAssertTrue(checkpointC.backgroundDurationSinceLastCrash >
                 checkpoint0.backgroundDurationSinceLastCrash, @"");
    XCTAssertTrue(checkpointC.launchesSinceLastCrash ==
                 checkpoint0.launchesSinceLastCrash, @"");
    XCTAssertTrue(checkpointC.sessionsSinceLastCrash ==
                 checkpoint0.sessionsSinceLastCrash, @"");

    XCTAssertTrue(checkpointC.activeDurationSinceLaunch ==
                 checkpoint0.activeDurationSinceLaunch, @"");
    XCTAssertTrue(checkpointC.backgroundDurationSinceLaunch >
                 checkpoint0.backgroundDurationSinceLaunch, @"");
    XCTAssertTrue(checkpointC.sessionsSinceLaunch ==
                 checkpoint0.sessionsSinceLaunch, @"");

    XCTAssertTrue(checkpointC.crashedThisLaunch, @"");
    XCTAssertFalse(checkpointC.crashedLastLaunch, @"");

    memset(&context, 0, sizeof(context));
    kscrashstate_init([stateFile cStringUsingEncoding:NSUTF8StringEncoding],
                      &context);

    XCTAssertTrue(context.applicationIsInForeground, @"");
    XCTAssertFalse(context.applicationIsActive, @"");

    XCTAssertEqual(context.activeDurationSinceLastCrash, 0.0, @"");
    XCTAssertEqual(context.backgroundDurationSinceLastCrash, 0.0, @"");
    XCTAssertEqual(context.launchesSinceLastCrash, 1, @"");
    XCTAssertEqual(context.sessionsSinceLastCrash, 1, @"");

    XCTAssertEqual(context.activeDurationSinceLaunch, 0.0, @"");
    XCTAssertEqual(context.backgroundDurationSinceLaunch, 0.0, @"");
    XCTAssertEqual(context.sessionsSinceLaunch, 1, @"");

    XCTAssertFalse(context.crashedThisLaunch, @"");
    XCTAssertTrue(context.crashedLastLaunch, @"");
}

- (void) testActDeactBGFGRelaunch
{
    KSCrash_State context = {0};
    NSString* stateFile = [self.tempPath stringByAppendingPathComponent:@"state.json"];

    kscrashstate_init([stateFile cStringUsingEncoding:NSUTF8StringEncoding],
                      &context);
    usleep(1);
    kscrashstate_notifyAppActive(true);
    usleep(1);
    kscrashstate_notifyAppActive(false);
    usleep(1);
    kscrashstate_notifyAppInForeground(false);
    usleep(1);
    KSCrash_State checkpoint0 = context;

    usleep(1);
    kscrashstate_notifyAppInForeground(true);
    KSCrash_State checkpoint1 = context;

    XCTAssertTrue(checkpoint1.applicationIsInForeground !=
                 checkpoint0.applicationIsInForeground, @"");
    XCTAssertTrue(checkpoint1.applicationIsActive ==
                 checkpoint0.applicationIsActive, @"");
    XCTAssertTrue(checkpoint1.applicationIsInForeground, @"");

    XCTAssertTrue(checkpoint1.activeDurationSinceLastCrash ==
                 checkpoint0.activeDurationSinceLastCrash, @"");
    XCTAssertTrue(checkpoint1.backgroundDurationSinceLastCrash >
                 checkpoint0.backgroundDurationSinceLastCrash, @"");
    XCTAssertTrue(checkpoint1.launchesSinceLastCrash ==
                 checkpoint0.launchesSinceLastCrash, @"");
    XCTAssertTrue(checkpoint1.sessionsSinceLastCrash ==
                 checkpoint0.sessionsSinceLastCrash + 1, @"");

    XCTAssertTrue(checkpoint1.activeDurationSinceLaunch ==
                 checkpoint0.activeDurationSinceLaunch, @"");
    XCTAssertTrue(checkpoint1.backgroundDurationSinceLaunch >
                 checkpoint0.backgroundDurationSinceLaunch, @"");
    XCTAssertTrue(checkpoint1.sessionsSinceLaunch ==
                 checkpoint0.sessionsSinceLaunch + 1, @"");

    XCTAssertFalse(checkpoint1.crashedThisLaunch, @"");
    XCTAssertFalse(checkpoint1.crashedLastLaunch, @"");

    usleep(1);
    memset(&context, 0, sizeof(context));
    kscrashstate_init([stateFile cStringUsingEncoding:NSUTF8StringEncoding],
                      &context);
    KSCrash_State checkpointR = context;

    XCTAssertTrue(checkpointR.applicationIsInForeground, @"");
    XCTAssertFalse(checkpointR.applicationIsActive, @"");

    XCTAssertTrue(checkpointR.activeDurationSinceLastCrash > 0, @"");
    // We don't save after going to FG, so this will still be 0.
    XCTAssertEqual(checkpointR.backgroundDurationSinceLastCrash, 0.0, @"");
    XCTAssertEqual(checkpointR.launchesSinceLastCrash, 2, @"");
    XCTAssertEqual(checkpointR.sessionsSinceLastCrash, 2, @"");

    XCTAssertEqual(checkpointR.activeDurationSinceLaunch, 0.0, @"");
    XCTAssertEqual(checkpointR.backgroundDurationSinceLaunch, 0.0, @"");
    XCTAssertEqual(checkpointR.sessionsSinceLaunch, 1, @"");

    XCTAssertFalse(checkpointR.crashedThisLaunch, @"");
    XCTAssertFalse(checkpointR.crashedLastLaunch, @"");
}

- (void) testActDeactBGFGCrash
{
    KSCrash_State context = {0};
    NSString* stateFile = [self.tempPath stringByAppendingPathComponent:@"state.json"];

    kscrashstate_init([stateFile cStringUsingEncoding:NSUTF8StringEncoding],
                      &context);
    usleep(1);
    kscrashstate_notifyAppActive(true);
    usleep(1);
    kscrashstate_notifyAppActive(false);
    usleep(1);
    kscrashstate_notifyAppInForeground(false);
    usleep(1);
    kscrashstate_notifyAppInForeground(true);
    KSCrash_State checkpoint0 = context;

    usleep(1);
    kscrashstate_notifyAppCrash();
    KSCrash_State checkpointC = context;

    XCTAssertTrue(checkpointC.applicationIsInForeground ==
                 checkpoint0.applicationIsInForeground, @"");
    XCTAssertTrue(checkpointC.applicationIsActive ==
                 checkpoint0.applicationIsActive, @"");

    XCTAssertTrue(checkpointC.activeDurationSinceLastCrash ==
                 checkpoint0.activeDurationSinceLastCrash, @"");
    XCTAssertTrue(checkpointC.backgroundDurationSinceLastCrash ==
                 checkpoint0.backgroundDurationSinceLastCrash, @"");
    XCTAssertTrue(checkpointC.launchesSinceLastCrash ==
                 checkpoint0.launchesSinceLastCrash, @"");
    XCTAssertTrue(checkpointC.sessionsSinceLastCrash ==
                 checkpoint0.sessionsSinceLastCrash, @"");

    XCTAssertTrue(checkpointC.activeDurationSinceLaunch ==
                 checkpoint0.activeDurationSinceLaunch, @"");
    XCTAssertTrue(checkpointC.backgroundDurationSinceLaunch ==
                 checkpoint0.backgroundDurationSinceLaunch, @"");
    XCTAssertTrue(checkpointC.sessionsSinceLaunch ==
                 checkpoint0.sessionsSinceLaunch, @"");

    XCTAssertTrue(checkpointC.crashedThisLaunch, @"");
    XCTAssertFalse(checkpointC.crashedLastLaunch, @"");

    memset(&context, 0, sizeof(context));
    kscrashstate_init([stateFile cStringUsingEncoding:NSUTF8StringEncoding],
                      &context);

    XCTAssertTrue(context.applicationIsInForeground, @"");
    XCTAssertFalse(context.applicationIsActive, @"");

    XCTAssertEqual(context.activeDurationSinceLastCrash, 0.0, @"");
    XCTAssertEqual(context.backgroundDurationSinceLastCrash, 0.0, @"");
    XCTAssertEqual(context.launchesSinceLastCrash, 1, @"");
    XCTAssertEqual(context.sessionsSinceLastCrash, 1, @"");

    XCTAssertEqual(context.activeDurationSinceLaunch, 0.0, @"");
    XCTAssertEqual(context.backgroundDurationSinceLaunch, 0.0, @"");
    XCTAssertEqual(context.sessionsSinceLaunch, 1, @"");

    XCTAssertFalse(context.crashedThisLaunch, @"");
    XCTAssertTrue(context.crashedLastLaunch, @"");
}

@end
