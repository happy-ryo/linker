//
//  DetailViewController.swift
//  linker
//
//  Created by happy_ryo on 2016/05/02.
//  Copyright © 2016年 Citron Syrup. All rights reserved.
//

import UIKit
import AMScrollingNavbar
import AWSS3

extension UIColor {
	class func hexStr (_ hexStr: NSString, alpha: CGFloat) -> UIColor {
		let hexStr = hexStr.replacingOccurrences(of: "#", with: "")
		let scanner = Scanner(string: hexStr as String)
		var color: UInt32 = 0
		if scanner.scanHexInt32(&color) {
			let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
			let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
			let b = CGFloat(color & 0x0000FF) / 255.0
			return UIColor(red: r, green: g, blue: b, alpha: alpha)
		} else {
			print("invalid hex string")
			return UIColor.white;
		}
	}
}

class DetailViewController: ScrollingNavigationViewController {

	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var postButton: UIButton!
	@IBOutlet weak var textView: UITextView!
	@IBOutlet weak var postView: UIView!
	@IBOutlet weak var textViewHeight: NSLayoutConstraint!
	@IBOutlet weak var tableViewHeight: NSLayoutConstraint!

	fileprivate var isObserving = false
	fileprivate let defaultHeight: CGFloat = 34.0

	var scrollBarView: UIView!
	var scrollBarBaseView: UIView!

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
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.configureView()
		timeLineRepository = TimeLineRepository(category: CategoryRepository(id: "hoge", name: "hoge"))

		let scrollBaseRect = CGRect(x: UIScreen.main.bounds.size.width - 10,
			y: 0,
			width: 10,
			height: UIScreen.main.bounds.size.height)
		self.scrollBarBaseView = UIView(frame: scrollBaseRect)
		self.scrollBarBaseView.backgroundColor = UIColor.hexStr("FFFFFF", alpha: 0.5)
		self.tableView.addSubview(self.scrollBarBaseView)

		let scrollRect = CGRect(x: UIScreen.main.bounds.size.width - 10, y: 0, width: 10, height: 60)
		self.scrollBarView = UIView(frame: scrollRect)
		self.scrollBarView.backgroundColor = UIColor.hexStr("96E8D8", alpha: 1.0)
		self.tableView.addSubview(self.scrollBarView)
        
        for view in self.tableView.subviews {
            if view.isKind(of: UIImageView.self) {
                if let imageview = view as? UIImageView {
                    imageview.image = UIImage(named: "")
                }
            }
        }
	}

	override func viewWillAppear(_ animated: Bool) {
		if let tableView = self.tableView {
			tableView.rowHeight = UITableViewAutomaticDimension
			tableView.estimatedRowHeight = 120
			self.scrollViewShouldScrollToTop(tableView)
		}
        if !isObserving {
            let notification = NotificationCenter.default
            notification.addObserver(self, selector: #selector(DetailViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            notification.addObserver(self, selector: #selector(DetailViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
            isObserving = true
        }

		self.followScrollView()

		if let timeLineRepository = self.timeLineRepository {
			timeLineRepository.retrieveContents({ [unowned self](content) in
				let indexPath = IndexPath(row: 0, section: 0)
				self.tableView.insertRows(at: [indexPath], with: .automatic)
				self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)
			})
		}
		self.postButton.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(DetailViewController.openPostView)))
	}

	override func viewDidAppear(_ animated: Bool) {
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

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		if isObserving {
			let notification = NotificationCenter.default
			notification.removeObserver(self)
			notification.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
			notification.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
		if let timeLineRepository = self.timeLineRepository {
			timeLineRepository.postFromTextView(self.textView)
		}
		self.textViewHeight.constant = defaultHeight
	}

	func keyboardWillShow(_ notification: Notification?) {
		if UIApplication.shared.applicationState != UIApplicationState.active {
			return
		} else if let _ = self.postWindow {
			return
		}

		if let notification = notification,
			let userInfo = notification.userInfo,
			let frameEndUserInfoKey = userInfo[UIKeyboardFrameEndUserInfoKey],
			let durationUserInfoKey = userInfo[UIKeyboardAnimationDurationUserInfoKey] {
				let rect = (frameEndUserInfoKey as AnyObject).cgRectValue
				let duration = (durationUserInfoKey as AnyObject).doubleValue
				UIView.animate(withDuration: duration!, animations: {
					let transform = CGAffineTransform(translationX: 0, y: -(rect?.size.height)!)
					self.postView.transform = transform
					}, completion: { [unowned self](flg: Bool) in
					self.unFollowScrollView()
				})
		}
	}

	func keyboardWillHide(_ notification: Notification?) {
		if UIApplication.shared.applicationState != UIApplicationState.active {
			return
		}

		let duration = (notification?.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double)
		UIView.animate(withDuration: duration, animations: {
			self.postView.transform = CGAffineTransform.identity
			}, completion: { [unowned self](flg: Bool) in
			self.followScrollView()
		})
	}

	@IBAction func back() {
		self.splitViewController?.performSelector((self.splitViewController?.displayModeButtonItem().action)!)
		self.splitViewController?.popoverPresentationController
	}
}

