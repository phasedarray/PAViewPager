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
    optional func viewPager(viewPager: PAViewPager, resuableTitleView: UIView?, titleViewForIndex: Int) -> UIView
}

public class PAViewPager: UIView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource
{
    public enum AnimationWhenTappingTab
    {
        case None
        case Adjacent
        case All
    }
    
    public enum TabPosition
    {
        case Top
        case Bottom
    }
    
    // MARK: Public properties
    public var tabSelectedBackgroundColor: UIColor = UIColor.orangeColor()
    {
        didSet
        {
            self.selectionIndicatorView.backgroundColor = tabSelectedBackgroundColor
        }
    }
    
    public var titleColor: UIColor = UIColor.blackColor()
    public var titleFont: UIFont = UIFont.systemFontOfSize(14)
    public var selectedTitleColor: UIColor = UIColor.whiteColor()
    public var animatedScrollWhenTappingTab: AnimationWhenTappingTab = .Adjacent
    public var needAnimateSelectionIndictor: Bool = true
    
    public var allowScroll = true
    {
        didSet
        {
            self.contentCollectionView.scrollEnabled = allowScroll
        }
    }
    
    public var tabHeight: CGFloat  = 44
    {
        didSet
        {
            tabHeightConstraint.constant = tabHeight
            self.tabCollectionView.collectionViewLayout.invalidateLayout()
            self.contentCollectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    public var tabWidth: CGFloat = 0
    {
        didSet
        {
            self.tabCollectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    public var tabOffset: CGFloat = 0
    {
        didSet
        {
            if let flowLayout = self.tabCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
            {
                flowLayout.sectionInset = UIEdgeInsets(top: 0, left: tabOffset, bottom: 0, right: 0)
                flowLayout.invalidateLayout()
            }
        }
    }
    
    public var tabPosition: TabPosition = .Top
    {
        didSet
        {
            if self.verticalLayoutConstraints.count > 0
            {
                self.removeConstraints(self.verticalLayoutConstraints)
            }
            self.tabView.translatesAutoresizingMaskIntoConstraints = false
            self.contentCollectionView.translatesAutoresizingMaskIntoConstraints = false
            var layoutStr = "V:|[tab(\(tabHeight))]-(0)-[content]|"
            if tabPosition == .Bottom
            {
                layoutStr = "V:|[content]-(0)-[tab(\(tabHeight))]|"
            }
            
            let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat(layoutStr, options:NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["tab": tabView, "content": contentCollectionView])
            self.tabHeightConstraint = vConstraints[1]
            self.verticalLayoutConstraints = vConstraints
            self.addConstraints(vConstraints)
            self.layoutIfNeeded()
        }
    }
    
    public var tabBackgroundColor: UIColor = UIColor.lightGrayColor()
    {
        didSet
        {
            self.tabView.backgroundColor = tabBackgroundColor
        }
    }
    
    // MARK: SelectionIndicator parameters
    public var selectionIndicatorHeight: CGFloat = 44
    {
        didSet
        {
            self.selectionIndicatorVerticalConstraints[1].constant = selectionIndicatorHeight
        }
    }
    
    public var selectionIndicatorY: CGFloat = 40 {
        didSet
        {
            self.selectionIndicatorVerticalConstraints[0].constant = selectionIndicatorY
        }
    }
    
    public var selectionIndicatorWidth: CGFloat = 0 {
        didSet
        {
            self.selectionIndicatorVerticalConstraints[1].constant = selectionIndicatorWidth
            adjustSelectionIndicator()
        }
    }

    
    public var selectionIndicatorView: UIView
    
    // MARK: Private variables
    var tabCollectionView: UICollectionView
    var contentCollectionView: UICollectionView
    let titleCellIndentifier = "tabTitleCell"
    let kCommonTag = 1001
    var numberOfItems:Int = 0
    var tabDequeueDictionary:[String:Bool] = [:]
    var contentDequeueDictionary: [String:Bool] = [:]
    var tabHeightConstraint: NSLayoutConstraint!
    
    var selectionIndicatorVerticalConstraints: [NSLayoutConstraint] = []
    var selectionIndicatorHorizontalConstraints: [NSLayoutConstraint] = []
    var verticalLayoutConstraints: [NSLayoutConstraint] = []
    var tabView: UIView
    
    private var _selectedIndex:Int = 0

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
        let contentlayout = UICollectionViewFlowLayout()
        let tabLayout = UICollectionViewFlowLayout()
        self.tabView = UIView(frame: CGRectZero)
        self.selectionIndicatorView = UIView(frame: CGRectZero)
        self.tabCollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: tabLayout)
        self.contentCollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: contentlayout)
        super.init(frame: frame)
        self.initViews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        let contentlayout = UICollectionViewFlowLayout()
        let tabLayout = UICollectionViewFlowLayout()
        self.tabView = UIView(frame: CGRectZero)
        self.selectionIndicatorView = UIView(frame: CGRectZero)
        self.tabCollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: tabLayout)
        self.contentCollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: contentlayout)
        super.init(coder: aDecoder)
        self.initViews()
    }
    
    func initViews()
    {
        if let tabLayout = tabCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        {
            tabLayout.scrollDirection = .Horizontal
            tabLayout.minimumInteritemSpacing = 0
            tabLayout.sectionInset = UIEdgeInsetsZero
            tabLayout.minimumLineSpacing = 0
        }
        self.tabCollectionView.backgroundColor = UIColor.clearColor()
        self.tabCollectionView.showsHorizontalScrollIndicator = false
        self.tabCollectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: titleCellIndentifier)
        self.tabView.backgroundColor = self.tabBackgroundColor

        if let contentLayout = contentCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        {
            contentLayout.scrollDirection = .Horizontal
            contentLayout.minimumInteritemSpacing = 0
            contentLayout.sectionInset = UIEdgeInsetsZero
            contentLayout.minimumLineSpacing = 0
        }
        self.contentCollectionView.pagingEnabled = true
        self.contentCollectionView.showsHorizontalScrollIndicator = false
        tabView.addSubview(selectionIndicatorView)
        tabView.addSubview(tabCollectionView)
        self.addSubview(tabView)
        self.addSubview(contentCollectionView)
        self.addConstraintsToSubviews()
        self.selectionIndicatorView.backgroundColor = tabSelectedBackgroundColor
    }
    
    public func setSelectedIndex(index: Int, animated: Bool)
    {
        if index < numberOfItems
        {
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            if self.tabCollectionView.indexPathsForSelectedItems()?.count > 0
            {
                self.tabCollectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .CenteredHorizontally)
            }
            self.collectionView(tabCollectionView, didDeselectItemAtIndexPath: NSIndexPath(forRow: _selectedIndex, inSection: 0))
            _selectedIndex = index
            self.collectionView(tabCollectionView, didSelectItemAtIndexPath: indexPath)
            self.contentCollectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Left, animated: animated && allowScroll)
            adjustSelectionIndicator(needAnimateSelectionIndictor)
        }
    }
    
    public func selectedIndex()-> Int
    {
        return _selectedIndex
    }
    
    func reloadData()
    {
        numberOfItems = tabCollectionView.numberOfItemsInSection(0)
        self.tabCollectionView.reloadData()
        self.contentCollectionView.reloadData()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()
        self.tabCollectionView.collectionViewLayout.invalidateLayout()
        self.contentCollectionView.collectionViewLayout.invalidateLayout()
        
        if (_selectedIndex < numberOfItems)
        {
            let indexPath = NSIndexPath(forRow: _selectedIndex, inSection: 0)
            if let indexes = self.tabCollectionView.indexPathsForSelectedItems()
            {
                if indexes.count > 0 && indexes[0].row == _selectedIndex
                {
                    //return
                }
            }
            self.tabCollectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .CenteredHorizontally)
            self.contentCollectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Left, animated: false)
            adjustSelectionIndicator(false)
            return
        }
    }
    
    func addConstraintsToSubviews()
    {
        self.tabCollectionView.fillParent(.Both)
        self.tabView.fillParent(.Horizontal)
        self.contentCollectionView.fillParent(.Horizontal)
        self.tabPosition = .Top
        
        self.selectionIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-\(self.selectionIndicatorY)-[selectionView(\(self.selectionIndicatorHeight))]", options:NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["selectionView": self.selectionIndicatorView])
        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[selectionView(\(self.selectionIndicatorWidth))]", options:NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["selectionView": self.selectionIndicatorView])
        self.selectionIndicatorVerticalConstraints = vConstraints
        self.selectionIndicatorHorizontalConstraints = hConstraints
        self.addConstraints(vConstraints)
        self.addConstraints(hConstraints)
        self.layoutIfNeeded()
    }
    
    func setupVerticalLayout(tabPosition: TabPosition)
    {
        
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        guard let delegate = self.delegate else
        {
            return 0
        }
        return delegate.numberOfPageInViewPager(self)
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
            return CGSize(width: tabWidth > 0 ? tabWidth : CGFloat( Float(CGRectGetWidth(self.frame)) / Float(numberOfItems)), height: tabHeight)
        }
        else
        {
            return CGSize(width: CGRectGetWidth(self.frame), height: CGRectGetHeight(self.frame) - tabHeight)
        }
    }
    
    // MARK: UICollectionViewDelegate
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        if collectionView == tabCollectionView
        {
            let offset = abs(indexPath.row - _selectedIndex)
            _selectedIndex = indexPath.row
            if let cell = self.tabCollectionView.cellForItemAtIndexPath(indexPath)
            {
                if delegate != nil && delegate!.respondsToSelector("viewPager:titleForIndex:")
                {
                    if let titleLabel = cell.contentView.viewWithTag(kCommonTag) as? UILabel
                    {
                        titleLabel.textColor = self.selectedTitleColor
                    }
                }
            }
            var anmiated = false
            switch(animatedScrollWhenTappingTab)
            {
            case .None:
                    anmiated = false
                
            case .All:
                    anmiated = true
            case .Adjacent:
                    anmiated = (offset == 1)
            }
            
            contentCollectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: anmiated && allowScroll)
            adjustSelectionIndicator(needAnimateSelectionIndictor)
        }
    }
    
    public func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath)
    {
        if collectionView == tabCollectionView
        {
            if let cell = self.tabCollectionView.cellForItemAtIndexPath(indexPath)
            {
                if delegate != nil && delegate!.respondsToSelector("viewPager:titleForIndex:")
                {
                    if let titleLabel = cell.contentView.viewWithTag(kCommonTag) as? UILabel
                    {
                        titleLabel.textColor = self.titleColor
                    }
                }
            }
        }
    }
    
    // MARK: UIScrollViewDelegate
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView)
    {
        if scrollView == contentCollectionView
        {
            let i = scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame)
            self.setSelectedIndex(Int(i), animated: true)
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
            cell.backgroundColor = UIColor.clearColor()
            cell.backgroundView = UIView()
//            cell.selectedBackgroundView = UIView(frame: CGRectZero)
//            cell.selectedBackgroundView?.backgroundColor = self.tabSelectedBackgroundColor
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
            titleLabel!.font = self.titleFont
            titleLabel!.textColor = self.titleColor
            if let selected = self.tabCollectionView.indexPathsForSelectedItems()
            {
                if selected.contains(indexPath)
                {
                    titleLabel!.textColor = self.selectedTitleColor
                }
            }
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
            let tabView = delegate.viewPager!(self, resuableTitleView: view, titleViewForIndex: indexPath.row)
            if tabView.superview != cell.contentView
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
    
    private func adjustSelectionIndicator(animated: Bool = false)
    {
        var width = self.selectionIndicatorWidth
        if width == 0
        {
            width = CGRectGetWidth(self.frame) / CGFloat(numberOfItems)
        }
        if let cell = self.tabCollectionView.cellForItemAtIndexPath(NSIndexPath(forRow: self.selectedIndex(), inSection: 0))
        {
            if let superview = cell.superview
            {
                let x = superview.convertPoint(cell.center, toView: self.tabView).x
                let block = {
                    self.selectionIndicatorHorizontalConstraints[0].constant = x - width / 2
                    self.layoutIfNeeded()
                }
                if animated
                {
                    UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseInOut, animations: block, completion: nil)
                }
                else
                {
                    block()
                }
            }
        }
        self.selectionIndicatorHorizontalConstraints[1].constant = width
    }
}

public extension PAViewPager
{
    public func setAsNormalTabBarStyle(tabPosition: TabPosition)
    {
        self.allowScroll = false
        self.tabWidth = 0
        self.tabOffset = 0
        self.tabPosition = tabPosition
        self.animatedScrollWhenTappingTab = .None
    }
    
    public func setAsViewPagerStyle(tabPosition: TabPosition)
    {
        self.allowScroll = true
        self.tabWidth = 0
        self.tabOffset = 0
        self.tabPosition = tabPosition
        self.animatedScrollWhenTappingTab = .Adjacent
    }
}
