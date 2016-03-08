//
//  PAViewPager.swift
//  PAViewPagerDemo
//
//  Created by VincentX on 2/23/16.
//
//

import Foundation
import UIKit

@objc public protocol PAViewPagerDelegate: NSObjectProtocol
{
    func numberOfPageInViewPager(viewPager: PAViewPager) -> Int
    optional func viewPager(viewPager: PAViewPager, reusableIdentifierForIndex: Int)-> String
    func viewPager(viewPager: PAViewPager, resuableView: UIView?, viewForIndex: Int) -> UIView
    
    optional func viewPager(viewPager: PAViewPager, titleForIndex: Int) -> String
    
    optional func viewPager(viewPager: PAViewPager, reusableIdentifierForTitleViewIndex: Int) -> String
    optional func viewPager(viewPager: PAViewPager, titleViewForIndex: Int) -> Int
}

public class PAViewPager: UIView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource
{
    // MARK: Public properties
    public var tabSelectedBackgroundColor: UIColor = UIColor.orangeColor()
    {
        didSet
        {
            if let selectedItems = self.tabCollectionView.indexPathsForSelectedItems()
            {
                self.tabCollectionView.reloadItemsAtIndexPaths(selectedItems)
            }
        }
    }
    
    public var selectedIndex:Int = 0
    {
        didSet
        {
            if selectedIndex < numberOfItems
            {
                let indexPath = NSIndexPath(forRow: selectedIndex, inSection: 0)
                self.tabCollectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .CenteredHorizontally)
                self.contentCollectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .CenteredHorizontally)
            }
        }
    }

    
    // MARK: Private variables
    var tabCollectionView: UICollectionView
    var contentCollectionView: UICollectionView
    let titleCellIndentifier = "tabTitleCell"
    let kCommonTag = 1001
    var numberOfItems:Int = 0
    var tabDequeueDictionary:[String:Bool] = [:]
    var contentDequeueDictionary: [String:Bool] = [:]
    
    
    @IBOutlet weak var delegate: PAViewPagerDelegate?
    {
        didSet
        {
            self.tabCollectionView.delegate = self
            self.tabCollectionView.dataSource = self
            self.contentCollectionView.delegate = self
            self.contentCollectionView.dataSource = self
        }
    }
    
    override public init(frame: CGRect) {
        self.tabCollectionView = UICollectionView()
        self.contentCollectionView = UICollectionView()
        self.tabCollectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: titleCellIndentifier)
        super.init(frame: frame)
        self.addConstraintsToSubviews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsetsZero
        layout.minimumLineSpacing = 0
        self.tabCollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        self.tabCollectionView.backgroundColor = UIColor.clearColor()
