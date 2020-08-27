//
//  ShareViewController.swift
//  Scanner
//
//   on 2/1/17.
//   
//

import UIKit

enum ShareWithExportType {
    case with, none
}

protocol ShareViewControllerDelegate: class {
    func didEndDismissController()
    func didSelectItemAt(_ indexPath: IndexPath, application: App?)
    func didSelectFileTypeSegmentTapped(_ sender: UISegmentedControl)
}

class ShareViewController: UIViewController {
    
    // MARK: - Properties
    
    var shareWith: ShareWithExportType = .none
    
    weak var shareDelegate: ShareViewControllerDelegate?
    
    fileprivate var appCategories: [ShareAppCategory]?
    
    fileprivate lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.paleGrey
        view.layer.cornerRadius = 4.0
        
        return view
    }()
    
    fileprivate lazy var actionView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.layer.cornerRadius = 4.0
        
        return view
    }()
    
    fileprivate lazy var exportLabel: UILabel = {
        let label = createLabel(UIColor.gri, font: UIFont.textStyleFontRegular(14), spacing: -0.5)
        label.text = "Export as:"
        label.textAlignment = .left
        
        return label
    }()
    
    fileprivate let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel".localized(), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 22)
        button.titleLabel?.textColor = UIColor.darkSkyBlue
        button.titleLabel?.text?.addTextSpacing(-0.7)
        button.backgroundColor = UIColor.paleGrey
        button.layer.cornerRadius = 4.0
        button.addTarget(self, action: #selector(cancelTapped(_:)), for: .touchUpInside)
        
        return button
    }()
    
    fileprivate let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = .zero
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 8.0
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.showsVerticalScrollIndicator = false
        
        return collection
    }()
    
    fileprivate lazy var exportSegmentedControl: UISegmentedControl = {
        let segment = UISegmentedControl()
        segment.insertSegment(withTitle: "JPEG", at: 0, animated: true)
        segment.insertSegment(withTitle: "PDF Text".localized(), at: 1, animated: true)
        segment.tintColor = UIColor.darkSkyBlue
        segment.selectedSegmentIndex = 0
        segment.addTarget(self, action: #selector(fileTypeSegmentTapped(_:)), for: .valueChanged)
        
        return segment
    }()
    
    
    
    // MARK: - LyfeCicle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        updateUI()
        
        self.collectionView.register(ShareCategoryCell.self, forCellWithReuseIdentifier: ShareCategoryCell.reuseIdentifier)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        appCategories = ShareAppCategory.sampleAppCategory()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Deinitializers
    
    deinit {
        shareDelegate = nil
        appCategories = nil
    }
}


extension ShareViewController {
    
