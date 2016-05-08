//
//  DetailViewController.swift
//  linker
//
//  Created by happy_ryo on 2016/05/02.
//  Copyright © 2016年 Citron Syrup. All rights reserved.
//

import UIKit
import AMScrollingNavbar

class DetailViewController: ScrollingNavigationViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var postView: UIView!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!

    private var isObserving = false
    private let defaultHeight: CGFloat = 34.0
    
    var postWindow: UIWindow?
    var mainWindow: UIWindow?
    var timeLineRepository: TimeLineRepository? {
        didSet {
            self.configureView()
        }
    }

    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
//        if let detail = self.detailItem {
//        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        timeLineRepository = TimeLineRepository(category: CategoryRepository(id: "hoge", name: "hoge"))
    }

    override func viewWillAppear(animated: Bool) {
        if let tableView = self.tableView {
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 80
            self.scrollViewShouldScrollToTop(tableView)
        }
        if !isObserving {
            let notification = NSNotificationCenter.defaultCenter()
            notification.addObserver(self, selector: #selector(DetailViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
            notification.addObserver(self, selector: #selector(DetailViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
            isObserving = true
        }

        self.followScrollView()

        if let timeLineRepository = self.timeLineRepository {
            timeLineRepository.retrieveContents({ [unowned self](content) in
                let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
            })
        }
        self.postButton.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(DetailViewController.openPostView)))
    }

    override func viewDidAppear(animated: Bool) {
        if let navigationController = self.navigationController as? ScrollingNavigationController {
            navigationController.setNavigationBarHidden(true, animated: true)
        }
    }

    func followScrollView() {
        if let navigationController = self.navigationController as? ScrollingNavigationController {
            navigationController.followScrollView(self.tableView, delay: 10)
        }
    }

    func unFollowScrollView() {
        if let navigationController = self.navigationController as? ScrollingNavigationController {
            navigationController.stopFollowingScrollView()
        }
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
        
        if let timeLineRepository = self.timeLineRepository {
            timeLineRepository.endRetrieveContents()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func postContent() {
        self.post(self.textView)
        self.textViewHeight.constant = defaultHeight
    }
    
    func post(textView:UITextView) {
        if textView.text.characters.count == 0 {
            return
        }
        if let timeLineRepository = self.timeLineRepository {
            timeLineRepository.post(ContentRepository(userRepository: UserRepository(), text: textView.text))
            textView.text = ""
        }
        textView.resignFirstResponder()
    }

    func keyboardWillShow(notification: NSNotification?) {
        if let postWindow = self.postWindow {
            return
        }
        if let notification = notification,
            let userInfo = notification.userInfo,
            let frameEndUserInfoKey = userInfo[UIKeyboardFrameEndUserInfoKey],
            let durationUserInfoKey = userInfo[UIKeyboardAnimationDurationUserInfoKey] {
                let rect = frameEndUserInfoKey.CGRectValue()
                let duration = durationUserInfoKey.doubleValue
                UIView.animateWithDuration(duration, animations: {
                    let transform = CGAffineTransformMakeTranslation(0, -rect.size.height)
                    self.postView.transform = transform
                    }, completion: { [unowned self](flg: Bool) in
                    self.unFollowScrollView()
                })
        }
    }

    func keyboardWillHide(notification: NSNotification?) {
        let duration = (notification?.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double)
        UIView.animateWithDuration(duration, animations: {
            self.postView.transform = CGAffineTransformIdentity
            }, completion: { [unowned self](flg: Bool) in
            self.followScrollView()
        })
    }

    @IBAction func back() {
        self.splitViewController?.performSelector((self.splitViewController?.displayModeButtonItem().action)!)
        self.splitViewController?.popoverPresentationController
    }
}

extension DetailViewController: UITextViewDelegate {
    func textViewDidChange(textView: UITextView) {
        let maxHeight: CGFloat = 90.0
        let size = self.textView.sizeThatFits(self.textView.frame.size)
        if size.height < maxHeight {
            self.textViewHeight.constant = size.height
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

extension DetailViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let timeLineRepository = timeLineRepository else {
            return 0
        }
        return timeLineRepository.contents.count
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

extension DetailViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NonImageCell", forIndexPath: indexPath) as! DetailViewCell
        cell.loadContent((timeLineRepository?.contents[indexPath.row])!)
        cell.layoutMargins = UIEdgeInsetsZero
        return cell
    }
}

extension DetailViewController {
    func openPostView() {
        if postWindow != nil {
            return
        }
        self.textView.resignFirstResponder()
        mainWindow = UIApplication.sharedApplication().keyWindow
        let rect = UIScreen.mainScreen().bounds
        let window = UIWindow(frame: rect)
        window.windowLevel = UIWindowLevelNormal + 5.0
        let postViewController = PostViewController(nibName: "PostView", bundle: nil)
        window.rootViewController = postViewController
        postWindow = window
        window.makeKeyAndVisible()
        postViewController.closeButton.target = self
        postViewController.closeButton.action = #selector(DetailViewController.closePostView)
        postViewController.postButton.target = self
        postViewController.postButton.action = #selector(DetailViewController.postContentFromPostView)
        postViewController.timeLineRepository = self.timeLineRepository
        postViewController.textView.becomeFirstResponder()
    }
    
    func postContentFromPostView() {
        let controller = postWindow?.rootViewController as! PostViewController
        self.post(controller.textView)
        self.closePostView()
    }
    
    func closePostView() {
        mainWindow?.makeKeyAndVisible()
        postWindow = nil
    }
}