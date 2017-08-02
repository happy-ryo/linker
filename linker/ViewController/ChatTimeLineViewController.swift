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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let timeLineRepository = self.timeLineRepository else {
            return 0
        }
        return timeLineRepository.contents.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if let timeLineRepository = self.timeLineRepository {
            cell.textLabel?.text = timeLineRepository.contents[indexPath.row].text
        }
        return cell
    }
}

extension ChatTimeLineViewController {
    override func willMove(toParentViewController parent: UIViewController?) {
        let viewController = parent as! ChatViewController
        if let timeLineRepository = viewController.timeLineRepository {
            self.timeLineRepository = timeLineRepository
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 80.0
        if let timeLineRepository = self.timeLineRepository {
            timeLineRepository.retrieveContents({[unowned self] (content) in
                let indexPath = IndexPath(row: 0, section: 0)
                self.tableView.insertRows(at: [indexPath], with: .automatic)
                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let timeLineRepository = self.timeLineRepository {
            timeLineRepository.endRetrieveContents()
        }
    }
}
