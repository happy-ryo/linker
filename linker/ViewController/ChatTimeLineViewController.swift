//
//  ChatTimeLineViewController.swift
//  linker
//
//  Created by happy_ryo on 2016/05/04.
//  Copyright © 2016年 Citron Syrup. All rights reserved.
//

import Foundation
import UIKit

class ChatTimeLineViewController: UITableViewController {
    var timeLineRepository: TimeLineRepository?
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let timeLineRepository = self.timeLineRepository else {
            return 0
        }
        return timeLineRepository.contents.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        if let timeLineRepository = self.timeLineRepository {
            cell.textLabel?.text = timeLineRepository.contents[indexPath.row].text
        }
        return cell
    }
}

extension ChatTimeLineViewController {
    override func willMoveToParentViewController(parent: UIViewController?) {
        let viewController = parent as! ChatViewController
        if let timeLineRepository = viewController.timeLineRepository {
            self.timeLineRepository = timeLineRepository
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 80.0
        if let timeLineRepository = self.timeLineRepository {
            timeLineRepository.retrieveContents({[unowned self] (content) in
                let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
            })
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        if let timeLineRepository = self.timeLineRepository {
            timeLineRepository.endRetrieveContents()
        }
    }
}