//
//  CellTapeable.swift
//  Scanner
//
//   
//   
//

import Foundation

protocol CellTapeable: class {
    func didSelectItemAt(_ indexPath: IndexPath, application: App?)
}
