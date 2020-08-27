//
//  PaperSizeViewController.swift
//  Scanner
//
//   on 1/26/17.
//   
//

import UIKit

class PaperSizeViewController: UITableViewController, UserDefaultable, PaperSizeable {

    // MARK: - Properties
    
    fileprivate let cellID = "SizeCell"
    
    
    // MARK: - LyfeCicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.hideEmptyCells(UIColor.rgb(red: 245, green: 245, blue: 247, alpha: 1))
        view.backgroundColor = UIColor.rgb(red: 245, green: 245, blue: 247, alpha: 1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


// MARK: - Table view data source

extension PaperSizeViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return paperSizes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        // Configure the cell...
        cell.selectionStyle = .none
        
        cell.textLabel?.text = paperSizesPixels[indexPath.row]
        cell.textLabel?.font = UIFont.textStyleFontLight(18)
        cell.textLabel?.text?.addTextSpacing(-0.6)
        cell.textLabel?.textColor = UIColor.gri
        
        if let ind = self.userDefaultsGetValue(userDefaultsPaperSizeKey) as? Int {
            if indexPath.row == ind {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }
    
        return cell
    }
}


// MARK: - Table view degelate

extension PaperSizeViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.userDefaultsSaveValue(indexPath.row, key: userDefaultsPaperSizeKey)
        tableView.reloadData()
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52.0
    }
}
