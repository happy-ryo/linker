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
    
    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if  let _ = self.tableView.indexPathForSelectedRow {
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
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
        let alert = UIAlertController(title: "linker", message: "ネットワークエラーです、時間をおいて再度お試しください", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {[unowned self] (action:UIAlertAction) in
            self.registration()
            }))
        self.present(alert, animated: true, completion: nil)
    }
}
