//
//  LGFriendViewController.swift
//  LGChatViewController
//
//  Created by jamy on 10/19/15.
//  Copyright © 2015 jamy. All rights reserved.
//

import UIKit
import Contacts

class LGFriendViewController: UIViewController {

    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "通讯录"
        view.backgroundColor = UIColor.groupTableViewBackgroundColor()
        // Do any additional setup after loading the view.
        
        tableView = UITableView(frame: view.bounds, style: .Grouped)
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        viewModel = FriendViewModel()
        viewModel?.searchContact()
    }

    var viewModel: FriendViewModel? {
        didSet {
            viewModel?.friendSession.observe({ (sessionModel:[contactSessionModel]) -> Void in
                
            })
        }
    }
}


extension LGFriendViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (viewModel?.friendSession.value.count)!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let cellModel = viewModel?.friendSession.value[section]
        return (cellModel?.friends.value.count)!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "friendcell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? LGFriendListCell
        if cell == nil {
            cell = LGFriendListCell(style: .Default, reuseIdentifier: cellIdentifier)
            let leftButtons = [UIButton.createButton("修改备注", backGroundColor: UIColor.grayColor())]
            cell?.setRightButtons(leftButtons)
        }
        let cellModel =  viewModel?.friendSession.value[indexPath.section]
        let friend = cellModel?.friends.value[indexPath.row]
        
        cell?.viewModel = friend
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let cellModel =  viewModel?.friendSession.value[section]
        return cellModel?.key.value
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        var titles = [String]()
        for i in 65...90 {
            let title = NSString(format: "%c", i)
            titles.append(title as String)
        }
        return titles
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        for i in 0..<viewModel!.friendSession.value.count {
            if viewModel?.friendSession.value[i].key.value == title {
                return i
            }
        }
        return 1
    }
    
}