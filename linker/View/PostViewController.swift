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
        self.textView.becomeFirstResponder()
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String: AnyObject]?) {
        let docDir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let fileName = "hoge.png"
        let filePath = "\(docDir)/\(fileName)"
        let png = UIImagePNGRepresentation(image)
        do {
            try NSFileManager.defaultManager().removeItemAtPath(filePath)
        } catch {

        }
        try! png?.writeToFile(filePath, options: NSDataWritingOptions.DataWritingWithoutOverwriting)
        self.postImagePath = NSURL(string: "file://\(filePath)")
        picker.dismissViewControllerAnimated(true, completion: nil)
        self.postImage.image = image
        self.textView.becomeFirstResponder()
    }
}