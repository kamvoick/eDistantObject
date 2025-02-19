//
// Copyright 2018 Google Inc.
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

#import "EDOHostService.h"
#import "EDOObject+Private.h"

NS_ASSUME_NONNULL_BEGIN

@class EDOExecutor;
@class EDOHostPort;
@class EDOObject;
@protocol EDOChannel;

/** The internal use for sending and receiving EDOObject. */
@interface EDOHostService (Private)
/** The underlying root object. */
@property(readonly) id rootLocalObject;
/** The executor to handle the request. */
@property(readonly) EDOExecutor *executor;

/** Gets the @c EDOHostService for the current running queue as an executing queue. */
+ (nullable instancetype)serviceForCurrentExecutingQueue;

/**
 * @return The temporary @c EDOHostService for the current thread.
 *
 * @note This is the fallback approach of fetching a host service when it's
 * infeasible to create the service using the current running queue. A temporary
 * host service is able to handle incoming remote calls while waiting for an
 * outgoing remote call. It is an error if an incoming remote call is sent to a
 * temporary service after the outgoing remote call has completed.
 */
+ (instancetype)temporaryServiceForCurrentThread;

/**
 * Wraps a distant object for the given local object and host port.
 *
 * @param object   The object to be wrapped as a remote object.
 * @param hostPort The port that the remote object connects to. If nil, the default host port from
 *                 the service will be used.
 * @return The remote object that proxies the given object.
 */
- (EDOObject *)distantObjectForLocalObject:(id)object hostPort:(nullable EDOHostPort *)hostPort;

/**
 * Checks if the underlying object for the given address is still alive.
 *
 * @param port          The port of the remote object.
 * @param remoteAddress The address of the remote object.
 * @return @c YES if the underlying object is still in the cache; @c NO otherwise.
 */
- (BOOL)isObjectAliveWithPort:(EDOServicePort *)port remoteAddress:(EDOPointerType)remoteAddress;

/**
 * Removes an EDOObject with the specified address in the host cache.
 *
 * @param remoteAddress The @c EDOPointerType containing the object address.
 * @return @c YES if an object was removed; @c NO otherwise.
 */
- (BOOL)removeObjectWithAddress:(EDOPointerType)remoteAddress;

/**
 * Removes a weak EDOObject with the specified address in the host cache for weak objects.
 *
 * @param remoteAddress The @c EDOPointerType containing the object address.
 * @return @c YES if an object was removed; @c NO otherwise.
 */
- (BOOL)removeWeakObjectWithAddress:(EDOPointerType)remoteAddress;

/**
 * Adds a weak EDOObject to the host cache for weak objects, so that it gets retained and will not
 * be released immediately.
 *
 * @param object The @c EDOObject containing the underlying object address.
 * @return @c YES if the weak EDOObject is owned by the weak object cache.
 */
- (BOOL)addWeakObject:(EDOObject *)object;

/**
 * Starts receiving requests and handling them from @c channel.
 *
 * This will properly handle all incoming requests for the given channel, which will be strongly
 * referenced in the method by an internal handler block until the channel or the host service is
 * invalidated.
 *
 * @param channel The channel to schedule receiving requests from clients.
 */
- (void)startReceivingRequestsForChannel:(id<EDOChannel>)channel;

@end

NS_ASSUME_NONNULL_END
