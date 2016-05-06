//
//  PostView.swift
//  linker
//
//  Created by happy_ryo on 2016/05/06.
//  Copyright © 2016年 Citron Syrup. All rights reserved.
//

import Foundation
import UIKit

class PostView: UIView {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!

    private let textViewDefaultHeight: CGFloat = 32.0

    var timeLineRepositroy: TimeLineRepository?

    @IBAction func post() {
        if textView.text.characters.count == 0 {
            return
        }
        if let timeLineRepositroy = self.timeLineRepositroy {
            timeLineRepositroy.post(ContentRepository(userRepository: UserRepository(), text: textView.text))
            textView.text = ""
            self.textViewHeight.constant = textViewDefaultHeight
        }
    }
}

extension PostView: UITextViewDelegate {
    func textViewDidChange(textView: UITextView) {
        let maxHeight: CGFloat = 90.0
        let size = self.textView.sizeThatFits(self.textView.frame.size)
        if size.height < maxHeight {
            UIView.animateWithDuration(0, animations: { [weak self] in
                self!.textViewHeight.constant = size.height
                let frame = self!.frame
                self!.frame = CGRectMake(0, 0, frame.width, 400)
                self!.sizeToFit()
                
            })

        }

        if textView.text.characters.count > 30 {
            self.postButton.enabled = false
        } else {
            self.postButton.enabled = true
        }
    }

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        self.textView.scrollRangeToVisible(self.textView.selectedRange)
        return true
    }
}