//
//  GraphWorldView.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-01.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import UIKit

protocol GestureResponse: class {
    func handleStateBegan(recog:UIPanGestureRecognizer);
    func handleStateChanged(recog:UIPanGestureRecognizer);
    func handleStateEnded(recog:UIPanGestureRecognizer);
}
    
class GraphWorldView: UIView {

    // MARK: vars and inits
    weak var gestureResponseDelegate:GestureResponse?;
    var circSize,edgeSize,strokeSize: CGFloat?;

    var gestureVV:VertView?;
    var shiftedOrigin:CGPoint?;
    // panCount is for debug
    var panCount=0;
    var radius: CGFloat {return (circSize!+edgeSize!)/2; }
    var diameter: CGFloat {return (circSize!+edgeSize!); }
    
    override init(frame: CGRect) {
    
        //(1) set non-inherited properties
        circSize=50;
        edgeSize=10;
        strokeSize=5;
        
        //(2) delegate to superclass
        super.init(frame: frame);
        
        //(3) add a gesture recognizer to the view
        addGestureRecognizer(UIPanGestureRecognizer(target:self, action:"pan:" ));
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
    
    // MARK: gesture recognizers
    
    // pan() determines the state of the pan gesture and passes it to the Gestures extension of CoreController to handle
    func pan(recognizer:UIPanGestureRecognizer) {
    
        panCount++;
        if gestureResponseDelegate == nil {print("GraphView: pan: delegate is nil");}
        
        if(recognizer.state==UIGestureRecognizerState.Began) {gestureResponseDelegate!.handleStateBegan(recognizer);}
        else if(recognizer.state == UIGestureRecognizerState.Changed ) {gestureResponseDelegate!.handleStateChanged(recognizer);}
        else if(recognizer.state==UIGestureRecognizerState.Ended) {
            gestureResponseDelegate!.handleStateEnded(recognizer);
            
            //reset panCount;
            panCount=0;
        }
        else {print("VertView: pan(): err state is not valid");}
    }

    //MARK: Vert Interface
    //addVertAtPoint() creates a vert at a particular points. Returns a ref for further customization
    func addVertAtPoint(cgp:CGPoint)->VertView {
        let diameter:CGFloat=circSize!+edgeSize!;
        let vert:VertView=VertView( frame: CGRectMake(cgp.x, cgp.y, diameter, diameter) );
        (vert.circSize,vert.strokeSize)=(circSize,strokeSize);
        addSubview(vert);
        return vert;
    }
    
    //getVertViewById() returns the VertView corresponding to a particular id or nil if such a VertView does not exist
    func getVertViewById(vertVId:Int32) -> VertView? {

        for subview in subviews {
            if subview is VertView {
                let vertView:VertView=subview as! VertView;
                print("VERTVIEW: \(vertView.vertViewId!) and input id is \(vertVId)");
                if(vertView.vertViewId! == vertVId) {return vertView;}
            }
            else {
                // probably subview is an Edge
            }
        }
        return nil;
    }

    //MARK: Edge Interface
    //setEdge() sets the properties of an EdgeView and returns a ref to it (ref is needed if for example the edgeView init() was in setEdge input)
    func setEdge(ev:EdgeView, topLeftToBotRight:Bool)->EdgeView {
        ev.topLeftToBotRight=topLeftToBotRight;
        // fill in the radius
        ev.radius=radius;

        addSubview(ev);
        sendSubviewToBack(ev);

        return ev;
    }

    // return the EdgeView corresponding to a particular id
    func getEdgeViewById(edgeVId:Int32)->EdgeView? {
        for subview in subviews {
            if subview is EdgeView {
            
                let edgeView:EdgeView=subview as! EdgeView;
                if(edgeView.edgeViewId! == edgeVId) {
                    print("GraphWorldView: getEdgeViewById: got edge with id \(edgeVId)");
                    return edgeView;
                }
            }
        }
        return nil;
    }

}
