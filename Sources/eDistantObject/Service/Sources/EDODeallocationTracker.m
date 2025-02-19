//
// Copyright 2019 Google LLC.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "EDODeallocationTracker.h"

#include <objc/runtime.h>

#import "EDOClientService+Private.h"
#import "EDOClientService.h"
#import "EDOObject+Private.h"
#import "EDOObjectReleaseMessage.h"
#import "EDOWeakObject.h"

@interface EDODeallocationTracker ()

/** The tracked object address (EDOWeakObject) that is stored in the weak object dictionary. */
@property(readonly, nonatomic) EDOPointerType remoteObjectAddress;
/** The host port where weak object dictionary holds the remote object. */
@property(readonly, nonatomic) EDOHostPort *hostPort;
@end

@implementation EDODeallocationTracker

+ (void)enableTrackingForObject:(EDOWeakObject *)trackedObject hostPort:(EDOHostPort *)hostPort {
  if (!objc_getAssociatedObject(trackedObject.weakObject, &_cmd)) {
    EDODeallocationTracker *tracker = [[self alloc] initWithTrackedObject:trackedObject
                                                                 hostPort:hostPort];
    objc_setAssociatedObject(trackedObject.weakObject, &_cmd, tracker, OBJC_ASSOCIATION_RETAIN);
  }
}

- (instancetype)initWithTrackedObject:(EDOWeakObject *)trackedObject
                             hostPort:(EDOHostPort *)hostPort {
  self = [super init];
  if (self) {
    _remoteObjectAddress = (EDOPointerType)trackedObject;
    _hostPort = hostPort;
  }
  return self;
}

- (void)dealloc {
  @try {
    EDOObjectReleaseRequest *request =
        [EDOObjectReleaseRequest requestWithWeakRemoteAddress:self.remoteObjectAddress];
    [EDOClientService sendSynchronousRequest:request onPort:self.hostPort];
  } @catch (NSException *e) {
    // Safely ignore the exception because we don't care about the errors when we send the release
    // message. The service could be terminated, or the message can't be processed, but either way,
    // those can be ignored.
  }
}

@end
