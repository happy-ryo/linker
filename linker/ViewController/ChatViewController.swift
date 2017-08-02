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
    
    fileprivate var isObserving = false
    fileprivate let defaultHeight:CGFloat = 30.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        timeLineRepository = TimeLineRepository(category: CategoryRepository(id: "hoge", name: "hoge"))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !isObserving {
            let notification = NotificationCenter.default
            notification.addObserver(self, selector:#selector(DetailViewController.keyboardWillShow(_:)) , name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            notification.addObserver(self, selector: #selector(DetailViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
            isObserving = true
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isObserving {
            let notification = NotificationCenter.default
            notification.removeObserver(self)
            notification.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            notification.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
    
    func keyboardWillShow(_ notification: Notification?) {
        if let notification = notification ,
            let userInfo = notification.userInfo,
            let frameEndUserInfoKey = userInfo[UIKeyboardFrameEndUserInfoKey],
            let durationUserInfoKey = userInfo[UIKeyboardAnimationDurationUserInfoKey]{
            let rect = (frameEndUserInfoKey as AnyObject).cgRectValue
            let duration = (durationUserInfoKey as AnyObject).doubleValue
            UIView.animate(withDuration: duration!, animations: {
                let transform = CGAffineTransform(translationX: 0, y: -(rect?.size.height)!)
                self.view.transform = transform
                }, completion: nil)
        }
    }
    
    func keyboardWillHide(_ notification: Notification?) {
        let duration = (notification?.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double)
        UIView.animate(withDuration: duration, animations:{
            self.view.transform = CGAffineTransform.identity
            },
                                   completion:nil)
    }
}
