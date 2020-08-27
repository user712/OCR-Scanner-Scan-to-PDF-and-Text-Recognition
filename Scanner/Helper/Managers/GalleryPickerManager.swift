//
//  GalleryPickerManager.swift
//  Scanner
//
//  
//   
//

import UIKit
import Photos

extension UIViewController {
    
    /// Present Image Picker using closures rather than delegation.
    ///
    /// - Parameters:
    ///   - imagePicker: the `OpalImagePickerController`
    ///   - animated: is presentation animated
    ///   - select: notifies when selection of `[PHAsset]` has been made
    ///   - cancel: notifies when Image Picker has been cancelled by user
    ///   - completion: notifies when the Image Picker finished presenting
    func presentGalleryImagePickerController(_ imagePicker: GalleryImagePickerController, animated: Bool, select: @escaping (([PHAsset]) -> Void), cancel: @escaping (() -> Void), completion: (() -> Void)? = nil) {
        let manager = OpalImagePickerManager.sharedInstance
        manager.select = select
        manager.cancel = cancel
        imagePicker.imagePickerDelegate = manager
        present(imagePicker, animated: animated, completion: completion)
    }
    
    
    func getImagesFrom(_ assets: [PHAsset]) -> [UIImage] {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.isSynchronous = true
        var images = [UIImage]()
        
        for asset in assets {
            manager.requestImage(for: asset,
                                 targetSize: CGSize(width: view.frame.width,
                                                    height: view.frame.height),
                                 contentMode: .aspectFit,
                                 options: option,
                                 resultHandler: { (result, info) -> Void in
                                    
                                    if let result = result {
                                        images.append(result)
                                    }
            })
        }
        
        return images
    }
}

final class OpalImagePickerManager: NSObject {
    var select: (([PHAsset]) -> Void)?
    var cancel: (() -> Void)?
    
    static let sharedInstance = OpalImagePickerManager()
    fileprivate override init() { }
}

extension OpalImagePickerManager: GalleryImagePickerControllerDelegate {
    func imagePicker(_ picker: GalleryImagePickerController, didFinishPickingAssets assets: [PHAsset]) {
        select?(assets)
    }
    
    func imagePickerDidCancel(_ picker: GalleryImagePickerController) {
        cancel?()
    }
}



class ImagePickerCollectionViewCell: UICollectionViewCell {
    
    static let reuseId = String(describing: ImagePickerCollectionViewCell.self)
    
    var photoAsset: PHAsset? {
        didSet {
            loadIfNeeded()
        }
    }
    
    var size: CGSize? {
        didSet {
            loadIfNeeded()
        }
    }
    
    var selectionTintColor: UIColor = UIColor.black.withAlphaComponent(0.8) {
        didSet {
            overlayView?.backgroundColor = selectionTintColor
        }
    }
    
    var selectionImageTintColor: UIColor = .clear {
        didSet {
            overlayImageView?.tintColor = selectionImageTintColor
        }
    }
    
    var selectionImage: UIImage? {
        didSet {
            overlayImageView?.image = selectionImage?.withRenderingMode(.alwaysTemplate)
        }
    }
    
    override var isSelected: Bool {
        set {
            setSelected(newValue, animated: true)
        }
        get {
            return super.isSelected
        }
    }
    
    func setSelected(_ isSelected: Bool, animated: Bool) {
        super.isSelected = isSelected
        updateSelected(animated)
    }
    
    weak var imageView: UIImageView?
    weak var activityIndicator: UIActivityIndicatorView?
    
    weak var overlayView: UIView?
    weak var overlayImageView: UIImageView?
    
    fileprivate var imageRequestID: PHImageRequestID?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .lightGray
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        contentView.addSubview(activityIndicator)
        self.activityIndicator = activityIndicator
        
        let imageView = UIImageView(frame: frame)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        self.imageView = imageView
        
