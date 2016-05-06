//
//  PostRepository.swift
//  linker
//
//  Created by happy_ryo on 2016/05/02.
//  Copyright © 2016年 Citron Syrup. All rights reserved.
//

import Foundation
import Firebase

class TimeLineRepository: RootRepository {
	let category: CategoryRepository!
	var contents = [ContentRepository]()
	var valueHandler: FirebaseHandle?
	var chaildAddedHandler: FirebaseHandle?

	init(category: CategoryRepository) {
		self.category = category
		super.init(childPath: "chat/\(category.id)/contents")
	}

	func retrieveContents(completeHandler: (content: ContentRepository) -> Void) {
		self.myRootRef.observeEventType(FEventType.ChildAdded) { [weak self](snapShot: FDataSnapshot!) in
			let content = ContentRepository(
				userId: snapShot.value["uid"] as! String,
				text: snapShot.value["text"] as! String,
				date: snapShot.value["date"] as! String)
			if let weakSelf = self {
				weakSelf.contents.insert(content, atIndex: 0)
			}
			completeHandler(content: content)
		}
	}

	func endRetrieveContents() {
		self.myRootRef.removeAllObservers()
	}

	func post(content: ContentRepository) {
		self.myRootRef.childByAutoId().setValue([
			"uid": content.userId,
			"date": content.date,
			"text": content.text
		])
	}
}