//        self.tabCollectionView.alwaysBounceVertical = false
//        self.tabCollectionView.showsVerticalScrollIndicator = false
        
        let layout2 = UICollectionViewFlowLayout()
        layout2.scrollDirection = .Horizontal
        layout2.minimumInteritemSpacing = 0
        layout2.sectionInset = UIEdgeInsetsZero
        layout2.minimumLineSpacing = 0
        
        self.contentCollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout2)
        self.contentCollectionView.pagingEnabled = true
        
        self.tabCollectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: titleCellIndentifier)

        super.init(coder: aDecoder)
        self.addSubview(tabCollectionView)
        self.addSubview(contentCollectionView)
        self.addConstraintsToSubviews()
    }
    
    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
    }
    
    func reloadData()
    {
        self.tabCollectionView.reloadData()
        self.contentCollectionView.reloadData()
        
    }
    
    func addConstraintsToSubviews()
    {
        self.tabCollectionView.translatesAutoresizingMaskIntoConstraints = false
        self.contentCollectionView.translatesAutoresizingMaskIntoConstraints = false
        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[tab(44)]-(0)-[content]|", options:NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["tab": tabCollectionView, "content": contentCollectionView])
        let hTabConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[tab]|", options:NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["tab": tabCollectionView])
        let hContentConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[content]|", options:NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["content": contentCollectionView])
        self.addConstraints(vConstraints)
        self.addConstraints(hTabConstraints)
        self.addConstraints(hContentConstraints)
        self.layoutIfNeeded()
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        guard let delegate = self.delegate else
        {
            return 0
        }
        numberOfItems = delegate.numberOfPageInViewPager(self)
        return numberOfItems
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        
        if collectionView == self.contentCollectionView
        {
            return cellForContentView(indexPath)
        }
        return cellForTab(indexPath)
        
    }
    
    private func cellForContentView(indexPath: NSIndexPath) -> UICollectionViewCell
    {
        var indentifier = "cell"
        guard let delegate = self.delegate else
        {
            return self.contentCollectionView.dequeueReusableCellWithReuseIdentifier(indentifier, forIndexPath: indexPath)
        }
        
        if delegate.respondsToSelector("viewPager:reusableIdentifierForIndex:")
        {
            indentifier = delegate.viewPager!(self, reusableIdentifierForIndex: indexPath.row)
            if contentDequeueDictionary[indentifier] == nil
            {
                self.contentCollectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: indentifier)
                contentDequeueDictionary[indentifier] = true
            }
        }
        let cell = self.contentCollectionView.dequeueReusableCellWithReuseIdentifier(indentifier, forIndexPath: indexPath)
        if delegate.respondsToSelector("viewPager:resuableView:viewForIndex:")
        {
            let view = delegate.viewPager(self, resuableView: cell.contentView.viewWithTag(kCommonTag), viewForIndex: indexPath.row)
            view.tag = kCommonTag
            if view.superview != cell.contentView
            {
                let subviews = cell.contentView.subviews.map({ (view) -> UIView in
                    return view
                })
                subviews.forEach({ (view) -> () in
                    view.removeFromSuperview()
                })
                cell.contentView.addSubview(view)
                view.fillParent(.Both)
            }
        }
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        if collectionView == tabCollectionView
        {
            return CGSize(width: CGFloat( Float(CGRectGetWidth(self.frame)) / Float(numberOfItems)), height: 44)
        }
        else
        {
            return CGSize(width: CGRectGetWidth(self.frame), height: CGRectGetHeight(self.frame) - 44)
        }
    }
    
    // MARK: UICollectionViewDelegate
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        if collectionView == tabCollectionView
        {
            contentCollectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: true)
        }
    }
    
    public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath)
    {
        if collectionView.decelerating
        {
            if collectionView == contentCollectionView
            {
                tabCollectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .Right)
            }
        }
    }
    
    // MARK: UIScrollViewDelegate
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView)
    {
        if scrollView == contentCollectionView
        {
            let i = scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame)
            self.tabCollectionView.selectItemAtIndexPath(NSIndexPath(forRow: Int(i), inSection: 0), animated: false, scrollPosition: .Right)
        }
    }
    
    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool)
    {
        if scrollView == contentCollectionView && !decelerate
        {
            scrollViewDidEndDecelerating(scrollView)
        }
    }

    
    
    private func cellForTab(indexPath: NSIndexPath) -> UICollectionViewCell
    {
        var indentifier = "cell"
        guard let delegate = self.delegate else
        {
            return self.tabCollectionView.dequeueReusableCellWithReuseIdentifier(indentifier, forIndexPath: indexPath)
        }
        if delegate.respondsToSelector("viewPager:titleForIndex:")
        {
            let cell = self.tabCollectionView.dequeueReusableCellWithReuseIdentifier(titleCellIndentifier, forIndexPath: indexPath)
            cell.selectedBackgroundView = UIView(frame: CGRectZero)
            cell.selectedBackgroundView?.backgroundColor = self.tabSelectedBackgroundColor
            var titleLabel = cell.contentView.viewWithTag(kCommonTag) as? UILabel
            if titleLabel == nil
            {
                titleLabel = UILabel()
                titleLabel?.textAlignment = .Center
                cell.contentView.addSubview(titleLabel!)
                titleLabel!.tag = kCommonTag
                titleLabel?.fillParent(.Both)
            }
            let title = delegate.viewPager!(self, titleForIndex: indexPath.row)
            titleLabel!.text = title
            return cell
        }
        if delegate.respondsToSelector("viewPager:reusableIdentifierForTitleViewIndex:")
        {
            indentifier = delegate.viewPager!(self, reusableIdentifierForTitleViewIndex: indexPath.row)
            if tabDequeueDictionary[indentifier] == nil
            {
                self.tabCollectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: indentifier)
                tabDequeueDictionary[indentifier] = true
            }
            let cell = self.tabCollectionView.dequeueReusableCellWithReuseIdentifier(indentifier, forIndexPath: indexPath)
            let view = cell.contentView.viewWithTag(kCommonTag)
            let tabView = delegate.viewPager(self, resuableView: view, viewForIndex: indexPath.row)
            if tabView.superview == cell.contentView
            {
                let subviews = cell.contentView.subviews.map({ (view) -> UIView in
                    return view
                })
                subviews.forEach({ (view) -> () in
                    view.removeFromSuperview()
                })
                cell.contentView.addSubview(tabView)
                tabView.fillParent(.Both)
            }
            return cell
        }
        return self.tabCollectionView.dequeueReusableCellWithReuseIdentifier(indentifier, forIndexPath: indexPath)
    }
}
