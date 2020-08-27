//
//  CornerpointView.swift
//  CropImg
//


import UIKit


class CornerpointView: UIView
{
    var drawCornerOutlines = false
    var cornerpointDelegate: CornerpointClientProtocol?
    var dragger: UIPanGestureRecognizer!
    var dragStart: CGPoint!
    var pointForTargetView: UIView?
    
    //the centerPoint property is an optional. Set it to nil to hide this corner point.
    var centerPoint: CGPoint?
    {
        didSet(oldPoint)
        {
            if let newCenter = centerPoint
            {
                isHidden = false
                center = newCenter
                //println("newCenter = \(newCenter)")
            }
            else
            {
                isHidden = true
            }
        }
    }
    
    init()
    {
        super.init(frame:CGRect.zero)
        doSetup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        doSetup()
    }
    
    //-------------------------------------------------------------------------------------------------------
    
    func doSetup()
    {
        pointForTargetView = self
        dragger = UIPanGestureRecognizer(target: self as AnyObject,
                                         action: #selector(CornerpointView.handleCornerDrag(_:)))
        addGestureRecognizer(dragger)
        
        //Make the corner point view big enough to drag with a finger.
        bounds.size = CGSize(width: 50, height: 50)
        
        //Add a layer to the view to draw an outline for this corner point.
        let circleSize: CGFloat = 24.0
        let newLayer = CALayer()
        newLayer.position = CGPoint(x: layer.bounds.midX, y: layer.bounds.midY)
        newLayer.bounds.size = CGSize(width: circleSize, height: circleSize)
        newLayer.borderWidth = 2.0
        newLayer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        newLayer.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5).cgColor
        newLayer.cornerRadius = circleSize/2
        
        
        //This code adds faint outlines around the draggable region of each corner so you can see it.
        //I think it looks better NOT to draw an outline, but the outline does let you know where to drag.
        if drawCornerOutlines
        {
            //Create a faint white 3-point thick rectangle for the draggable area
            var shapeLayer = CAShapeLayer()
            shapeLayer.frame = layer.bounds
            shapeLayer.path = UIBezierPath(rect: layer.bounds).cgPath
            shapeLayer.strokeColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2).cgColor
            shapeLayer.lineWidth = 3.0;
            shapeLayer.fillColor = UIColor.clear.cgColor
            layer.addSublayer(shapeLayer)
            
            //Create a faint black 1 pixel rectangle to go on top  white rectangle
            shapeLayer = CAShapeLayer()
            shapeLayer.frame = layer.bounds
            shapeLayer.path = UIBezierPath(rect: layer.bounds).cgPath
            shapeLayer.strokeColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
            shapeLayer.lineWidth = 1;
            shapeLayer.fillColor = UIColor.clear.cgColor
            layer.addSublayer(shapeLayer)
            
        }
        layer.addSublayer(newLayer)
    }
    
    //-------------------------------------------------------------------------------------------------------
    
    func handleCornerDrag(_ thePanner: UIPanGestureRecognizer)
    {
        //println("In cornerpoint dragger")
        //    let newPoint = thePanner.locationInView(self)
        switch thePanner.state
        {
        case UIGestureRecognizerState.began:
            dragStart = centerPoint
            thePanner.setTranslation(CGPoint.zero,
                                     in: self)
            //println("In view dragger began at \(newPoint)")
            
        case UIGestureRecognizerState.changed:
            //println("In view dragger changed at \(newPoint)")
            centerPoint = CGPoint(x: dragStart.x + thePanner.translation(in: self).x,
                                  y: dragStart.y + thePanner.translation(in: self).y)
            
            //If we have a delegate, notify it that this corner has moved.
            //This code uses "optional binding" to convert the optional "cornerpointDelegate" to a required
            //variable "theDelegate". If cornerpointDelegate == nil, the code that follows is skipped.
            
            cornerpointDelegate?.cornerHasChanged(self)
            
        default:
            break;
        }
    }    
}
