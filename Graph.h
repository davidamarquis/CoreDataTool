//
//  Graph.h
//  CoreDataModeller
//
//  Created by David Marquis on 2015-05-28.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Edge, Vert;

@interface Graph : NSManagedObject

@property (nonatomic, retain) NSSet *edge;
@property (nonatomic, retain) NSSet *vert;
@end

@interface Graph (CoreDataGeneratedAccessors)

- (void)addEdgeObject:(Edge *)value;
- (void)removeEdgeObject:(Edge *)value;
- (void)addEdge:(NSSet *)values;
- (void)removeEdge:(NSSet *)values;

- (void)addVertObject:(Vert *)value;
- (void)removeVertObject:(Vert *)value;
- (void)addVert:(NSSet *)values;
- (void)removeVert:(NSSet *)values;

@end
