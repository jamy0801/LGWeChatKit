//  LGConversionListBaseCell.swift
//  LGChatViewController
//
//  Created by jamy on 10/19/15.
//  Copyright © 2015 jamy. All rights reserved.
//

import UIKit

public enum LGCellStatus: Int {
    case Center = 1, Left, Right
}


protocol LGConversionListBaseCellDelegate {
    func didSelectedLeftButton(index: Int)
    func didSelectedRightButton(index: Int)
}

class LGCellScrollView: UIScrollView, UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.panGestureRecognizer {
            let gesture = gestureRecognizer as! UIPanGestureRecognizer
            let translation = gesture.translationInView(gestureRecognizer.view)
            return fabs(translation.y) <= fabs(translation.x)
        } else {
            return true
        }
    }
   
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKindOfClass(UIPanGestureRecognizer.self) {
            let gesture = gestureRecognizer as! UIPanGestureRecognizer
            let velocity = gesture.velocityInView(gestureRecognizer.view).y
            
            return fabs(velocity) <= 0.20
        }
        return true
    }
    
}

@IBDesignable
class LGConversionListBaseCell: UITableViewCell {
    weak var containingTableView: UITableView! {
        willSet {
            if newValue != nil {
                removeOldTableViewPanObserver()
                tableViewpPanGesture = newValue.panGestureRecognizer
                newValue.directionalLockEnabled = true
                tapGesture.requireGestureRecognizerToFail(newValue.panGestureRecognizer)
            }
        }
        didSet {
            tapGesture.addObserver(self, forKeyPath: tableViewKeyPath, options: NSKeyValueObservingOptions(rawValue: 0), context: nil)
        }
    }
    
    override var frame: CGRect {
        willSet {
         layoutUpdating = true
         let change = self.frame.size.width != newValue.size.width
         super.frame = newValue
            if change {
                self.layoutIfNeeded()
            }
        }
        didSet {
            
            layoutUpdating = false
        }
    }
    
    var delegate: LGConversionListBaseCellDelegate?
    
    var tableViewpPanGesture: UIPanGestureRecognizer!
    var cellStatus: LGCellStatus = .Center
    var cellScrollView: LGCellScrollView!
    var containtCellView: UIView!
    
    var leftButtonView: LGButtonView!
    var rightButtonView: LGButtonView!
    var leftButtonContainView: UIView!
    var rightButtonContainView: UIView!
    
    var layoutUpdating = false
    var leftConstraint: NSLayoutConstraint!
    var rightConstraint: NSLayoutConstraint!
    
    var longPressGesture: UILongPressGestureRecognizer!
    var tapGesture: UITapGestureRecognizer!
    
    
    // MARK: - lifecycle
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        cellScrollView = LGCellScrollView()
        cellScrollView.delegate = self
        cellScrollView.scrollEnabled = true
        cellScrollView.scrollsToTop = false
        cellScrollView.showsHorizontalScrollIndicator = false
        cellScrollView.translatesAutoresizingMaskIntoConstraints = false
        containtCellView = UIView()
        cellScrollView.addSubview(containtCellView)
        containtCellView.tag = 10010
        let cellSubViews = subviews
        insertSubview(cellScrollView, atIndex: 0)
        for subView in cellSubViews {
            containtCellView.addSubview(subView)
        }
        
        addConstraints([NSLayoutConstraint(item: cellScrollView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: cellScrollView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: cellScrollView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: cellScrollView, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0)])
        
