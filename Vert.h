//
//  Vert.h
//  CoreDataModeller
//
//  Created by David Marquis on 2015-05-28.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Edge, Graph, Vert;

@interface Vert : NSManagedObject

@property (nonatomic, retain) NSNumber * depthSearchSeenNum;
@property (nonatomic, retain) NSNumber * drawnNum;
@property (nonatomic, retain) NSNumber * finishedObservedMethod;
@property (nonatomic, retain) NSNumber * neighborsDrawnNum;
@property (nonatomic, retain) NSString * parseObjId;
@property (nonatomic, retain) NSNumber * vertViewId;
@property (nonatomic, retain) NSNumber * xNum;
@property (nonatomic, retain) NSNumber * yNum;
@property (nonatomic, retain) NSSet *edge;
@property (nonatomic, retain) Graph *graph;
@property (nonatomic, retain) NSSet *neighbor;
@end

@interface Vert (CoreDataGeneratedAccessors)

- (void)addEdgeObject:(Edge *)value;
- (void)removeEdgeObject:(Edge *)value;
- (void)addEdge:(NSSet *)values;
- (void)removeEdge:(NSSet *)values;

- (void)addNeighborObject:(Vert *)value;
- (void)removeNeighborObject:(Vert *)value;
- (void)addNeighbor:(NSSet *)values;
- (void)removeNeighbor:(NSSet *)values;

@end
