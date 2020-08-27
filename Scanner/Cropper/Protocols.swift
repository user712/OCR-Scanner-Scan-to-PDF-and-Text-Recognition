//
//  CornerpointClientProtocol.swift
//  CropImg
//

//  This protocol is used to notify a CornerpointView's delegate when the user drags a cornerpoint.
//  The CroppableImageView sets itself up as the delegate of each of the CornerpointView objects.


import Foundation

@objc protocol CornerpointClientProtocol
{
  func cornerHasChanged(_: CornerpointView)
}

protocol CroppableImageViewDelegateProtocol
{
    func haveValidCropRect(_: Bool)
    func imageSizeSetted(size: CGSize?)
    func cornerHasChanged()
}
