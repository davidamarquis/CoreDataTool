//
//  GraphWorldView.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-01.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import UIKit

class GraphWorldView: UIView {

    // MARK: vars
    var circSize,edgeSize,strokeSize: CGFloat?;
    // not used
    var x1,x2,y1,y2: Double?;
    var radius: CGFloat {return (circSize!+edgeSize!)/2; }
    var diameter: CGFloat {return (circSize!+edgeSize!); }

    // MARK: init
    override init(frame: CGRect) {
        // step1: set non-inherited properties
        circSize=50;
        edgeSize=10;
        strokeSize=5;
        
        // step 2: delegate to superclass
        super.init(frame: frame);
        
        // make the graph recognize taps
        let recog = UITapGestureRecognizer(target:self, action:"tap:");
        // step 3: set inherited properties
        self.backgroundColor=UIColor.whiteColor();
        addGestureRecognizer(recog);
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }

    // MARK: methods
    func removeSubviews() {
        for s in subviews {
            s.removeFromSuperview();
        }
    }

    func tap(recognizer:UITapGestureRecognizer) {

        let cgp:CGPoint=recognizer.locationInView(self);
        let N:Int=subviews.count;
        var i:Int=0;
        
        for(i=0;i<N;i++) {
        
            if(subviews[i] is VertView) {
                let cur:VertView = subviews[i] as! VertView;
                // do a hit test on the vert
                // ok so need to know
                if( cur.updateIfHit(cgp) ) {
                    break;
                }
            }
        }
        if(i+1==N) {
            return;
        }
        else {
            i=i+1;
            for( ;i<N;i++) {
                if(subviews[i] is VertView) {
                    let cur:VertView=subviews[i] as! VertView;
                    if(cur.selected) {
                        cur.selected=false;
                    }
                }
            }
        }
    }

    //MARK: Vert Interface
    func addVertAtPoint(cgp:CGPoint)->VertView {
        let diameter:CGFloat=circSize!+edgeSize!;

        let vert:VertView=VertView( frame: CGRectMake(cgp.x, cgp.y, diameter, diameter) );

        vert.circSize=circSize;
        vert.strokeSize=strokeSize;
        addSubview(vert);
        setNeedsDisplay();
        return vert;
    }
    // return the VertView corresponding to a particular id
    // or nil if such a VertView does not exist
    func getVertViewById(vertViewId:Int32) -> VertView? {

        for subview in subviews {
            if subview is VertView {
                let vertView:VertView=subview as! VertView;
                if(vertView.vertViewId == vertViewId) {return vertView;}
            }
        }
        return nil;
    }

    //MARK: Edge Interface
    func addEdgeWithFrame(frame:CGRect, topLeftToBotRight:Bool) {
        let ev:EdgeView=EdgeView(frame: frame);
        ev.topLeftToBotRight=topLeftToBotRight;
        // fill in the radius
        ev.radius=self.radius;
        addSubview(ev);
        sendSubviewToBack(ev);
    }

    // return the EdgeView corresponding to a particular id
    func getEdgeViewById(edgeViewId:Int32)->EdgeView? {
        for subview in subviews {
            if subview is EdgeView {
                let edgeView:EdgeView=subview as! EdgeView;
                if(edgeView.edgeViewId == edgeViewId) {return edgeView;}
            }
        }
        return nil;
    }

}
