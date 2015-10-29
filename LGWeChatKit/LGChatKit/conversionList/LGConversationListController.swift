//
//  LGMessageListController.swift
//  LGChatViewController
//
//  Created by gujianming on 15/10/8.
//  Copyright © 2015年 jamy. All rights reserved.
//

import UIKit

class LGConversationListController: UITableViewController, LGConversionListBaseCellDelegate {
    
    
    override func viewDidLoad() {
        self.tableView.rowHeight = 60.0
        self.title = "消息"
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("messageListCell") as? LGConversionListCell
        if cell == nil {
            let leftButtons = [UIButton.createButton("取消关注", backGroundColor: UIColor.purpleColor())]
            let rightButtons = [UIButton.createButton("标记已读", backGroundColor: UIColor.grayColor()),UIButton.createButton("删除", backGroundColor: UIColor.redColor())]
            
            cell = LGConversionListCell(style: .Subtitle, reuseIdentifier: "messageListCell")
            cell?.delegate = self
            cell?.loadViewModel(updateCell())
            
            cell?.setLeftButtons(leftButtons)
            cell?.setRightButtons(rightButtons)
        }
        
        return cell!
    }
    
    // just for test message
    
    let image = ["icon1", "icon2", "icon3", "icon4", "icon0"]
    let name = ["招商银行信用卡中心", "微信运动", "just for IOS", "jamy", "腾讯新闻"]
    let time = ["13:14", "23:45", "昨天", "星期五", "15/10/19"]
    let message = ["iPhone 6s 和 iPhone 6s Plus 可使用中国移动、中国联通或中国电信的网络", "如果你从 apple.com 购买 iPhone，则此 iPhone 为无合约 iPhone。你可以直接联系运营商，了解适用于 iPhone 的服务套餐。", "http://www.apple.com/cn/iphone-6s/", "你是我的眼", "do you know who I am"]
    
    func updateCell() -> LGConversionListCellModel{
        
        let viewModel = LGConversionListCellModel()
        
        viewModel.iconName.value = image[random() % 5]
        viewModel.userName.value = name[random() % 5]
        viewModel.timer.value = time[random() % 5]
        viewModel.lastMessage.value = message[random() % 5]
        
        return viewModel
    }

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        navigationController?.pushViewController(LGConversationViewController(), animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    
    // MARK: - cell delegate
    
    func didSelectedLeftButton(index: Int) {
        let actionSheet = UIAlertController(title: "取消关注", message: "确定要取消关注?", preferredStyle: .ActionSheet)
        actionSheet.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: { (alertAction) -> Void in
            
        }))
        actionSheet.addAction(UIAlertAction(title: "确定", style: .Default, handler: { (alertAction) -> Void in
            
        }))
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func didSelectedRightButton(index: Int) {
        NSLog("click")
    }
    
}
