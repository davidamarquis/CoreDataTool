//
//  GraphView.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-01.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import UIKit

class GraphView: UIScrollView {

    var gridOn:Bool=true;
    var gwv:GraphWorldView?;
    var gridBack:UIView?;

    func switchGraphState() {
    
        if gridBack != nil {
            if gridOn {
                gridBack!.removeFromSuperview();
                gridBack!.setNeedsDisplay();
                gridOn = !gridOn;
            }
            else {
                addSubview(gridBack!);
                gridBack!.setNeedsDisplay();
                sendSubviewToBack(gridBack!);
                gridOn = !gridOn;
            }
        }
    }
    
    func setupGraphWorldView() {
        // init gwv and nil check
        gwv=GraphWorldView();
        if gwv == nil { println("GraphView: setupGraphWorldView: gwv is nil"); }
        
        gwv!.frame=CGRectMake(0,0, contentSize.width, contentSize.height);
        gwv!.backgroundColor=UIColor.clearColor();

        addSubview(gwv!);
    }
    
    // drawGraph() must be run before setupGraphWorldView()
    func drawGraph() {
        // img name
        let str:String="gridHalf";
        
        let grid:UIImage?=UIImage(named:str);
        if grid == nil {println("GraphView: setupGraphWorldView: img named \(str) not found");}
        
        var gwidth,gheight, curY, curX:CGFloat;
        (gwidth,gheight,curX,curY)=(grid!.size.width, grid!.size.height, 0, 0);
        
        if gridBack == nil {
            println("GraphView: drawGraph: gridBack is nil");
        }
        
        while curY < contentSize.height {
            while curX < contentSize.width {
                // create a UIImageView
                let gridView = UIImageView(image: UIImage(named:str));
                // adjust the frame of the UIImageView
                gridView.frame=CGRectMake(curX, curY, gwidth, gheight);
                // add the UIImageView as a subview of GraphView
                gridBack!.addSubview(gridView);
                // increment the current value of curX
                curX += gwidth;
            }
            curX=0;
            curY += gheight;
        }
    }
    
    convenience init(frame: CGRect, graphWorldViewDeleg: CoreController) {
        self.init(frame: frame);
        self.gwv!.gestureResponseDelegate=graphWorldViewDeleg;
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        setup();
    }
    override init(frame: CGRect) {
        super.init(frame: frame);
        setup();
    }
    private func setup() {
        contentSize=CGSizeMake(1000,1000);
        // self.backgroundColor may seem irrelevant as the view is covered by a GraphWorldView
        // This is wrong. There is no default color so nothing will be displayed
        backgroundColor=UIColor.whiteColor();
        
        opaque=false;
        gridBack=UIView(frame:CGRectMake(0,0,contentSize.width,contentSize.height));
        if gridOn {
            addSubview(gridBack!);
        }
        drawGraph();
        setupGraphWorldView();
    }
}
