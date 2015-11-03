//
//  LGImagePickController.swift
//  LGChatViewController
//
//  Created by jamy on 10/21/15.
//  Copyright © 2015 jamy. All rights reserved.
//

import UIKit
import Photos


protocol LGImagePickControllerDelegate {
     func imagePickerController(picker: LGImagePickController, didFinishPickingImages images: [UIImage])
     func imagePickerControllerCanceled(picker: LGImagePickController)
}

class LGImagePickController: UITableViewController {

    var delegate: LGImagePickControllerDelegate?
    var viewModel: PHRootViewModel?
    var selectedInfo = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = PHRootViewModel()
        
        PHPhotoLibrary.requestAuthorization { (authorizationStatus) -> Void  in
            if authorizationStatus == .Authorized {
                self.viewModel?.getCollectionList()
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                })
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let item = UIBarButtonItem(title: "取消", style: .Plain, target: self, action: "dismissView")
        self.navigationItem.rightBarButtonItem = item
        
        selectedInfo.removeAllObjects()
    }
    
    func dismissView() {
        delegate?.imagePickerControllerCanceled(self)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func dismissViewControllerAnimated(flag: Bool, completion: (() -> Void)?) {
        super.dismissViewControllerAnimated(flag, completion: completion)

        delegate?.imagePickerController(self, didFinishPickingImages: selectedInfo.copy() as! [UIImage])
    }
    
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.viewModel?.collections.value.count)!
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("ImagePickreuseIdentifier")

        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "ImagePickreuseIdentifier")
            cell?.imageView?.contentMode = .ScaleToFill
            cell?.accessoryType = .DisclosureIndicator
        }
        let collection = viewModel?.collections.value[indexPath.row]
        PHImageManager.defaultManager().requestImageForAsset(collection?.fetchResult.lastObject as! PHAsset, targetSize: CGSizeMake(50, 60), contentMode: .AspectFit, options: nil) { (image, _: [NSObject : AnyObject]?) -> Void in
            if image == nil {
                return
            }
            cell?.imageView?.image = image
            self.tableView.reloadData()
        }

        cell?.textLabel?.text = collection?.title
        cell?.detailTextLabel?.text = String("\(collection!.count)")
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let fetchReslut = viewModel?.collections.value[indexPath.row]
        
        let gridCtrl = LGAssetGridViewController()
        gridCtrl.assetsFetchResults = fetchReslut?.fetchResult
        gridCtrl.selectedInfo = selectedInfo
        gridCtrl.title = fetchReslut?.title
        self.navigationController?.pushViewController(gridCtrl, animated: true)
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row >= viewModel?.collections.value.count {
            return 100
        } else {
            return CGFloat(75)
        }
    }
}
