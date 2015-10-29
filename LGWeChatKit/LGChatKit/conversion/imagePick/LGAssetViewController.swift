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
    var currentIndex: Int = 0
    var toolBar: LGAssetToolView!
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
        toolBar = LGAssetToolView(leftTitle: "原图", leftSelector: nil, rightSelector: "send", parent: self)
        toolBar.frame = CGRectMake(0, view.bounds.height - 50, view.bounds.width, 50)
        toolBar.backgroundColor = UIColor(hexString: "39383d")
        view.addSubview(toolBar)
        for assetModel in assetModels {
            if assetModel.select {
                toolBar.addSelectCount = 1
            }
        }
        
        collectionView.selectItemAtIndexPath(NSIndexPath(forItem: selectIndex, inSection: 0), animated: false, scrollPosition: .CenteredHorizontally)
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSizeMake(view.bounds.width - 20, view.bounds.height - 120)
        layout.scrollDirection = .Horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 20
        layout.sectionInset = UIEdgeInsetsMake(0, 10, 10, 10)
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.registerClass(LGAssetViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
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
    }
    
    func selectCurrentImage() {
       let indexPaths = collectionView.indexPathsForVisibleItems()
       let indexpath = indexPaths.first
        let cell = collectionView.cellForItemAtIndexPath(indexpath!) as! LGAssetViewCell
        let asset = assetModels[(indexpath?.row)!]
        if asset.select {
            asset.select = false
            toolBar.addSelectCount = -1
            selectedInfo?.removeObject(cell.imageView.image!)
            selectButton.setImage(UIImage(named: "CellGreySelected"), forState: .Normal)
        } else {
            asset.select = true
            toolBar.addSelectCount = 1
            selectedInfo?.addObject(cell.imageView.image!)
            selectButton.setImage(UIImage(named: "CellBlueSelected"), forState: .Normal)
        }
    }
    
    
    func send() {
        navigationController?.viewControllers[0].dismissViewControllerAnimated(true, completion: nil)
    }
}


extension LGAssetViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetModels.count
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! LGAssetViewCell
        
        let assetModel = assetModels[indexPath.row]
        let viewModel = LGAssetViewModel(assetMode: assetModel)
        viewModel.updateStaticImage(cellSize)
        cell.viewModel = viewModel
        
        if assetModel.select {
            selectButton.setImage(UIImage(named: "CellBlueSelected"), forState: .Normal)
        } else {
            selectButton.setImage(UIImage(named: "CellGreySelected"), forState: .Normal)
        }

        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let cell = cell as! LGAssetViewCell
        let assetModel = assetModels[indexPath.row]
        let viewModel = LGAssetViewModel(assetMode: assetModel)
        viewModel.updateStaticImage(cellSize)
        cell.viewModel = viewModel
    }
  
}