        if #available(iOS 9.0, *) {
            NSLayoutConstraint.activate([
                contentView.leftAnchor.constraint(equalTo: imageView.leftAnchor),
                contentView.rightAnchor.constraint(equalTo: imageView.rightAnchor),
                contentView.topAnchor.constraint(equalTo: imageView.topAnchor),
                contentView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
                contentView.centerXAnchor.constraint(equalTo: activityIndicator.centerXAnchor),
                contentView.centerYAnchor.constraint(equalTo: activityIndicator.centerYAnchor)
                ])
        } else {
            // Fallback on earlier versions
            
            contentView.addConstraintsWithFormat("H:|[v0]|", views: imageView)
            contentView.addConstraintsWithFormat("V:|[v0]|", views: imageView)
            
            
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            let views = ["contentView": contentView, "activityIndicator": activityIndicator]
            let visualFormat = ":[contentView]-(<=1)-[activityIndicator(30)]"
            
            /// Center horisontally
            let horizontalConstraint = NSLayoutConstraint.constraints(
                withVisualFormat: "V" + visualFormat,
                options: .alignAllCenterX,
                metrics: nil,
                views: views)
            
            contentView.addConstraints(horizontalConstraint)
            
            /// Center vertically
            let verticalConstraints = NSLayoutConstraint.constraints(
                withVisualFormat: "H" + visualFormat,
                options: .alignAllCenterY,
                metrics: nil,
                views: views)
            
            contentView.addConstraints(verticalConstraints)
        }
        
        layoutIfNeeded()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView?.image = nil
        
        //Cancel request if needed
        let manager = PHImageManager.default()
        guard let imageRequestID = self.imageRequestID else { return }
        manager.cancelImageRequest(imageRequestID)
        self.imageRequestID = nil
        
        //Remove selection
        setSelected(false, animated: false)
    }
    
    fileprivate func loadIfNeeded() {
        guard let asset = photoAsset, let size = self.size else { return }
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = false
        options.isNetworkAccessAllowed = true
        
        let manager = PHImageManager.default()
        imageRequestID = manager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options, resultHandler: { [weak self] (result, info) in
            self?.imageRequestID = nil
            guard let result = result else {
                self?.imageView?.image = nil
                return
            }
            self?.imageView?.image = result
        })
    }
    
    fileprivate func updateSelected(_ animated: Bool) {
        if isSelected {
            addOverlay(animated)
        }
        else {
            removeOverlay(animated)
        }
    }
    
    fileprivate func addOverlay(_ animated: Bool) {
        guard self.overlayView == nil && self.overlayImageView == nil else { return }
        
        let overlayView = UIView(frame: frame)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.backgroundColor = selectionTintColor
        contentView.addSubview(overlayView)
        self.overlayView = overlayView
        
        let overlayImageView = UIImageView(frame: frame)
        overlayImageView.translatesAutoresizingMaskIntoConstraints = false
        overlayImageView.contentMode = .center
        overlayImageView.image = selectionImage ?? UIImage(named: "selectReveal")
        overlayImageView.tintColor = selectionImageTintColor
        overlayImageView.alpha = 0
        contentView.addSubview(overlayImageView)
        self.overlayImageView = overlayImageView
        
        if #available(iOS 9.0, *) {
            NSLayoutConstraint.activate([
                contentView.leftAnchor.constraint(equalTo: overlayView.leftAnchor),
                contentView.rightAnchor.constraint(equalTo: overlayView.rightAnchor),
                contentView.topAnchor.constraint(equalTo: overlayView.topAnchor),
                contentView.bottomAnchor.constraint(equalTo: overlayView.bottomAnchor),
                contentView.leftAnchor.constraint(equalTo: overlayImageView.leftAnchor),
                contentView.rightAnchor.constraint(equalTo: overlayImageView.rightAnchor),
                contentView.topAnchor.constraint(equalTo: overlayImageView.topAnchor),
                contentView.bottomAnchor.constraint(equalTo: overlayImageView.bottomAnchor)
                ])
        } else {
            // Fallback on earlier versions
            
            contentView.addConstraintsWithFormat("H:|[v0]|", views: overlayView)
            contentView.addConstraintsWithFormat("V:|[v0]|", views: overlayView)
            
            contentView.addConstraintsWithFormat("H:|[v0]|", views: overlayImageView)
            contentView.addConstraintsWithFormat("V:|[v0]|", views: overlayImageView)
        }
        
        layoutIfNeeded()
        
        let duration = animated ? 0.2 : 0.0
        UIView.animate(withDuration: duration, animations: {
            overlayView.alpha = 0.7
            overlayImageView.alpha = 1
        })
    }
    
    fileprivate func removeOverlay(_ animated: Bool) {
        guard let overlayView = self.overlayView,
            let overlayImageView = self.overlayImageView else {
                self.overlayView?.removeFromSuperview()
                self.overlayImageView?.removeFromSuperview()
                return
        }
        
        let duration = animated ? 0.2 : 0.0
        UIView.animate(withDuration: duration, animations: {
            overlayView.alpha = 0
            overlayImageView.alpha = 0
        }, completion: { (_) in
            overlayView.removeFromSuperview()
            overlayImageView.removeFromSuperview()
        })
    }
}




