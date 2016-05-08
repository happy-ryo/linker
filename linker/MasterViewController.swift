//
//  MasterViewController.swift
//  linker
//
//  Created by happy_ryo on 2016/05/02.
//  Copyright © 2016年 Citron Syrup. All rights reserved.
//

import UIKit
import PKHUD

class MasterViewController: UITableViewController {
    
    var detailViewController: DetailViewController? = nil
    var chatViewController: ChatViewController? = nil
    var objects = [AnyObject]()
    var userRepository: UserRepository?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        userRepository = UserRepository()
        self.registration()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if  let _ = self.tableView.indexPathForSelectedRow {
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel!.text = "カテゴリのつもり"
        return cell
    }
}

extension MasterViewController {
    func registration() {
        if let userRepository = userRepository {
            PKHUD.sharedHUD.contentView = PKHUDProgressView()
            PKHUD.sharedHUD.show()
            userRepository.registration({
                PKHUD.sharedHUD.hide(afterDelay: 0.3, completion: nil)
                }, failer: { (error:NSError) in
                    PKHUD.sharedHUD.hide(afterDelay: 0.3, completion: nil)
                    self.openErrorAlert()
            })
        } else {
            userRepository = UserRepository()
            self.openErrorAlert()
        }
    }
    
    func openErrorAlert() {
        let alert = UIAlertController(title: "linker", message: "ネットワークエラーです、時間をおいて再度お試しください", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: {[unowned self] (action:UIAlertAction) in
            self.registration()
            }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
