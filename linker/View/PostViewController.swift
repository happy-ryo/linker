//
//  PostView.swift
//  linker
//
//  Created by happy_ryo on 2016/05/06.
//  Copyright © 2016年 Citron Syrup. All rights reserved.
//

import Foundation
import UIKit

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
        }else {
            postButton.enabled = true
        }
        countButton.title = "\(count)"
    }
}