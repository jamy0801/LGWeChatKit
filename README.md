# LGWeChatKit
swift2.0仿微信界面，可滑动cell,自定义图片选择器,视频播放。。。
==========================
## 说明
  LGWeChatKit是我再学习swift的过程中慢慢修改的，对于很多swift的编程特性还有很多不了解的地方，所以再代码里面可能看到一些和OC类似的代码形式
  ，希望有什么不足的地方大家帮忙提出，如果你喜欢的话，请给个大大的Star吧，点下右上角就可以啦~谢谢啦~~

##QQ群
创建一个swift技术讨论群，欢迎各位大神加入交流  469492027

## note
 请在xcode7、IOS9.0以上版本上运行此程序demo，否则会有一些错误提示~~
 
## feature
* 代码基于swift2.0实现，包括很多swift的新用法，界面全部采用autolayout布局；
* 主要实现消息列表和聊天界面；
* 消息列表界面支持左右滑动，里面的内容可以定制；
* 聊天界面支持文本，语音，图片等消息，文本消息可以删除，复制等；
* 访问系统相册功能，基于新的PHoto.framework实现，界面和微信类似，增加livePhoto和video的播放功能！
* 支持地图调用；
* 使用新的Contacts.framework访问通讯录；
* 支持扫一扫的功能。
 
 ### 消息列表
 ![](https://github.com/jamy0801/LGWeChatKit/blob/master/gif/list.gif)
 
 再使用的时候，只要继承LGConversionListBaseCell就可以了。
 ```swift
  var cell = tableView.dequeueReusableCellWithIdentifier("messageListCell") as? LGConversionListCell
        if cell == nil {
            let leftButtons = [UIButton.createButton("取消关注", backGroundColor: UIColor.purpleColor())]
            let rightButtons = [UIButton.createButton("标记已读", backGroundColor: UIColor.grayColor()),UIButton.createButton("删除", backGroundColor: UIColor.redColor())]
            
            cell = LGConversionListCell(style: .Subtitle, reuseIdentifier: "messageListCell")
            cell?.delegate = self
            cell?.viewModel = updateCell()
            
            cell?.setLeftButtons(leftButtons)
            cell?.setRightButtons(rightButtons)
        }
        
        return cell!
 ```
 
 ### 系统相册访问
 基于新的photo.framework，告别繁琐的asset操作，使用起来非常的方便
 
 ![](https://github.com/jamy0801/LGWeChatKit/blob/master/gif/image.gif)
 
 获取相册流，包括自定义的文件夹
 ```swift
 func getCollectionList() {
        let albumOptions = PHFetchOptions()
        albumOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        let userAlbum = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype: .AlbumRegular, options: nil)
        
        userAlbum.enumerateObjectsUsingBlock { (collection, index, stop) -> Void in
            let coll = collection as! PHAssetCollection
            let assert = PHAsset.fetchAssetsInAssetCollection(coll, options: nil)
            if assert.count > 0 {
                let model = PHRootModel(title: coll.localizedTitle!, count: assert.count, fetchResult: assert)
                self.collections.value.append(model)
            }
        }
        
        let userCollection = PHCollectionList.fetchTopLevelUserCollectionsWithOptions(nil)
        
        userCollection.enumerateObjectsUsingBlock { (list, index, stop) -> Void in
            let list = list as! PHAssetCollection
            let assert = PHAsset.fetchAssetsInAssetCollection(list, options: nil)
            if assert.count > 0 {
                let model = PHRootModel(title: list.localizedTitle!, count: assert.count, fetchResult: assert)
                self.collections.value.append(model)
            }
        }
        
    }
 ```
 获取每一张图片，options是可选属性，可以设置图片的质量等
 ```swift
 PHImageManager.defaultManager().requestImageForAsset(collection?.fetchResult.lastObject as! PHAsset, targetSize: CGSizeMake(50, 60), contentMode: .AspectFit, options: nil) { (image, _: [NSObject : AnyObject]?) -> Void in
            if image == nil {
                return
            }
            cell?.imageView?.image = image
            self.tableView.reloadData()
        }
 ```
 
 ### 聊天界面
 支持录音播放功能~
 
  ![](https://github.com/jamy0801/LGWeChatKit/blob/master/gif/voice.gif)
 
 ### 文本输入
 支持文字粘贴复制等功能
 
  ![](https://github.com/jamy0801/LGWeChatKit/blob/master/gif/paste.gif)
  
  ```swift
 let pressIndexPath = tableView.indexPathForRowAtPoint(gestureRecognizer.locationInView(tableView))!
            tableView.selectRowAtIndexPath(pressIndexPath, animated: false, scrollPosition: .None)
            
            let menuController = UIMenuController.sharedMenuController()
            let localImageView = gestureRecognizer.view!
            
            menuController.setTargetRect(localImageView.frame, inView: localImageView.superview!)
            menuController.menuItems = [UIMenuItem(title: "复制", action: "copyAction:"), UIMenuItem(title: "转发", action: "transtionAction:"), UIMenuItem(title: "删除", action: "deleteAction:"), UIMenuItem(title: "更多", action: "moreAciton:")]
           
            menuController.setMenuVisible(true, animated: true)
 ```
 ### 获取通讯录
 使用Contacts.framework，该功能再IOS9以上可以使用！
 
 ![](https://github.com/jamy0801/LGWeChatKit/blob/master/gif/friend.gif)
 
 ```swift
 let store = CNContactStore()
        let keyToFetch = [CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName), CNContactImageDataKey, CNContactPhoneNumbersKey]
        let fetchRequest = CNContactFetchRequest(keysToFetch: keyToFetch)
        
        var contacts = [CNContact]()
        
        do {
            try store.enumerateContactsWithFetchRequest(fetchRequest, usingBlock: { (contact, stop) -> Void in
                contacts.append(contact)
            })
        } catch let error as NSError {
            print(error.localizedDescription)
        }
 ```
 
 ### 扫描
  ![](https://github.com/jamy0801/LGWeChatKit/blob/master/gif/scan.jpg)
  
  
  ## license
  MIT
 
