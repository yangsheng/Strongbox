//
//  ConcurrentMutableSet.m
//  Strongbox
//
//  Created by Strongbox on 02/05/2020.
//  Copyright © 2020 Mark McGuill. All rights reserved.
//

#import "ConcurrentMutableSet.h"

@interface ConcurrentMutableSet ()

@property (strong, nonatomic) NSMutableSet *data;
@property (strong, nonatomic) dispatch_queue_t dataQueue;

@end

@implementation ConcurrentMutableSet // Multiple Readers, Serialized Writes 

+ (instancetype)mutableSet {
    return [[ConcurrentMutableSet alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.data = NSMutableSet.set;
        self.dataQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)addObject:(id)object {
    dispatch_barrier_async(self.dataQueue, ^{ // Serialized Write with Barrier
        [self.data addObject:object];
    });
}

- (void)addObjectsFromArray:(NSArray*)array {
    dispatch_barrier_async(self.dataQueue, ^{  // Serialized Write with Barrier
        [self.data addObjectsFromArray:array];
    });
}

- (void)removeObject:(id)object {
    dispatch_barrier_async(self.dataQueue, ^{  // Serialized Write with Barrier
        [self.data removeObject:object];
    });
}

- (NSSet*)snapshot {
    __block NSSet *result;

    dispatch_sync(self.dataQueue, ^{ // Multiple concurrent readers fine no need for barrier
        result = self.data.copy;
    });
    
    return result;
}

- (NSArray*)arraySnapshot {
    __block NSArray *result;

    dispatch_sync(self.dataQueue, ^{ // Multiple concurrent readers fine no need for barrier
        result = self.data.allObjects.copy;
    });
    
    return result;
}

- (NSUInteger)count {
    __block NSUInteger result;

    dispatch_sync(self.dataQueue, ^{  // Multiple concurrent readers fine no need for barrier
        result = self.data.count;
    });
    
    return result;
}

- (id)anyObject {
    __block id result;

    dispatch_sync(self.dataQueue, ^{  // Multiple concurrent readers fine no need for barrier
        result = self.data.anyObject;
    });
    
    return result;
}

- (BOOL)containsObject:(id)object {
    __block BOOL result;

    dispatch_sync(self.dataQueue, ^{ // Multiple concurrent readers fine no need for barrier
        result = [self.data containsObject:object];
    });
    
    return result;
}

@end