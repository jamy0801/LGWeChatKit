//
//  LGAssetViewController.swift
//  LGWeChatKit
//
//  Created by jamy on 10/28/15.
//  Copyright © 2015 jamy. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "assetviewcell"
class LGAssetViewController: UIViewController {
    
    var collectionView: UICollectionView!
    var currentIndex: NSIndexPath!
    var selectButton: UIButton!
    var cellSize: CGSize!
    
    var assetModels = [LGAssetModel]()
    var selectedInfo: NSMutableArray?
    var selectIndex = 0
    
    lazy var imageManager: PHCachingImageManager = {
        return PHCachingImageManager()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        cellSize = (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        collectionView.selectItemAtIndexPath(NSIndexPath(forItem: selectIndex, inSection: 0), animated: false, scrollPosition: .CenteredHorizontally)
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSizeMake(view.bounds.width, view.bounds.height - 64)
        layout.scrollDirection = .Horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.registerClass(LGAssetViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.pagingEnabled = true
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setupNavgationBar()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    func setupNavgationBar() {
        let button = UIButton(type: .Custom)
        button.setImage(UIImage(named: "CellGreySelected"), forState: .Normal)
        button.frame = CGRectMake(0, 0, 30, 30)
        button.addTarget(self, action: "selectCurrentImage", forControlEvents: .TouchUpInside)
        let item = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItem = item
        selectButton = button
        
        let cancelButton = UIBarButtonItem(title: "取消", style: .Done, target: self, action: "dismissView")
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    func selectCurrentImage() {
       let indexPaths = collectionView.indexPathsForVisibleItems()
       let indexpath = indexPaths.first
        let cell = collectionView.cellForItemAtIndexPath(indexpath!) as! LGAssetViewCell
        let asset = assetModels[(indexpath?.row)!]
        if asset.select {
            asset.select = false
            selectedInfo?.removeObject(cell.imageView.image!)
            selectButton.setImage(UIImage(named: "CellGreySelected"), forState: .Normal)
        } else {
            asset.select = true
            selectedInfo?.addObject(cell.imageView.image!)
            selectButton.setImage(UIImage(named: "CellBlueSelected"), forState: .Normal)
        }
    }
    
    func dismissView() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}


extension LGAssetViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetModels.count
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! LGAssetViewCell
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "imageTapGesture:"))
        let assetModel = assetModels[indexPath.row]
        let viewModel = LGAssetViewModel(assetMode: assetModel)
        viewModel.updateStaticImage(cellSize)
        cell.viewModel = viewModel
        
        if assetModel.select {
            selectButton.setImage(UIImage(named: "CellBlueSelected"), forState: .Normal)
        } else {
            selectButton.setImage(UIImage(named: "CellGreySelected"), forState: .Normal)
        }
        currentIndex = indexPath
        self.title = "\(indexPath.row + 1)" + "/" + "\(assetModels.count)"
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let cell = cell as! LGAssetViewCell
        let assetModel = assetModels[indexPath.row]
        let viewModel = LGAssetViewModel(assetMode: assetModel)
        viewModel.updateStaticImage(cellSize)
        cell.viewModel = viewModel
        if assetModel.select {
            selectButton.setImage(UIImage(named: "CellBlueSelected"), forState: .Normal)
        } else {
            selectButton.setImage(UIImage(named: "CellGreySelected"), forState: .Normal)
        }
    }
    
    func imageTapGesture(gesture: UITapGestureRecognizer) {
        if UIApplication.sharedApplication().statusBarHidden == false {
            UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Slide)
            navigationController?.navigationBar.hidden = true
        } else {
            navigationController?.navigationBar.hidden = false
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)
        }
    }
}

