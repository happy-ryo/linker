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
    var postImagePath: URL?

    override func viewWillAppear(_ animated: Bool) {
        textView.inputAccessoryView = accessoryView
    }
}

extension PostViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let count = 30 - textView.text.characters.count
        if count < 0 {
            postButton.isEnabled = false
        } else {
            postButton.isEnabled = true
        }
        countButton.title = "\(count)"
    }
}

extension PostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBAction func openPhotolibrary() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let picker = UIImagePickerController()
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        self.textView.becomeFirstResponder()
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String: AnyObject]?) {
        let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let fileName = "hoge.png"
        let filePath = "\(docDir)/\(fileName)"
        let png = UIImagePNGRepresentation(image)
        do {
            try FileManager.default.removeItem(atPath: filePath)
        } catch {

        }
        try! png?.write(to: URL(fileURLWithPath: filePath), options: NSData.WritingOptions.withoutOverwriting)
        self.postImagePath = URL(string: "file://\(filePath)")
        picker.dismiss(animated: true, completion: nil)
        self.postImage.image = image
        self.textView.becomeFirstResponder()
    }
}