/// Image Picker Controller Delegate. Notifies when images are selected or image picker is cancelled.
@objc protocol GalleryImagePickerControllerDelegate: class {
    
    /// Image Picker did finish picking images. Provides an array of `UIImage` selected.
    ///
    /// - Parameters:
    ///   - picker: the `OpalImagePickerController`
    ///   - images: the array of `UIImage`
    @objc optional func imagePicker(_ picker: GalleryImagePickerController, didFinishPickingImages images: [UIImage])
    
    /// Image Picker did finish picking images. Provides an array of `PHAsset` selected.
    ///
    /// - Parameters:
    ///   - picker: the `OpalImagePickerController`
    ///   - assets: the array of `PHAsset`
    @objc optional func imagePicker(_ picker: GalleryImagePickerController, didFinishPickingAssets assets: [PHAsset])
    
    /// Image Picker did cancel.
    ///
    /// - Parameter picker: the `OpalImagePickerController`
    @objc optional func imagePickerDidCancel(_ picker: GalleryImagePickerController)
}


/// Image Picker Controller. Displays images from the Photo Library. Must check Photo Library permissions before attempting to display this controller.
class GalleryImagePickerController: UINavigationController {
    
    /// Image Picker Delegate. Notifies when images are selected or image picker is cancelled.
    weak var imagePickerDelegate: GalleryImagePickerControllerDelegate? {
        didSet {
            let rootVC = viewControllers.first as? ImagePickerRootViewController
            rootVC?.delegate = imagePickerDelegate
        }
    }
    
    /// Custom Tint Color for overlay of selected images.
    var selectionTintColor: UIColor? {
        didSet {
            let rootVC = viewControllers.first as? ImagePickerRootViewController
            rootVC?.selectionTintColor = selectionTintColor
        }
    }
    
    /// Custom Tint Color for selection image (checkmark).
    var selectionImageTintColor: UIColor? {
        didSet {
            let rootVC = viewControllers.first as? ImagePickerRootViewController
            rootVC?.selectionImageTintColor = selectionImageTintColor
        }
    }
    
    /// Custom selection image (checkmark).
    var selectionImage: UIImage? {
        didSet {
            let rootVC = viewControllers.first as? ImagePickerRootViewController
            rootVC?.selectionImage = selectionImage
        }
    }
    
    /// Initializer
    required init() {
        super.init(rootViewController: ImagePickerRootViewController())
    }
    
    /// Initializer (Do not use this controller in Interface Builder)
    ///
    /// - Parameters:
    ///   - nibNameOrNil: the nib name
    ///   - nibBundleOrNil: the nib `Bundle`
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    /// Initializer (Do not use this controller in Interface Builder)
    required init?(coder aDecoder: NSCoder) {
        fatalError("Cannot init \(String(describing: GalleryImagePickerController.self)) from Interface Builder")
    }
}





/// Image Picker Root View Controller contains the logic for selecting images. The images are displayed in a `UICollectionView`, and multiple images can be selected.
class ImagePickerRootViewController: UIViewController {
    
    /// Delegate for Image Picker. Notifies when images are selected (done is tapped) or when the Image Picker is cancelled.
    weak var delegate: GalleryImagePickerControllerDelegate?
    
