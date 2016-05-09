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

    var timeLineRepository: TimeLineRepository?

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

        PHImageManager.defaultManager().requestImageDataForAsset(asset, options: nil) { (data: NSData?, uti: String?, UIImageOrientation, info: [NSObject: AnyObject]?) in
            let fileUrl: NSURL = info!["PHImageFileURLKey"] as! NSURL
            self.uploadToS3(fileUrl)
        }

    }

    func uploadToS3(fileUrl: NSURL) {
        let syncClient = AWSCognito.defaultCognito()
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()

        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest.bucket = "linker-product"
        uploadRequest.key = "\(self.randomStringWithLength(30)).jpeg"
        uploadRequest.body = fileUrl
        uploadRequest.ACL = .PublicRead

        transferManager.upload(uploadRequest).continueWithBlock { (task: AWSTask) -> AnyObject? in
            if task.completed {
                print("success")
            } else {
                print("fail")
            }
            return nil
        }
    }

    func randomStringWithLength(length: Int) -> String {
        let alphabet = "-_1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let upperBound = UInt32(alphabet.characters.count)
        return String((0 ..< length).map { _ -> Character in
            return alphabet[alphabet.startIndex.advancedBy(Int(arc4random_uniform(upperBound)))]
        })
    }
}