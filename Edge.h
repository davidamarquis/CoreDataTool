//
//  Edge.h
//  CoreDataModeller
//
//  Created by David Marquis on 2015-05-28.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Graph, Vert;

@interface Edge : NSManagedObject

@property (nonatomic, retain) NSNumber * edgeViewId;
@property (nonatomic, retain) NSString * parseObjectId;
@property (nonatomic, retain) Graph *graph;
@property (nonatomic, retain) NSSet *joinedTo;
@end

@interface Edge (CoreDataGeneratedAccessors)

- (void)addJoinedToObject:(Vert *)value;
- (void)removeJoinedToObject:(Vert *)value;
- (void)addJoinedTo:(NSSet *)values;
- (void)removeJoinedTo:(NSSet *)values;

@end