    /// `UICollectionView` for displaying images
    weak var collectionView: UICollectionView?
    
    /// Custom Tint Color for overlay of selected images.
    var selectionTintColor: UIColor? {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    /// Custom Tint Color for selection image (checkmark).
    var selectionImageTintColor: UIColor? {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    /// Custom selection image (checkmark).
    var selectionImage: UIImage? {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    /// Page size for paging through the Photo Assets in the Photo Library. Defaults to 100. Must override to change this value.
    let pageSize = 100
    
    var photoAssets: PHFetchResult<PHAsset> = PHFetchResult()
    weak var doneButton: UIBarButtonItem?
    weak var cancelButton: UIBarButtonItem?
    
    internal var collectionViewLayout: ImagePickerCollectionViewLayout? {
        return collectionView?.collectionViewLayout as? ImagePickerCollectionViewLayout
    }
    
    internal lazy var fetchOptions: PHFetchOptions = {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return fetchOptions
    }()
    
    internal var fetchLimit: Int {
        get {
            if #available(iOS 9.0, *) {
                return fetchOptions.fetchLimit
            } else {
                // Fallback on earlier versions
                
                return 5
            }
        }
        set {
            if #available(iOS 9.0, *) {
                fetchOptions.fetchLimit = newValue
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    fileprivate var photosCompleted = 0
    fileprivate var savedImages: [UIImage] = []
    
    /// Initializer
    required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    /// Initializer (Do not use this View Controller in Interface Builder)
    required init?(coder aDecoder: NSCoder) {
        fatalError("Cannot init \(String(describing: ImagePickerRootViewController.self)) from Interface Builder")
    }
    
    fileprivate func setup() {
        requestPhotoAccessIfNeeded(PHPhotoLibrary.authorizationStatus())
        if #available(iOS 9.0, *) {
            fetchOptions.fetchLimit = pageSize
        } else {
            // Fallback on earlier versions
        }
        photoAssets = PHAsset.fetchAssets(with: fetchOptions)
        
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: ImagePickerCollectionViewLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.allowsMultipleSelection = true
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ImagePickerCollectionViewCell.self, forCellWithReuseIdentifier: ImagePickerCollectionViewCell.reuseId)
        view.addSubview(collectionView)
        self.collectionView = collectionView
        
        if #available(iOS 9.0, *) {
            NSLayoutConstraint.activate([
                view.leftAnchor.constraint(equalTo: collectionView.leftAnchor),
                view.rightAnchor.constraint(equalTo: collectionView.rightAnchor),
                view.topAnchor.constraint(equalTo: collectionView.topAnchor),
                view.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor)
                ])
        } else {
            // Fallback on earlier versions
            
            view.addConstraintsWithFormat("H:|[v0]|", views: collectionView)
            view.addConstraintsWithFormat("V:|[v0]|", views: collectionView)
        }
        view.layoutIfNeeded()
    }
    
    
    /// Load View
    override func loadView() {
        view = UIView()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
        navigationItem.title = NSLocalizedString("Photos", comment: "")
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        navigationItem.leftBarButtonItem = cancelButton
        self.cancelButton = cancelButton
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        doneButton.isEnabled = false
        navigationItem.rightBarButtonItem = doneButton
        self.doneButton = doneButton
    }
    
    func cancelTapped() {
        dismiss(animated: true) { [weak self] in
            guard let imagePicker = self?.navigationController as? GalleryImagePickerController else { return }
            self?.delegate?.imagePickerDidCancel?(imagePicker)
        }
    }
    
