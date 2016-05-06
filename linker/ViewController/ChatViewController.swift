//
//  ChatViewController.swift
//  linker
//
//  Created by happy_ryo on 2016/05/04.
//  Copyright © 2016年 Citron Syrup. All rights reserved.
//

import Foundation
import UIKit

class ChatViewController: UIViewController {
    var categoryRepository:CategoryRepository?
    var timeLineRepository: TimeLineRepository?
    
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    
    private var isObserving = false
    private let defaultHeight:CGFloat = 30.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        timeLineRepository = TimeLineRepository(category: CategoryRepository(id: "hoge", name: "hoge"))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()        
    }
    
    override func viewWillAppear(animated: Bool) {
        if !isObserving {
            let notification = NSNotificationCenter.defaultCenter()
            notification.addObserver(self, selector:#selector(DetailViewController.keyboardWillShow(_:)) , name: UIKeyboardWillShowNotification, object: nil)
            notification.addObserver(self, selector: #selector(DetailViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
            isObserving = true
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if isObserving {
            let notification = NSNotificationCenter.defaultCenter()
            notification.removeObserver(self)
            notification.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
            notification.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
            isObserving = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func postContent() {
        if let timeLineRepository = self.timeLineRepository {
            timeLineRepository.post(ContentRepository(userRepository: UserRepository(), text: textView.text))
            textView.text = ""
            self.textViewHeight.constant = defaultHeight
        }
        textView.resignFirstResponder()
    }
    
    func keyboardWillShow(notification: NSNotification?) {
        if let notification = notification ,
            let userInfo = notification.userInfo,
            let frameEndUserInfoKey = userInfo[UIKeyboardFrameEndUserInfoKey],
            let durationUserInfoKey = userInfo[UIKeyboardAnimationDurationUserInfoKey]{
            let rect = frameEndUserInfoKey.CGRectValue()
            let duration = durationUserInfoKey.doubleValue
            UIView.animateWithDuration(duration, animations: {
                let transform = CGAffineTransformMakeTranslation(0, -rect.size.height)
                self.view.transform = transform
                }, completion: nil)
        }
    }
    
    func keyboardWillHide(notification: NSNotification?) {
        let duration = (notification?.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double)
        UIView.animateWithDuration(duration, animations:{
            self.view.transform = CGAffineTransformIdentity
            },
                                   completion:nil)
    }
}