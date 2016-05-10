//
//  PostView.swift
//  linker
//
//  Created by happy_ryo on 2016/05/06.
//  Copyright © 2016年 Citron Syrup. All rights reserved.
//

import Foundation
import UIKit
import AWSS3
import Photos
import AWSCognito

class PostViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var textView: UITextView!

    @IBOutlet weak var accessoryView: UIToolbar!
    @IBOutlet weak var countButton: UIBarButtonItem!
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var postImage: UIImageView!

    var timeLineRepository: TimeLineRepository?
    var postImagePath: NSURL?

    override func viewWillAppear(animated: Bool) {
        textView.inputAccessoryView = accessoryView
    }
}

extension PostViewController: UITextViewDelegate {
    func textViewDidChange(textView: UITextView) {
        let count = 30 - textView.text.characters.count
        if count < 0 {
            postButton.enabled = false
        } else {
            postButton.enabled = true
        }
        countButton.title = "\(count)"
    }
}

extension PostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBAction func openPhotolibrary() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let picker = UIImagePickerController()
            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            picker.delegate = self
            self.presentViewController(picker, animated: true, completion: nil)
        }
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: AnyObject]) {
        let pickedURL: NSURL = info[UIImagePickerControllerReferenceURL] as! NSURL
        let fetchResult = PHAsset.fetchAssetsWithALAssetURLs([pickedURL], options: nil)
        let asset = fetchResult.firstObject as! PHAsset

        PHImageManager.defaultManager().requestImageDataForAsset(asset, options: nil) { [unowned self](data: NSData?, uti: String?, UIImageOrientation, info: [NSObject: AnyObject]?) in
            if let info = info {
                self.postImagePath = info["PHImageFileURLKey"] as? NSURL
            }
            picker.dismissViewControllerAnimated(true, completion: nil)
            self.textView.becomeFirstResponder()
        }

    }

}