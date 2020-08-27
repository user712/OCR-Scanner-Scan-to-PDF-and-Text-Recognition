//
//  OCRLangsTableViewCell.swift
//  Scanner
//
//   on 2/22/17.
//   
//

import UIKit

protocol OCRLangsTableViewCellDelegate: class {
    func downloadLanguageButtonPressed(cell: OCRLangsTableViewCell, index: Int)
}

class OCRLangsTableViewCell: UITableViewCell {
    static let reuseIdentifier = "OCRLangsTableViewCell"
    
    weak var delegate: OCRLangsTableViewCellDelegate?
    
    var isDownloaded: Bool = false
    
    @IBOutlet weak var checkMarkImageView: UIImageView!{
        didSet{
            checkMarkImageView.image = checkMarkImageView.image?.withRenderingMode(.alwaysTemplate)
        }
    }
    
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var downloadButton: UIButton!{
        didSet{
            downloadButton.titleLabel?.numberOfLines = 1
            downloadButton.titleLabel?.adjustsFontSizeToFitWidth = true
            downloadButton.titleLabel?.lineBreakMode = .byClipping
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func downloadButtonAction(_ sender: UIButton) {
        delegate?.downloadLanguageButtonPressed(cell: self, index: sender.tag)
    }
    
//    // MARK: - Properties
//    
//    lazy var flagImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFit
//        imageView.clipsToBounds = true
//        
//        return imageView
//    }()
//    
//    lazy var nameLabel: UILabel = {
//        let label = createLabel(UIColor.gri, font: UIFont.textStyleFontRegular(16), spacing: -0.5)
//        label.textAlignment = .left
//        
//        return label
//    }()
//    
//    let downloadLanguagesButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitleColor(UIColor.gri, for: .normal)
//        button.titleLabel?.textAlignment = .right
//        button.contentHorizontalAlignment = .right
//        button.setTitle("Install".localized(), for: .normal)
//        button.setTitleColor(UIColor.download, for: .normal)
//        button.titleLabel?.font = UIFont.textStyleFontRegular(16)
//        button.titleLabel?.text?.addTextSpacing(-0.5)
//        
//        return button
//    }()
//    
    let downloadActivityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.hidesWhenStopped = false
        
        return activityIndicator
    }()
//
//    fileprivate lazy var separatorView: UIView = {
//        let view = UIView()
//        view.backgroundColor = UIColor.separator
//        
//        return view
//    }()
//    
//    var isDownloaded: Bool = false
    
    
    // MARK: - Initializers
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
}



// MARK: - Setup Views

extension OCRLangsTableViewCell {
    
    func setupViews() {
//        addSubview(flagImageView)
//        addSubview(separatorView)
//        addSubview(nameLabel)
//        addSubview(downloadLanguagesButton)
//        
//        addConstraintsWithFormat("H:|-17-[v0(27)]-12-[v1]-12-[v2(120)]-17-|", views: flagImageView, nameLabel, downloadLanguagesButton)
//        
//        separatorView.translatesAutoresizingMaskIntoConstraints = false
//        addConstraintsWithFormat("H:|-17-[v0]-17-|", views: separatorView)
//        addConstraintsWithFormat("V:[v0(1)]|", views: separatorView)
//        
//        addConstraintsWithFormat("V:|-17-[v0]-17-|", views: flagImageView)
//        
//        addConstraintsWithFormat("V:|-18-[v0]-15-|", views: nameLabel)
//        
//        addConstraintsWithFormat("V:|-12-[v0]-10-|", views: downloadLanguagesButton)
        
        addSubview(downloadActivityIndicator)
        downloadActivityIndicator.isHidden = true
        addConstraintsWithFormat("H:[v0(30)]-17-|", views: downloadActivityIndicator)
        addConstraintsWithFormat("V:|-13-[v0]-10-|", views: downloadActivityIndicator)
    }
}

