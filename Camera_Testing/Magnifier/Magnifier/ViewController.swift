//
//  ViewController.swift
//  Magnifier
//
//  Created by Developer on 3/10/17.
//  Copyright © . 
//

import UIKit

class ViewController: UIViewController {

    // MARK: - Properties
    
    fileprivate var zoom: MagnifierView!
    fileprivate var touchTimer: Timer!
    fileprivate var isDragged = false
    
    // MARK: - LyfeCicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension ViewController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.addLoop), userInfo: nil, repeats: false)

        if zoom == nil {
            zoom = MagnifierView()
            zoom.viewToMagnify = self.view
        }
        self.isDragged = false
        UIMenuController.shared.isMenuVisible = false

        let touch: UITouch? = touches.first
        zoom.touchPoint = (touch?.location(in: self.view))!
        zoom.setNeedsDisplay()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.isDragged = true
        self.handleAction(touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchTimer.invalidate()
        self.zoom.removeFromSuperview()
        if self.isDragged {
            self.isDragged = false
        }
    }
    
    func handleAction(_ touches: Set<UITouch>) {
        let touch: UITouch? = touches.first
        zoom.touchPoint = (touch?.location(in: self.view))!
        zoom.setNeedsDisplay()
    }
}

extension ViewController {
    
    @objc fileprivate func addLoop() {
        // add the loop to the superview.  if we add it to the view it magnifies, it'll magnify itself!
        self.view.superview?.addSubview(zoom)
        // here, we could do some nice animation instead of just adding the subview...
    }
}
