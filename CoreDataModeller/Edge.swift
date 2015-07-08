//
//  EdgeExtension.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-02.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import Foundation
import CoreData

@objc(Edge)
class Edge: NSManagedObject {

    //MARK: getters
    func gEdgeViewId()->Int32 {
        let selfEdges:NSNumber? = valueForKeyPath("edgeViewId") as? NSNumber
        if selfEdges == nil {print("Edge: getFreshView: is nil");}
        return selfEdges!.intValue;
    }
    
    func gFreshView()->Bool {
        let selfEdges:NSNumber? = valueForKeyPath("freshView") as? NSNumber
        if selfEdges == nil {print("Edge: getFreshView: is nil");}
        return selfEdges!.boolValue;
    }
    
    func gRel1Name()->String {
        let rel1:String? = valueForKeyPath("rel1name") as? String
        if rel1 == nil {print("Edge: getRel1Name: rel1 is nil");}
        return rel1!;
    }
    
    func gRel2Name()->String {
        let rel2:String? = valueForKeyPath("rel2name") as? String
        if rel2 == nil {print("Edge: getRel2Name: rel2 is nil");}
        return rel2!;
    }
    
    func gVertChange()->Bool {
        let selfEdges:NSNumber? = valueForKeyPath("getVertChange") as? NSNumber
        if selfEdges == nil {print("Edge: getVertChange: is nil");}
        return selfEdges!.boolValue;
    }
    
    func gJoinedTo()->Set<Vert> {
        let selfNeighbors:Set<Vert>? = valueForKeyPath("joinedTo") as? Set<Vert>;
        if selfNeighbors == nil {print("Edge: joinedTo: nil");}
        return selfNeighbors!;
    }
    
    //MARK: setters
    func sEdgeViewId(int:Int32) {
        setValue(NSNumber(int:int),forKeyPath: "edgeViewId") ;
    }
    
    func sFreshView(bool:Bool) {
        setValue(NSNumber(bool:bool),forKeyPath:"freshView");
        //setValue(NSNumber(bool:bool),forKeyPath: "freshView") ;
    }
    
    func sRel1Name(string:String) {
        let opString:String? = string;
        setValue(opString,forKeyPath: "rel1name") ;
    }
    
    func sRel2Name(string:String) {
        let opString:String? = string;
        setValue(opString,forKeyPath: "rel2name") ;
    }
    
    func sVertChange(bool:Bool) {
        setValue(NSNumber(bool: bool),forKeyPath: "vertChange") ;
    }
    
    func addVertToJoinedTo(vert:Vert) {
        let key="joinedTo";
        var selfNeighbors:Set<Vert>? = valueForKeyPath(key) as? Set<Vert>;
        if selfNeighbors == nil {print("Edge:addVertToJoinedTo: selfNeighbors is nil");}
        selfNeighbors!.insert(vert);
        
        setValue(selfNeighbors, forKeyPath: key);
    }
    
    func remVertFromJoinedTo(vert:Vert) {
        let key="joinedTo";
        var selfNeighbors:Set<Vert>? = valueForKeyPath(key) as? Set<Vert>;
        if selfNeighbors == nil {print("Edge:remVertToJoinedTo: selfNeighbors is nil");}
        selfNeighbors!.remove(vert);
        
        setValue(selfNeighbors, forKeyPath: key);
    }
    
    //MARK: init
    // setEdgeProperties must init all attributes of an edge
    func setEdgeProperties() {
        sEdgeViewId(-1);
        sFreshView(false);
        sRel1Name("");
        sRel2Name("");
        sVertChange(false);
    }
/*
    override var description:String {
        // store methodName for logging errors
        // should use connects
        // not going to worry about deterministic display when there are only two elements
        //let (v:Vert,w:Vert)=Connects();
        
        //var desc:String="Edge(\(Int(v.x)),\(Int(v.y)))(\(Int(w.x)),\(Int(w.y)))";
        var desc = String();
        
        if gJoinedTo().count != 2 {
            desc=desc+"INCOMPLETE";
        }
        for v in gJoinedTo() {
            desc=desc + "(";
            desc=desc + "\(Int(v.x)) , \(Int(v.y))";
            desc=desc + ")";
        }
        
        return desc;
    }
*/
    // computed properties
    //TODO:
    /*
    func length()->Float? {
        let v:Vert?;
        let w:Vert?;
        (v,w)=Connects();
        if v != nil && w != nil {
            return v!.distance(w!);
        }
        print("Edge cat: length: v or w is nil");
        return nil;
    }

    func angle()->Float? {
        let v:Vert?;
        let w:Vert?;
        (v,w)=Connects();
        if v != nil && w != nil {
            return Float(atan2(v!.y - w!.y, v!.x-w!.x ));
        }
            print("Edge cat: length: v or w is nil");
            return nil;
    }
    */

