//
//  GraphExtension.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-02.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import Foundation
import CoreData

protocol ModelObserver {

}

@objc(Graph)
class Graph: NSManagedObject {
// all methods in an extension
    /*
    func removeVert(vertToKill: Vert?) {
        if vertToKill != nil {
            verts=verts.setByRemovingObject();
        }
        
        // now delete the object from core data
    }
    */

    func gCurEdgeId()->Int32 {
        let selfEdges:NSNumber? = valueForKeyPath("curEdgeId") as? NSNumber
        if selfEdges == nil {print("Graph: curEdgeId is nil");}
        return selfEdges!.intValue;
    }
    
    func gCurVertId()->Int32 {
        let selfEdges:NSNumber? = valueForKeyPath("curVertId") as? NSNumber
        if selfEdges == nil {print("Graph: curVertId is nil");}
        return selfEdges!.intValue;
    }
    
    func sCurEdgeId(newId:Int32) {
        setValue(NSNumber(int: newId), forKeyPath: "curEdgeId") ;
    }
    
    func sCurVertId(newId:Int32) {
        setValue(NSNumber(int: newId), forKeyPath: "curVertId") ;
    }
    
    func gEdges()->Set<Edge> {
        //let selfEdges:Set<Edge>? = valueForKeyPath("edges") as? Set<Edge>
        var selfEdges = mutableSetValueForKeyPath("edges") as? Set<Edge>;
        //if selfEdges == nil {print("Graph: edges is nil");}
        return selfEdges!;
    }
    
    func gVerts()->Set<Vert> {
        //let verts:Set<Vert>? = valueForKeyPath("verts") as? Set<Vert>;
        var verts = mutableSetValueForKeyPath("verts") as? Set<Vert>;
        //if verts == nil {print("Graph: verts is nil");}
        return verts!;
    }
    
    func addVertToVerts(vert:Vert) {
        var selfNeighbors:Set<Vert>? = self.valueForKeyPath("verts") as? Set<Vert>;
        
        if selfNeighbors == nil {print("Graph:addVertToVerts is nil");}
        selfNeighbors!.insert(vert);
        setValue(selfNeighbors, forKeyPath: "verts");
    }
    
    func remVertFromVerts(vert:Vert) {
        var selfNeighbors:Set<Vert>? = valueForKeyPath("verts") as? Set<Vert>;
        
        if selfNeighbors == nil {print("Graph:remVertFromVerts is nil");}
        selfNeighbors!.remove(vert);
        
        setValue(selfNeighbors, forKeyPath: "verts");
    }
    
    func addEdgeToEdges(edge:Edge) {
        var selfNeighbors:Set<Edge>? = valueForKeyPath("edges") as? Set<Edge>;
        if selfNeighbors == nil {print("Graph:addEdgeToEdges is nil");}
        selfNeighbors!.insert(edge);
        
        setValue(selfNeighbors, forKeyPath: "edges");
    }
    
    func remEdgeFromEdges(edge:Edge) {
        var selfNeighbors:Set<Edge>? = valueForKeyPath("edges") as? Set<Edge>
        if selfNeighbors == nil {print("Graph:remEdgeFromEdges is nil");}
        
        selfNeighbors!.remove(edge);
        
        setValue(selfNeighbors, forKeyPath: "edges");
    }
    
    // getIds() is a debugging method
    // not tested
    func getIds()->Array<Int32> {
    
        var idArray:Array<Int32>=Array<Int32>();
        
        for v in verts! {
            if v is Vert {
                idArray.append((v as! Vert).vertViewId);
            }
        }
        return idArray;
    }
    
    func incrementCurVertId() {
        // set the id property
        let inc:Int32 = gCurVertId() + 1;
        setValue(NSNumber(int: inc), forKey: "curVertId");
    }
    
    func incrementCurEdgeId() {
    
        // set the id property
        let inc:Int32 = gCurEdgeId() + 1;
        setValue(NSNumber(int: inc), forKey: "curEdgeId");
    }
    
    //MARK: methods
        
    func SetupVert(vertOrNil:Vert?, AtX xPos:Float, AtY yPos:Float ) {
        // Warning: setting of ids should be guarded against the deletion of managed verts from but is not currently
      
        if vertOrNil != nil {
            // add to set within graph
            addVertToVerts(vertOrNil!);

            // set title
            incrementCurVertId();
            vertOrNil!.sVertViewId(self.gCurVertId());

            // set default title
            let title = "Entity\(self.gVerts().count)";
            vertOrNil!.setValue(title, forKeyPath: "title");
            
            // set position
            vertOrNil!.moveVertTo(xPos, yPos);
            
        }
        else {
            print("Graph cat: SetupVert: err ");
        }
    }
    
    func SetupEdge(edgeOrNil:Edge?, From vertOrNil1:Vert?, To vertOrNil2:Vert?) {
        if edgeOrNil != nil {
            addEdgeToEdges(edgeOrNil!);
            
            incrementCurEdgeId();
            // adding an edge sets vert1 and vert2 to be neighbors joined by the edge e
            
            edgeOrNil!.sEdgeViewId(self.gCurEdgeId());
        }
        else {
            print("Graph Cat : SetupEdge: ");
        }
        //TODO: check
        vertOrNil1!.AddEdge(edgeOrNil, toVert:vertOrNil2);
    }

    // returns an array of the form [id1, id2] where the elements are ints
    // change NSMutableArray to array
    //
    func edgeIdArray()->Array<Array<Int32>> {

        var edgeArray:Array<Array<Int32>> = Array();
        //println("Graph cat: number of elems in edges is \(edges.count)");
        
        for testEdge in edges! {
        
            if(!(testEdge is NSManagedObject)) { print("Graph cat: edgeIdArray: verts has element that is not an NSManagedObject"); }
            else {
                if(testEdge is Edge ) {
                    var (v, w): (Vert?, Vert?)=(testEdge as! Edge).Connects();
                    
                    if v!.gVertViewId() != nil && w!.gVertViewId() != nil {
                        edgeArray.append([v!.gVertViewId()!,w!.gVertViewId()!]);
                    }
                    else {
                        
                    }
                }
                else {
                    print("Graph cat: edgeIdArray: verts has element that is not a vert");
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
        
        let edges:Array<Array<Int32>> = edgeIdArray();
        let sortArray=edges.sort(sortFunction);

        return sortArray;
    }
    
    //MARK: edge inferface
    func getEdgeById(edgeId:Int32)->Edge? {

        if edgeId < Int32(0)  {
            print("Graph cat: getEdgeById: err id argument is too large or small");
            return nil;
        }
        // search for matching id
        for e in self.gEdges() {
                if e.gEdgeViewId() == edgeId {
                    return e;
                }

        }
        return nil;
    }

    //MARK: vert inferface
    func getVertById(vertId:Int32)->Vert? {

        if vertId < Int32(0)  {
            print("Graph cat: getVertById: err id argument is too large or small");
            return nil;
        }
        // search for matching id
        for v in self.gVerts() {
            //print( "\(vertId), \(v.gVertViewId())" );
                if v.gVertViewId() == vertId {
                    return v;
                }
        }
        return nil;
    }

    //moveVertTo(newX:Double, _ newY:Double)
    func moveVertById(vertId:Int32, toXPos endX:Float, toYPos endY:Float) {
        var v:Vert? = getVertById(vertId);
        // check v
        if(v==nil) {
            print("moveVertById err: no vert found", appendNewline: false);
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
