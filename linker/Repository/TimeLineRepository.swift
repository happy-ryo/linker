//
//  PostRepository.swift
//  linker
//
//  Created by happy_ryo on 2016/05/02.
//  Copyright © 2016年 Citron Syrup. All rights reserved.
//

import Foundation
import Firebase
import AWSS3

class TimeLineRepository: RootRepository {
    let category: CategoryRepository!
    var contents = [ContentRepository]()
    var valueHandler: FirebaseHandle?
    var chaildAddedHandler: FirebaseHandle?

    init(category: CategoryRepository) {
        self.category = category
        super.init(childPath: "chat/\(category.id)/contents")
    }

    func retrieveContents(_ completeHandler: @escaping (_ content: ContentRepository) -> Void) {
        self.myRootRef.observe(FEventType.childAdded) { [weak self](snapShot: FDataSnapshot!) in
            let valueDict = snapShot.value as! NSDictionary
            var imageURL = ""
            if let imagePath = valueDict["imagePath"] as? String {
                imageURL = imagePath
            }
            let content = ContentRepository(
                userId: valueDict["uid"] as! String,
                text: valueDict["text"] as! String,
                date: valueDict["date"] as! String,
                imagePath: imageURL)
            if let weakSelf = self {
                weakSelf.contents.insert(content, at: 0)
            }
            completeHandler(content: content)
        }
    }

    func endRetrieveContents() {
        self.myRootRef.removeAllObservers()
    }

    func post(_ content: ContentRepository) {
        self.myRootRef.childByAutoId().setValue([
            "uid": content.userId,
            "date": content.date,
            "text": content.text,
            "imagePath": content.imagePath
        ])
    }

    func uploadToS3(_ fileUrl: URL, callback: @escaping (String, Bool) -> Void) {
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()

        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest.bucket = "linker-product"
        let fileName = "\(self.randomStringWithLength(30)).jpeg"
        uploadRequest.key = fileName
        uploadRequest.body = fileUrl        
        uploadRequest.ACL = .PublicRead
        uploadRequest.contentType = "image/jpeg"
        uploadRequest.storageClass = .ReducedRedundancy
        

        transferManager.upload(uploadRequest).continueWithBlock { (task: AWSTask) -> AnyObject? in
            if task.error == nil && task.exception == nil {
                callback(fileName, true)
            } else {
                print(task)
                callback("", false)
            }
            return nil
        }
    }

    func randomStringWithLength(_ length: Int) -> String {
        let alphabet = "-_1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let upperBound = UInt32(alphabet.characters.count)
        return String((0 ..< length).map { _ -> Character in
            return alphabet[alphabet.characters.index(alphabet.startIndex, offsetBy: Int(arc4random_uniform(upperBound)))]
        })
    }

    func post(_ postViewController: PostViewController) {
        if postViewController.textView.text.characters.count == 0 {
            return
        }
        if let imagePath = postViewController.postImagePath {
            let postText = postViewController.textView.text
            self.uploadToS3(imagePath as URL, callback: { (fileName: String, flg: Bool) in
                if flg {
                    self.post(ContentRepository(userRepository: UserRepository(), text: postText!, imagePath: "https://s3-ap-northeast-1.amazonaws.com/linker-product/\(fileName)"))
                }
            })
        } else {
            self.postFromTextView(postViewController.textView)
            postViewController.textView.text = ""
            postViewController.textView.resignFirstResponder()
        }

    }

    func postFromTextView(_ textView: UITextView) {
        if textView.text.characters.count == 0 {
            return
        }
        self.post(ContentRepository(userRepository: UserRepository(), text: textView.text))
        textView.text = ""
        textView.resignFirstResponder()
    }

}
