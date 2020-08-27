//
//  CropperViewController.swift
//  AVCamera
//
//  Created  on 3/7/17.
//  Copyright © 2017 A. 
//

import UIKit
import Rectangle

class CropperViewController: CropViewController {
    
    // MARK: - Properties
    
    var cameraResolution: CameraResolution!
    var image: UIImage!
    
    fileprivate lazy var cancelButton: UIButton =  {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "shape"), for: .normal)
        button.addTarget(self, action: #selector(cancelTapped(_:)), for: .touchUpInside)
        
        return button
    }()
    
    fileprivate lazy var doneButton: UIButton =  {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "select"), for: .normal)
        button.addTarget(self, action: #selector(doneTapped(_:)), for: .touchUpInside)
        
        return button
    }()
    
    fileprivate lazy var selectSegmentedControl: UISegmentedControl = {
        let segment = UISegmentedControl()
        segment.insertSegment(withTitle: "Find", at: 0, animated: true)
        segment.insertSegment(withTitle: "All", at: 1, animated: true)
        segment.tintColor = UIColor.blue
        segment.selectedSegmentIndex = 0
        segment.addTarget(self, action: #selector(selectSegmentTapped(_:)), for: .valueChanged)
        
        return segment
    }()
    
    fileprivate lazy var segmentContainerView: UIView = {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        
        return headerView
    }()
}



// MARK: - SetupUI

extension CropperViewController {
    
    override func setupUI() {
        setupFooterViewUI()
        setupHeaderViewUI()
    }
    
    fileprivate func setupHeaderViewUI() {
        headerView.addSubview(segmentContainerView)
        headerView.addConstraintsWithFormat("H:|[v0]|", views: segmentContainerView)
        headerView.addConstraintsWithFormat("V:|-20-[v0]|", views: segmentContainerView)
        
        
        segmentContainerView.addSubview(selectSegmentedControl)
        selectSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        let views = ["segmentContainerView": segmentContainerView, "selectSegmentedControl": selectSegmentedControl]
        
        /// Center horisontally
        let horizontalConstraint = NSLayoutConstraint.constraints(
            withVisualFormat: "V:[segmentContainerView]-(<=1)-[selectSegmentedControl(30)]",
            options: .alignAllCenterX,
            metrics: nil,
            views: views)
        
        segmentContainerView.addConstraints(horizontalConstraint)
        
        /// Center vertically
        let verticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:[segmentContainerView]-(<=1)-[selectSegmentedControl(150)]",
            options: .alignAllCenterY,
            metrics: nil,
            views: views)
        
        segmentContainerView.addConstraints(verticalConstraints)
    }
    
    fileprivate func setupFooterViewUI() {
        footerView.addSubview(cancelButton)
        footerView.addSubview(doneButton)
        
        footerView.addConstraintsWithFormat("H:|-17-[v0(30)]", views: cancelButton)
        footerView.addConstraintsWithFormat("V:|-7-[v0(30)]-7-|", views: cancelButton)
        
        footerView.addConstraintsWithFormat("H:[v0(30)]-17-|", views: doneButton)
        footerView.addConstraintsWithFormat("V:|-7-[v0(30)]-7-|", views: doneButton)
    }
}



// MARK: - Action's

extension CropperViewController {
    
    @objc fileprivate func cancelTapped(_ button: UIButton) {
        dismissCurrentController()
    }
    
    @objc fileprivate func doneTapped(_ button: UIBarButtonItem) {
        
    }
    
    fileprivate func dismissCurrentController() {
        self.dismiss(animated: true, completion: nil)
    }
}


// MARK: - selectSegmentTapped

extension CropperViewController {
    
    @objc fileprivate func selectSegmentTapped(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.findRectangleInImage()
            
            print(0)
        default:
            self.selectAllArea()
        }
    }
}