    func doneTapped() {
        guard let imagePicker = navigationController as? GalleryImagePickerController,
            let collectionViewLayout = collectionView?.collectionViewLayout as? ImagePickerCollectionViewLayout else { return }
        let indexPathsForSelectedItems = collectionView?.indexPathsForSelectedItems ?? []
        
        var photoAssets: [PHAsset] = []
        for indexPath in indexPathsForSelectedItems {
            guard indexPath.item < self.photoAssets.count else { continue }
            photoAssets += [self.photoAssets.object(at: indexPath.item)]
        }
        
        
        delegate?.imagePicker?(imagePicker, didFinishPickingAssets: photoAssets)
        
        //Skip next step for optimization if `imagePicker:didFinishPickingAssets:` isn't implemented on delegate
        if let nsDelegate = delegate as? NSObject,
            !nsDelegate.responds(to: #selector(GalleryImagePickerControllerDelegate.imagePicker(_:didFinishPickingImages:))) {
            return
        }
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = false
        options.isNetworkAccessAllowed = true
        
        photosCompleted = 0
        for photoAsset in photoAssets {
            let size = CGSize(width: collectionViewLayout.sizeOfItem * 3, height: collectionViewLayout.sizeOfItem * 3)
            PHImageManager.default().requestImage(for: photoAsset, targetSize: size, contentMode: .aspectFill, options: options, resultHandler: { [weak self] (result, info) in
                guard let strongSelf = self else { return }
                if let image = result {
                    strongSelf.savedImages += [image]
                }
                
                strongSelf.photosCompleted += 1
                if strongSelf.photosCompleted == photoAssets.count {
                    strongSelf.delegate?.imagePicker?(imagePicker, didFinishPickingImages: strongSelf.savedImages)
                    strongSelf.savedImages = []
                }
            })
        }
    }
    
    fileprivate func updateDoneButton() {
        guard let indexPathsForSelectedItems = collectionView?.indexPathsForSelectedItems else {
            doneButton?.isEnabled = false
            return
        }
        doneButton?.isEnabled = indexPathsForSelectedItems.count > 0
    }
    
    fileprivate func fetchNextPageIfNeeded(indexPath: IndexPath) {
        guard indexPath.item == fetchLimit-1 else { return }
        
        let oldFetchLimit = fetchLimit
        fetchLimit += pageSize
        photoAssets = PHAsset.fetchAssets(with: fetchOptions)
        
        var indexPaths: [IndexPath] = []
        for i in oldFetchLimit..<photoAssets.count {
            indexPaths += [IndexPath(item: i, section: 0)]
        }
        collectionView?.insertItems(at: indexPaths)
    }
    
    fileprivate func requestPhotoAccessIfNeeded(_ status: PHAuthorizationStatus) {
        guard status == .notDetermined else { return }
        PHPhotoLibrary.requestAuthorization { [weak self] (authorizationStatus) in
            DispatchQueue.main.async { [weak self] in
                self?.photoAssets = PHAsset.fetchAssets(with: self?.fetchOptions)
                self?.collectionView?.reloadData()
            }
        }
    }
}

//MARK: - Collection View Delegate

extension ImagePickerRootViewController: UICollectionViewDelegate {
    
    
    /// Collection View did select item at `IndexPath`
    ///
    /// - Parameters:
    ///   - collectionView: the `UICollectionView`
    ///   - indexPath: the `IndexPath`
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        updateDoneButton()
    }
    
    
    /// Collection View did de-select item at `IndexPath`
    ///
    /// - Parameters:
    ///   - collectionView: the `UICollectionView`
    ///   - indexPath: the `IndexPath`
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        updateDoneButton()
    }
}

//MARK: - Collection View Data Source

extension ImagePickerRootViewController: UICollectionViewDataSource {
    
    
    /// Returns Collection View Cell for item at `IndexPath1
    ///
    /// - Parameters:
    ///   - collectionView: the `UICollectionView`
    ///   - indexPath: the `IndexPath`
    /// - Returns: Returns the `UICollectionViewCell`
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fetchNextPageIfNeeded(indexPath: indexPath)
        
        guard let layoutAttributes = collectionViewLayout?.layoutAttributesForItem(at: indexPath),
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImagePickerCollectionViewCell.reuseId, for: indexPath) as? ImagePickerCollectionViewCell else { return UICollectionViewCell() }
        let photoAsset = photoAssets.object(at: indexPath.item)
        cell.photoAsset = photoAsset
        cell.size = layoutAttributes.frame.size
        
        if let selectionTintColor = self.selectionTintColor {
            cell.selectionTintColor = selectionTintColor
        }
        if let selectionImageTintColor = self.selectionImageTintColor {
            cell.selectionImageTintColor = selectionImageTintColor
        }
        if let selectionImage = self.selectionImage {
            cell.selectionImage = selectionImage
        }
        
        return cell
    }
    
    
    /// Returns the number of items in a given section
    ///
    /// - Parameters:
    ///   - collectionView: the `UICollectionView`
    ///   - section: the given section of the `UICollectionView`
    /// - Returns: Returns an `Int` for the number of rows.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoAssets.count
    }
}




