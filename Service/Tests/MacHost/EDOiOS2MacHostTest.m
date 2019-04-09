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

#import <XCTest/XCTest.h>

#import "Service/Sources/EDOClientService.h"
#import "Service/Sources/EDOHostNamingService.h"
#import "Service/Tests/TestsBundle/EDOTestDummy.h"

/** The test of communication between iOS physical device and Mac host. */
@interface EDOiOS2MacHostTest : XCTestCase
@end

@implementation EDOiOS2MacHostTest

+ (void)setUp {
  [super setUp];
  [EDOHostNamingService.sharedService start];
}

/** Tests remote invocation from iOS device to Mac host. */
- (void)testDeviceCanMakeRemoteInvocationOnMacHost {
  // The remote object served by test service on Mac host.
  EDOTestDummy *testDummy = [EDOClientService rootObjectWithPort:0
                                                     serviceName:@"com.google.test.MacTestService"];
  XCTAssertEqual([testDummy returnInt], 100);
}

@end
