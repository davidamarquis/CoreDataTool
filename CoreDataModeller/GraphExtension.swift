//
//  GraphExtension.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-02.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import CoreData
import Foundation

extension Graph {
// all methods in an extension

    func SetupVert(vertOrNil:Vert?, AtX xPos:Float, AtY yPos:Float) {
        // Warning: setting of ids should be guarded against the deletion of managed verts from but is not currently
      
        if let vert=vertOrNil {
            // add to set within graph
            verts=verts.setByAddingObject(vert);
            // set the id property
            let vertId:Int32=Int32(self.verts.count-1);
            vert.vertViewId=vertId;
            // 
            vert.moveVertTo(xPos, yPos);
        }
        else {
            println("Graph cat: SetupVert: err ");
        }
    }

    func SetupEdge(edgeOrNil:Edge?, From vertOrNil1:Vert?, To vertOrNil2:Vert?) {
        if edgeOrNil != nil {
            edges=edges.setByAddingObject(edgeOrNil!) ;
            let edgeId:Int32=Int32(edges.count-1);
            
            edgeOrNil!.edgeViewId=edgeId;
            // adding an edge sets vert1 and vert2 to be neighbors joined by the edge e
        }
        else {
            println("Graph Cat : SetupEdge: ");
        }
        vertOrNil1!.AddEdge(edgeOrNil, toVert:vertOrNil2);
    }

    // returns an array of the form [id1, id2] where the elements are ints
    // change NSMutableArray to array
    //
    func edgeIdArray()->Array<Array<Int32>> {

        var edgeArray:Array<Array<Int32>> = Array();
        //println("Graph cat: number of elems in edges is \(edges.count)");
        
        for testEdge in self.edges {
        
            if(!(testEdge is NSManagedObject)) { println("Graph cat: edgeIdArray: verts has element that is not an NSManagedObject"); }
            else {
                if(testEdge is Edge ) {
                    let (v:Vert?,w:Vert?)=(testEdge as! Edge).Connects();
                    edgeArray.append([v!.vertViewId,w!.vertViewId]);
                    
                }
                else {
                    println("Graph cat: edgeIdArray: verts has element that is not a vert");
                }
            }
        }
        return edgeArray;
    }


    func sortFunction(e1:Array<Int32>, e2:Array<Int32>)->Bool {
        let id00=e1[0];
        let id01=e1[1];
        let id10=e2[0];
        let id11=e2[1];
        
        if (id00 < id10) {
            return true;
        }
        else if (id00 > id10) {
            return false;
        }
        else {
            if(id01<id11) {
                return true;
            }
            else if(id01>id11) {
                return false;
            }
        }
        return false;
    }

    func sortedEdgeIdArray()->Array<Array<Int32>> {
        
        var bacon:Array<Array<Int32>> = edgeIdArray();
        let sortArray=sorted(bacon,sortFunction);

        return sortArray;
    }

    func getVertById(vertId:Int32)->Vert? {

        // check id
        let vertCount:Int32 = Int32(self.verts.count);
        if((vertId < Int32(0) ) || (vertCount <= vertId)) {
            print("getVertById: err id argument is too large or small");
            return nil;
        }
        // search for matching id
        for v in verts {
            if v is Vert {
                let vert:Vert=v as! Vert;
                if vert.vertViewId == vertId {
                    return vert;
                }
            }
        }
        return nil;
    }

    //moveVertTo(newX:Double, _ newY:Double)
    func moveVertById(vertId:Int32, toXPos endX:Float, toYPos endY:Float) {
        let v:Vert? = getVertById(vertId);
        // check v
        if(v==nil) {
            print("moveVertById err: no vert found");
        }
        v!.moveVertTo(endX, endY);
    }

}
/*
// NSObject override
-(NSString*)description {
    // store methodName for logging errors
    NSMutableString* description=[[NSMutableString alloc] initWithFormat:@"#V(G)=%lu    ",[self.vert count]];
    NSArray* edges;
    NSString* pairString;

    // get an array of "edge pairs"
    [self sortedEdgeIdArray:&edges];
    
    for(id p in edges) {
        if(![p isKindOfClass:[NSArray class]]) {
            NSLog(@"Graph cat: description: err");
            return nil;
        }
        NSArray* pair=(NSArray*)p;
        NSString* vertPairString=[NSString stringWithFormat:@"[%d %d],",[(NSNumber*)pair[0] intValue],[(NSNumber*)pair[1] intValue] ];
        [description appendString:vertPairString];
    }
    return description;
}

-(void)removeVertById:(NSNumber*)vertId {
    // TO DO
}

// public
-(Edge*)getEdgeById:(NSNumber*)edgeId {
    int idAsInt=[edgeId intValue];
    
    // check id
    if(idAsInt<0 || [self.edge count]<=idAsInt) {
        NSLog(@"getVertById: err id argument is too large or small");
        return nil;
    }
    // search for matching id
    for(id e in self.edge) {
        if([e isKindOfClass:[Edge class]]) {
            Edge* edge=(Edge*)e;
            if([edge.edgeViewId isEqualToNumber:edgeId]){
                return edge;
            }
        }
    }
    return nil;
}

// public
-(void)removeEdgeById:(NSNumber*)edgeId {
    // TO DO
}

#pragma mark testing methods

#pragma mark graph theory
// returns YES if a cycle exists in the graph and NO otherwise
// tests if graph has any cycles by recursively calling [cycleExistsExcludingEdgeBetween:v And:w]
-(BOOL)cycleExists {
    int depth=0;
    // start with arbitrary vert
    Vert* current=[self.vert anyObject];
    return [self cycleExistsExcludingEdgeBetween:current And:nil :depth];
}

// returns a cycle if one exists
-(NSMutableArray*)getCycle {
    int depth=0;
    // start with arbitrary vert
    Vert* current=[self.vert anyObject];
    NSMutableArray* edgePairs=[[NSMutableArray alloc] init];
    [self addEdgeToCycleIfCycleExistsExcludingEdgeBetween:current And:nil :depth OnEdges:edgePairs];
    // clean up model
    for(id v in self.vert) {
        if(![v isKindOfClass:[Vert class]]) {
            NSLog(@"graph cat: getCycle: self.vert contains elements that are not verts");
        }
        Vert* vert=(Vert*)v;
        [vert setDepthSearchSeen:NO];
    }
    return edgePairs;
*/