/// Collection View Layout that evenly lays out the images in the Image Picker.
class ImagePickerCollectionViewLayout: UICollectionViewLayout {
    
    
    /// Estimated Image Size. Used as a minimum image size to determine how many images should be go across to cover the width. You can override for different display preferences. Assumed to be greater than 0.
    var estimatedImageSize: CGFloat {
        guard let collectionView = self.collectionView else { return 80 }
        return collectionView.traitCollection.horizontalSizeClass == .regular ? 160 : 80
    }
    
    var sizeOfItem: CGFloat = 0
    fileprivate var cellLayoutInfo: [IndexPath:UICollectionViewLayoutAttributes] = [:]
    
    
    /// Prepare for Collection View Update
    ///
    /// - Parameter updateItems: Items to update
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        updateItemSizes()
    }
    
    
    /// Prepare the layout
    override func prepare() {
        updateItemSizes()
    }
    
    
    /// Returns `Bool` telling should invalidate layout
    ///
    /// - Parameter newBounds: the new bounds
    /// - Returns: Returns a `Bool` telling should invalidate layout
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    
    /// Returns layout attributes for indexPath
    ///
    /// - Parameter indexPath: the `IndexPath`
    /// - Returns: Returns layout attributes
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cellLayoutInfo[indexPath]
    }
    
    
    /// Returns a list of layout attributes for items in rect
    ///
    /// - Parameter rect: the Rect
    /// - Returns: Returns a list of layout attributes
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = self.collectionView else { return nil }
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        return cellLayoutInfo.filter { (indexPath, layoutAttribute) -> Bool in
            return layoutAttribute.frame.intersects(rect) && indexPath.item < numberOfItems
            }.map { $0.value }
    }
    
    
    /// Collection View Content Size
    override var collectionViewContentSize: CGSize {
        guard let collectionView = self.collectionView else { return CGSize.zero }
        let numberOfItemsAcross = Int(collectionView.bounds.width/estimatedImageSize)
        
        guard numberOfItemsAcross > 0 else { return CGSize.zero }
        let widthOfItem = collectionView.bounds.width/CGFloat(numberOfItemsAcross)
        sizeOfItem = widthOfItem
        
        var totalNumberOfItems = 0
        for section in 0..<collectionView.numberOfSections {
            totalNumberOfItems += collectionView.numberOfItems(inSection: section)
        }
        
        let numberOfRows = Int(ceilf(Float(totalNumberOfItems)/Float(numberOfItemsAcross)))
        var size = collectionView.frame.size
        size.height = CGFloat(numberOfRows) * widthOfItem
        return size
    }
    
    fileprivate func updateItemSizes() {
        guard let collectionView = self.collectionView else { return }
        let numberOfItemsAcross = Int(collectionView.bounds.width/estimatedImageSize)
        
        guard numberOfItemsAcross > 0 else { return }
        let widthOfItem = collectionView.bounds.width/CGFloat(numberOfItemsAcross)
        sizeOfItem = widthOfItem
        
        cellLayoutInfo = [:]
        
        var yPosition: CGFloat = 0
        
        for section in 0..<collectionView.numberOfSections {
            for item in 0..<collectionView.numberOfItems(inSection: section) {
                let indexPath = IndexPath(item: item, section: section)
                let layoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                let column = item % numberOfItemsAcross
                
                let xPosition = CGFloat(column) * widthOfItem
                layoutAttributes.frame = CGRect(x: xPosition, y: yPosition, width: widthOfItem, height: widthOfItem)
                cellLayoutInfo[indexPath] = layoutAttributes
                
                //When at the end of row increment y position.
                if column == numberOfItemsAcross-1 {
                    yPosition += widthOfItem
                }
            }
        }
    }
}