        tapGesture = UITapGestureRecognizer(target: self, action: "scrollViewTapped:")
        tapGesture.delegate = self
        tapGesture.cancelsTouchesInView = false
        cellScrollView.addGestureRecognizer(tapGesture)
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: "scrollViewPress:")
        longPressGesture.delegate = self
        longPressGesture.cancelsTouchesInView = false
        longPressGesture.minimumPressDuration = 0.15
        cellScrollView.addGestureRecognizer(longPressGesture)
        
        leftButtonContainView = UIView()
        leftButtonContainView.tag = 10030
        leftConstraint = NSLayoutConstraint(item: leftButtonContainView, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0)
        leftButtonView = LGButtonView(buttons: [UIButton](), parentCell: self, buttonSelector: Selector("leftButtonHandle:"))
    
        rightButtonContainView = UIView(frame: bounds)
        rightButtonContainView.tag = 10020
        rightConstraint = NSLayoutConstraint(item: rightButtonContainView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0)
        rightButtonView = LGButtonView(buttons: [UIButton](), parentCell: self, buttonSelector: Selector("rightButtonHandler:"))
        
        let containViews = [rightButtonContainView, leftButtonContainView]
        let containLayout = [rightConstraint, leftConstraint]
        let buttonViews = [rightButtonView, leftButtonView]
        let layoutAttributes = [NSLayoutAttribute.Right, NSLayoutAttribute.Left]
        
        for i in 0...1 {
            let clipView = containViews[i]
            let clipConstraint = containLayout[i]
            let buttonView = buttonViews[i]
            let layoutAttribute = layoutAttributes[i]
            
            clipConstraint.priority = UILayoutPriorityDefaultHigh
            clipView.translatesAutoresizingMaskIntoConstraints = false
            clipView.clipsToBounds = true
            
            cellScrollView.addSubview(clipView)
            addConstraints([NSLayoutConstraint(item: clipView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: clipView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: clipView, attribute: layoutAttribute, relatedBy: .Equal, toItem: self, attribute: layoutAttribute, multiplier: 1, constant: 0), clipConstraint])
            
            clipView.addSubview(buttonView)
            addConstraints([NSLayoutConstraint(item: buttonView, attribute: .Top, relatedBy: .Equal, toItem: clipView, attribute: .Top, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: buttonView, attribute: .Bottom, relatedBy: .Equal, toItem: clipView, attribute: .Bottom, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: buttonView, attribute: layoutAttribute, relatedBy: .Equal, toItem: clipView, attribute: layoutAttribute, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: buttonView, attribute: .Width, relatedBy: .LessThanOrEqual, toItem: self.contentView, attribute: .Width, multiplier: 1, constant: -90)])
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        cellScrollView.delegate = nil
        removeOldTableViewPanObserver()
    }
    
    // MARK: - observer
    
    let tableViewKeyPath = "state"
    
    func removeOldTableViewPanObserver() {
        if tableViewpPanGesture == nil {
            return
        }
        tableViewpPanGesture.removeObserver(self, forKeyPath: tableViewKeyPath)
    }

    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let path = keyPath {
            if path == tableViewKeyPath {
                if object === tableViewpPanGesture {
                    let locationTableView = tableViewpPanGesture.locationInView(containingTableView)
                    let currentCell = CGRectContainsPoint(self.frame, locationTableView)
                    
                    if !currentCell && cellStatus != .Center {
                        hiddenButtonsAnimated(true)
                    }
                }
            }
        }
    }
    
    func setLeftButtons(buttons: [UIButton], width: CGFloat = 90) {
        leftButtonView.setupButton(buttons, buttonWidth: width)
        leftButtonView.layoutIfNeeded()
        layoutIfNeeded()
    }
    
    func setRightButtons(buttons: [UIButton], width: CGFloat = 90) {
        rightButtonView.setupButton(buttons, buttonWidth: width)
        rightButtonView.layoutIfNeeded()
        layoutIfNeeded()
    }
    
    // MARK: - uitableView overrides
    
    override func didMoveToSuperview() {
        containingTableView = nil
        var view = self.superview
        repeat {
            if view!.isKindOfClass(UITableView.self) {
                containingTableView = view as! UITableView
                break
            }
            view = view?.superview
        } while (view != nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var frame = contentView.frame
        frame.x = leftButtonsWidth()
        contentView.frame = frame
        
        cellScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame) + totalButtonsWidth(), CGRectGetHeight(self.frame))
        
        if !cellScrollView.tracking && !cellScrollView.decelerating {
            cellScrollView.contentOffset = contentOffsetForCellStatus(cellStatus)
        }
        
        updateCellStatus()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.hiddenButtonsAnimated(true)
    }
    
    override func didTransitionToState(state: UITableViewCellStateMask) {
        super.didTransitionToState(state)
        
        if state == UITableViewCellStateMask.DefaultMask {
            layoutSubviews()
        }
    }
    
    // MARK: - selection handle
    
    func shouldHighlight() -> Bool {
        var shouldHighlight = true
        if containingTableView.delegate!.respondsToSelector("tableView:shouldHighlightRowAtIndexPath:") {
            let cellIndexPath = containingTableView.indexPathForCell(self)
            shouldHighlight = (containingTableView.delegate?.tableView!(containingTableView, shouldHighlightRowAtIndexPath: cellIndexPath!))!
        }
        
        return shouldHighlight
    }
    
    func scrollViewPress(gestureRecognizer: UIGestureRecognizer) {
        hiddenOtherCells()
        if gestureRecognizer.state == .Began && !self.highlighted && self.shouldHighlight() {
            setHighlighted(true, animated: false)
        } else if gestureRecognizer.state == .Ended {
            setHighlighted(false, animated: false)
            scrollViewTapped(gestureRecognizer)
        } else if gestureRecognizer.state == .Cancelled {
            setHighlighted(false, animated: false)
        }
    }
    
    func scrollViewTapped(gestureRecognizer: UIGestureRecognizer) {
        
        for cell in containingTableView.visibleCells {
            let newCell = cell as! LGConversionListBaseCell
            if newCell != self && newCell.isKindOfClass(LGConversionListBaseCell.self) {
                if newCell.cellStatus != .Center {
                    newCell.hiddenButtonsAnimated(true)
                    break
                }
            }
        }
        
        if cellStatus == .Center {
            if self.selected {
                deselectCell()
            } else if shouldHighlight() && !containingTableView.tracking && !containingTableView.decelerating {
                selectCell()
            }
        } else {
            hiddenButtonsAnimated(true)
        }
    }
    
    func selectCell() {
        if cellStatus == .Center {
            var cellIndexPath = containingTableView.indexPathForCell(self)
            if containingTableView.delegate!.respondsToSelector("tableView:willSelectRowAtIndexPath:") {
                cellIndexPath = containingTableView.delegate?.tableView!(containingTableView, willSelectRowAtIndexPath: cellIndexPath!)
            }
            if cellIndexPath != nil {
                containingTableView.selectRowAtIndexPath(cellIndexPath, animated: false, scrollPosition: .None)
                if containingTableView.delegate!.respondsToSelector("tableView:didSelectRowAtIndexPath:") {
                    containingTableView.delegate?.tableView!(containingTableView, didSelectRowAtIndexPath: cellIndexPath!)
                }
            }
        }
    }
    
    func deselectCell() {
        if cellStatus == .Center {
            var cellIndexPath = containingTableView.indexPathForCell(self)
            if containingTableView.delegate!.respondsToSelector("tableView:willDeselectRowAtIndexPath:") {
                cellIndexPath = containingTableView.delegate?.tableView!(containingTableView, willDeselectRowAtIndexPath: cellIndexPath!)
            }
            
            if cellIndexPath != nil {
                containingTableView.deselectRowAtIndexPath(cellIndexPath!, animated: false)
                
                if containingTableView.delegate!.respondsToSelector("tableView:didDeselectRowAtIndexPath:") {
                    containingTableView.delegate?.tableView!(containingTableView, didDeselectRowAtIndexPath: cellIndexPath!)
                }
            }
        }
    }
    
    // MARK: - buttons handling
    func rightButtonHandler(gestureRecognizer: LGButtonTapGestureRecognizer) {
        delegate?.didSelectedRightButton(gestureRecognizer.buttonIndex)
        hiddenButtonsAnimated(true)
    }
    
    func leftButtonHandle(gestureRecognizer: LGButtonTapGestureRecognizer) {
        delegate?.didSelectedLeftButton(gestureRecognizer.buttonIndex)
        hiddenButtonsAnimated(true)
    }
    
    func hiddenButtonsAnimated(animated: Bool) {
        if cellStatus != .Center {
            cellScrollView.setContentOffset(contentOffsetForCellStatus(.Center), animated: animated)
        }
    }
    
    func showLeftButtonsAnimated(animated: Bool) {
        if cellStatus != .Left {
            cellScrollView.setContentOffset(contentOffsetForCellStatus(.Left), animated: animated)
        }
    }
    
    
    func showRightButtonsAnimated(animated: Bool) {
        if cellStatus != .Right {
            cellScrollView.setContentOffset(contentOffsetForCellStatus(.Right), animated: animated)
        }
    }
    
    
    func hiddenOtherCells() {
            for cell in containingTableView.visibleCells {
                let newCell = cell as! LGConversionListBaseCell
                if newCell != self && newCell.isKindOfClass(LGConversionListBaseCell.self) {
                    newCell.hiddenButtonsAnimated(true)
                }
        }
    }
    
    func isButtonsHidden() -> Bool {
        return cellStatus == .Center
    }
    
    // MARK: - help
    
    func leftButtonsWidth() -> CGFloat {
        return round(CGRectGetWidth(leftButtonView.frame))
    }
    
    func rightButtonsWidth() -> CGFloat {
        return round(CGRectGetWidth(rightButtonView.frame))
    }
    
    func totalButtonsWidth() -> CGFloat {
        return round(leftButtonsWidth() + rightButtonsWidth())
    }
    
    func contentOffsetForCellStatus(status: LGCellStatus) -> CGPoint {
        var tempPoint = CGPointZero
        
        switch status {
        case .Center:
            tempPoint.x = leftButtonsWidth()
        case .Right:
            tempPoint.x = totalButtonsWidth()
        case .Left:
            tempPoint.x = 0
        }
        return tempPoint
    }
    
    
    func updateCellStatus() {
        if layoutUpdating {
            return
        }
        
        for newStatus in [LGCellStatus.Center, LGCellStatus.Left, LGCellStatus.Right] {
            if CGPointEqualToPoint(cellScrollView.contentOffset, contentOffsetForCellStatus(newStatus)) {
                cellStatus = newStatus
                break
            }
        }
        
        var frame = contentView.superview?.convertRect(contentView.frame, toView: self)
        frame?.width = CGRectGetWidth(self.frame)
        
        leftConstraint.constant = max(0, CGRectGetMinX(frame!) - CGRectGetMinX(self.frame))
        rightConstraint.constant = min(0, CGRectGetMaxX(frame!) - CGRectGetMaxX(self.frame))
        
        if self.editing {
            leftConstraint.constant = 0
            cellScrollView.contentOffset = CGPointMake(leftButtonsWidth(), 0)
            cellStatus = .Center
        }
        
        leftButtonContainView.hidden = (leftConstraint.constant == 0)
        rightButtonContainView.hidden = (rightConstraint.constant == 0)
        
        if self.accessoryType != .None && !self.editing {
            let accesory = cellScrollView.superview?.subviews.last
            var accessoryFrame = accesory?.frame
            accessoryFrame?.x = CGRectGetWidth(frame!) - CGRectGetWidth(accessoryFrame!) - CGFloat(15) + CGRectGetMinX(frame!)
            accesory?.frame = accessoryFrame!
        }
        
        if !cellScrollView.dragging && !cellScrollView.decelerating {
            tapGesture.enabled = true
            longPressGesture.enabled = (cellStatus == .Center)
        } else {
            tapGesture.enabled = false
            longPressGesture.enabled = false
        }
        cellScrollView.scrollEnabled = !self.editing
    }
    
}