    // not tested
    func getNameForVert(vert:Vert)->String? {
        var v:Vert?;
        var w:Vert?;
        (v,w)=Connects();
        
        if v == nil || w == nil {print("Edge ext: getNameForVert: could not get pair of verts that the edge connects");}
        if vert === v! {
            return gRel1Name();
        }
        else if vert === w! {
            return gRel2Name();
        }
        else {
            print("Edge ext: getNameForVert: err");
            return nil;
        }
    }

    // not tested
    // setNameForVert() sets the relationship name for the given vert
    func setNameForVert(vert:Vert, relationshipName:String) {
        var v:Vert?;
        var w:Vert?;
        (v,w)=Connects();
        if v == nil || w == nil {print("Edge ext: getNameForVert: could not get pair of verts that the edge connects");}
        
        print("edge cat: setNameForVert: \(v!.gTitle()), \(w!.gTitle())");
        if vert === v! {
            sRel1Name(relationshipName);
        }
        else if vert === w! {
            sRel2Name(relationshipName);
            //rel2name = relationshipName;
        }
        else {
            print("Edge ext: setNameForVert: err");
        }
    }

    // not tested
    func setNameForInverseOfVert(vert:Vert, relationshipName:String) {

        let inverse = vert.getNeighborOnEdge(self);
        var v:Vert?;
        var w:Vert?;
        (v,w)=Connects();
        if v == nil || w == nil {print("Edge ext: getNameForVert: could not get pair of verts that the edge connects");}
        
        if inverse === v! {
            print("edge cat: setNameForInverse: the entity \(v!.gTitle()) has a relationship \(relationshipName) ");
            sRel1Name(relationshipName);
        }
        else if inverse === w! {
            print("edge cat: setNameForInverse: the entity \(w!.gTitle()) has a relationship \(relationshipName) ");
            sRel2Name(relationshipName);
        }
        else {print("Edge ext: getNameForVert: err");}
    }

    // returns the two verts that an edge is connected to
    func Connects() -> (v:Vert?,w:Vert?) {
        
        // v and w: if both do not exist both will be nil
        var v:Vert?;
        var w:Vert?;
        // check that the number of verts on an edge is correct
        // this is made more important because verts can be deleted from the graph
        if gJoinedTo().count < 2 {
            print("Edge cat: Connects: vertArray: err edge has too few verts in joinedTo");
        }
        else if gJoinedTo().count > 2 {
            print("Edge cat: Connects: vertArray: err edge has too few verts in joinedTo")
        }

        var count:Int=0;
        for vert in gJoinedTo() {
            if count == 0 {
                v = vert;
            }
            else {
                w = vert;
            }
            count++;
        }

        if v != nil && w != nil {
            orderVerts(v,w);
            return orderVerts(v,w);
        }
        else {
            return (nil,nil);
        }
    }
    
    func orderVerts(v:Vert?,_ w:Vert?)->(Vert?,Vert?) {
        if v!.gVertViewId() < w!.gVertViewId() {
            return (v,w);
        }
        else if v!.gVertViewId() > w!.gVertViewId() {
            return (w,v);
        }
        else {
            print("Edge: orderVerts: err ids of both verts are equal");
            //TODO: try (nil, nil)
            return (v,w);
        }
    }

    func swapDesintationVert(v:Vert,forVert w:Vert) {
        //var manyRelation:AnyObject?
        
        // remove
        if gJoinedTo().count != 2 {
            print("Edge cat: swapDestinationVert: err number of connected verts before removal is wrong");
        }
        remVertFromJoinedTo(v);
        
        if gJoinedTo().count != 1 {
            print("Edge cat: swapDestinationVert: err number of connected verts after removal is wrong");
        }
        
        // add
        addVertToJoinedTo(w);
        
        vertChange = true;
    }
    
    deinit {
    
    }

}