    fileprivate func updateUI() {
        view.addSubview(containerView)
        containerView.addSubview(actionView)
        containerView.addSubview(collectionView)
        
        switch deviceType {
        case .phone:
            //            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(gestureTapped(_:)))
            //            view.addGestureRecognizer(tapGesture)
            
            switch shareWith {
            case .with:
                view.addSubview(cancelButton)
                actionView.addSubview(exportLabel)
                actionView.addSubview(exportSegmentedControl)
                
                view.addConstraintsWithFormat("H:|-7-[v0]-7-|", views: containerView)
                view.addConstraintsWithFormat("H:|-7-[v0]-7-|", views: cancelButton)
                view.addConstraintsWithFormat("V:[v0(388)]-7-[v1(60)]-7-|", views: containerView, cancelButton)
                
                
                containerView.addConstraintsWithFormat("H:|[v0]|", views: collectionView)
                containerView.addConstraintsWithFormat("H:|-20-[v0]-20-|", views: actionView)
                
                containerView.addConstraintsWithFormat("V:|-20-[v0(44)]-2-[v1]|", views: actionView, collectionView)
                
                actionView.addConstraintsWithFormat("H:|[v0][v1(200)]|", views: exportLabel, exportSegmentedControl)
                actionView.addConstraintsWithFormat("V:|-2-[v0]-2-|", views: exportLabel)
                actionView.addConstraintsWithFormat("V:|-2-[v0]-2-|", views: exportSegmentedControl)

            case .none:
                view.addSubview(cancelButton)
                
                view.addConstraintsWithFormat("H:|-7-[v0]-7-|", views: containerView)
                view.addConstraintsWithFormat("H:|-7-[v0]-7-|", views: cancelButton)
                
                view.addConstraintsWithFormat("V:[v0(317)]-7-[v1(60)]-7-|", views: containerView, cancelButton)
                
                containerView.addConstraintsWithFormat("H:|[v0]|", views: collectionView)
                containerView.addConstraintsWithFormat("V:|-14-[v0]|", views: collectionView)
            }

        case .pad:
            view.backgroundColor = UIColor.paleGrey
            navigationController?.popoverPresentationController?.backgroundColor = UIColor.paleGrey
            
            switch shareWith {
            case .with:
                
                view.addConstraintsWithFormat("H:|[v0]|", views: containerView)
                view.addConstraintsWithFormat("V:|[v0]|", views: containerView)
                
                
                containerView.addConstraintsWithFormat("H:|-16-[v0]-20-|", views: actionView)
                containerView.addConstraintsWithFormat("H:|-14-[v0]|", views: collectionView)
                
                containerView.addConstraintsWithFormat("V:|-20-[v0(44)]-2-[v1]|", views: actionView, collectionView)
                
                
                actionView.addSubview(exportLabel)
                actionView.addSubview(exportSegmentedControl)
                
                
                actionView.addConstraintsWithFormat("H:|-20-[v0][v1(200)]|", views: exportLabel, exportSegmentedControl)
                actionView.addConstraintsWithFormat("V:|-2-[v0]-2-|", views: exportLabel)
                actionView.addConstraintsWithFormat("V:|-2-[v0]-2-|", views: exportSegmentedControl)
                
            case .none:
                view.addConstraintsWithFormat("H:|[v0]|", views: containerView)
                view.addConstraintsWithFormat("V:|[v0]|", views: containerView)
                
                containerView.addConstraintsWithFormat("H:|[v0]|", views: collectionView)
                containerView.addConstraintsWithFormat("V:|-14-[v0]|", views: collectionView)
            }
        default:
            break
        }
    }
}


// MARK: - UICollectionViewDataSource

extension ShareViewController: UICollectionViewDataSource {
    
    internal func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.appCategories?.count ?? 0
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShareCategoryCell.reuseIdentifier, for: indexPath) as! ShareCategoryCell
        cell.appCategory = appCategories?[indexPath.row]
        cell.cellTapeableDegelate = self
        
        return cell
    }
}


// MARK: - UICollectionViewDelegate

extension ShareViewController: UICollectionViewDelegate {
    
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("cell section \(indexPath.section)\ncell row: \(indexPath.row)\n")
    }
}


// MARK: - UICollectionViewDelegateFlowLayout

extension ShareViewController: UICollectionViewDelegateFlowLayout {
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat = (containerView.frame.height - 36) / 3 /// 22 bottom and 14 top

        switch shareWith {
        case .none:
            switch deviceType {
            case .phone:
                return CGSize(width: collectionView.frame.width, height: height)
            case .pad:
                return CGSize(width: collectionView.frame.width, height: height)
            default:
                return .zero
            }
        default:
            switch deviceType {
            case .phone:
                return CGSize(width: collectionView.frame.width, height: height - 16)
            case .pad:
                return CGSize(width: collectionView.frame.width, height: height - 26)
            default:
                return .zero
            }
        }
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
}


// MARK: - Action's 

extension ShareViewController {
    
    @objc fileprivate func cancelTapped(_ button: UIButton) {
        self.dismissCurentController()
    }
    
    @objc fileprivate func fileTypeSegmentTapped(_ sender: UISegmentedControl) {
        self.shareDelegate?.didSelectFileTypeSegmentTapped(sender)
    }
    
    @objc fileprivate func gestureTapped(_ sender: UITapGestureRecognizer) {
        dismissCurentController()
    }
    
    internal func dismissCurentController() {
        self.shareDelegate?.didEndDismissController()
        self.dismiss(animated: true, completion: nil)
    }
}


// MAKR: - CellTapeable

extension ShareViewController: CellTapeable {

    internal func didSelectItemAt(_ indexPath: IndexPath, application: App?) {
        print("application section \(indexPath.section)\ncell application row: \(indexPath.row)\n")
        dismissCurentController()
        shareDelegate?.didSelectItemAt(indexPath, application: application)
    }
}