extension LGConversionListBaseCell: UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if velocity.x >= 0.5 {
            if cellStatus == .Left || rightButtonsWidth() == 0 {
                cellStatus = .Center
            } else {
                cellStatus = .Right
            }
        } else if velocity.x <= -0.5 {
            if cellStatus == .Right || leftButtonsWidth() == 0 {
                cellStatus = .Center
            } else {
                cellStatus = .Left
            }
        } else {
            let leftThreshold = contentOffsetForCellStatus(.Left).x + leftButtonsWidth() * 0.8
            let rightThreshold = contentOffsetForCellStatus(.Right).x - rightButtonsWidth() * 0.8
            
            if targetContentOffset.memory.x > rightThreshold {
                cellStatus = .Right
            } else if targetContentOffset.memory.x < leftThreshold {
                cellStatus = .Left
            } else {
                cellStatus = .Center
            }
        }
        
        if cellStatus != .Center {
            hiddenOtherCells()
        }
        
        
        targetContentOffset.memory = contentOffsetForCellStatus(cellStatus)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.x > leftButtonsWidth() {
            if self.rightButtonsWidth() > 0 {
               // scrollView.contentOffset = CGPointMake(leftButtonsWidth(), 0)
            } else {
                scrollView.contentOffset = CGPointMake(leftButtonsWidth(), 0)
                tapGesture.enabled = true
            }
        } else {
            if leftButtonsWidth() > 0 {
              //  scrollView.contentOffset = CGPointMake(leftButtonsWidth(), 0)
            } else {
                scrollView.contentOffset = CGPointZero
                tapGesture.enabled = true
            }
        }
        updateCellStatus()
    }
    
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        updateCellStatus()
        
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        updateCellStatus()
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            tapGesture.enabled = true
        }
    }
}


extension LGConversionListBaseCell {
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer == containingTableView.panGestureRecognizer && otherGestureRecognizer == longPressGesture) || (gestureRecognizer == longPressGesture && otherGestureRecognizer == containingTableView.panGestureRecognizer) {
            return true
        } else {
            return false
        }
    }
    
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return !(touch.view!.isKindOfClass(UIControl.self))
    }
}


