//
//  LGFindViewController.swift
//  LGChatViewController
//
//  Created by jamy on 10/19/15.
//  Copyright © 2015 jamy. All rights reserved.
//

import UIKit
import CoreSpotlight
import MobileCoreServices


let uniqueIdentifier = "com.jamy.wechat"
let domainIdentifier = "jamy"

class LGFindViewController: UITableViewController {
    
    var activity: NSUserActivity!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "发现"
        view.backgroundColor = UIColor.groupTableViewBackgroundColor()
        // Do any additional setup after loading the view.
        
        let activityType = String(format: "%@.%@", uniqueIdentifier, domainIdentifier)
        activity = NSUserActivity(activityType: activityType)
        activity.title = "jamy-search"
        activity.keywords = Set<String>(arrayLiteral: "微信", "jamy", "MJ")
        activity.eligibleForSearch = true
        activity.becomeCurrent()
        
        // core spotlight
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeImage as String)
        attributeSet.title = "jamy-spotlight search"
        attributeSet.contentDescription = "jamy写的仿微信界面，谢谢大家支持"
        attributeSet.keywords = ["微信", "jamy", "MJ"]
        let image = UIImage(named: "icon")
        let data = UIImagePNGRepresentation(image!)
        attributeSet.thumbnailData = data
        
        let searchItem = CSSearchableItem(uniqueIdentifier: uniqueIdentifier, domainIdentifier: domainIdentifier, attributeSet: attributeSet)
        
        CSSearchableIndex.defaultSearchableIndex().indexSearchableItems([searchItem]) { (error) -> Void in
            if error != nil {
                NSLog("search fail")
            } else {
                NSLog("search success")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        if indexPath.section == 1 && indexPath.row == 0 {
            if TARGET_OS_SIMULATOR == 1 {
                showAlterView()
                return
            } else {
                self.navigationController?.pushViewController(LGScanViewController(), animated: true)
            }
        }
    }
    
    func showAlterView() {
        let alter = UIAlertController(title: "Tip", message: "Simulator can't use this function!", preferredStyle: .Alert)
        alter.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        presentViewController(alter, animated: true, completion: nil)
    }
}