extension DetailViewController {
	func scrollIndicator(_ scrollView: UIScrollView) -> UIView? {
		let lastSubView = scrollView.subviews[scrollView.subviews.endIndex - 1]
		if lastSubView.isKind(of: UIView.self) {
			return lastSubView
		}
		return nil
	}

	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let indicator = self.scrollIndicator(scrollView)
		var frame = self.scrollBarView.frame
		frame.origin.y = (indicator?.frame.origin.y)!

		var baseFrame = self.scrollBarBaseView.frame
		baseFrame.size.height = scrollView.contentSize.height
		UIView.animate(withDuration: 0.00, animations: { [unowned self] in
			self.scrollBarView.frame = frame
			self.scrollBarBaseView.frame = baseFrame
		}) 
	}
}

extension DetailViewController {
	override func prepareForSegue(_ segue: UIStoryboardSegue, sender: AnyObject?) {
		guard let identifier = segue.identifier else {
			return
		}
		if identifier == "ImageDetail" {
			let controller = segue.destination as! ImageDetailViewController
			controller.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            if let imageViewCell = sender as? ImageViewCell, imageViewCell.contentRepository != nil{
                controller.contentRepository = imageViewCell.contentRepository
            }
		}
	}
}

extension DetailViewController: UITextViewDelegate {
	func textViewDidChange(_ textView: UITextView) {
		let maxHeight: CGFloat = 90.0
		let size = self.textView.sizeThatFits(self.textView.frame.size)
		if size.height < maxHeight {
			self.textViewHeight.constant = size.height
		}
		if textView.text.characters.count > 30 {
			self.postButton.isEnabled = false
		} else {
			self.postButton.isEnabled = true
		}
	}

	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		self.textView.scrollRangeToVisible(self.textView.selectedRange)
		return true
	}
}

extension DetailViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let timeLineRepository = timeLineRepository else {
			return 0
		}
		return timeLineRepository.contents.count
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
}

extension DetailViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		guard let timeLineRepository = self.timeLineRepository else {
			return UITableViewCell()
		}
		let content = timeLineRepository.contents[indexPath.row]

		var cellId = ""
		if content.isExistImage() {
			cellId = "ImageCell"
		} else {
			cellId = "NonImageCell"
		}
		let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! DetailViewCell
		cell.loadContent(content)
		cell.layoutMargins = UIEdgeInsets.zero
		return cell
	}
}

extension DetailViewController {
	func openPostView() {
		if postWindow != nil {
			return
		}
		self.textView.resignFirstResponder()
		mainWindow = UIApplication.shared.keyWindow
		let rect = UIScreen.main.bounds
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
		if let timeLineRepository = self.timeLineRepository {
			timeLineRepository.post(controller)
			self.closePostView()
		}
	}

	func closePostView() {
		mainWindow?.makeKeyAndVisible()
		postWindow = nil
	}

}
