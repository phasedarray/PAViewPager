//
//  PAViewPagerViewController.swift
//  PAViewPagerDemo
//
//  Created by VincentX on 3/14/16.
//
//

import UIKit

public class PAViewPagerViewController: UIViewController, PAViewPagerDelegate {
    
    public var viewPager: PAViewPager
    
    public required init?(coder aDecoder: NSCoder) {
        self.viewPager = PAViewPager(frame: CGRect(x: 0, y: 0, width: 0, height: 44))
        super.init(coder: aDecoder)
        self.edgesForExtendedLayout = .None
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        self.viewPager = PAViewPager(frame: CGRectZero)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.setup()
    }
    
    public var subViewControllers:[UIViewController] = []
    {
        didSet(oldValues)
        {
            oldValues.forEach { (vc) -> () in
                vc.willMoveToParentViewController(nil)
                vc.removeFromParentViewController()
                vc.didMoveToParentViewController(nil)
            }
            subViewControllers.forEach { (vc) -> () in
                vc.willMoveToParentViewController(self)
                self.addChildViewController(vc)
                vc.didMoveToParentViewController(self)
                
            }
            viewPager.reloadData()
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
        
    public func numberOfPageInViewPager(viewPager: PAViewPager) -> Int
    {
        return self.subViewControllers.count
    }
    
    public func viewPager(viewPager: PAViewPager, reusableIdentifierForIndex: Int)-> String
    {
        return "controller"
    }
    
    public func viewPager(viewPager: PAViewPager, resuableView: UIView?, viewForIndex: Int) -> UIView
    {
        return self.subViewControllers[viewForIndex].view
    }
    
    public func viewPager(viewPager: PAViewPager, titleForIndex: Int) -> String
    {
        if let title = self.subViewControllers[titleForIndex].title
        {
            return title
        }
        return ""
    }
    
    public func viewPager(viewPager: PAViewPager, willShowViewAtIndex: Int, animated: Bool) -> Void
    {
        if viewPager.selectedIndex() >= 0
        {
            let oldVC = self.subViewControllers[viewPager.selectedIndex()]
            oldVC.viewWillDisappear(animated)
        }
        let newVC = self.subViewControllers[willShowViewAtIndex]
        newVC.viewWillAppear(animated)
        
    }
    
    public func viewPager(viewPager: PAViewPager, didShowViewAtIndex: Int, previousIndex:Int, animated: Bool) -> Void
    {
        if previousIndex >= 0
        {
            let oldVC = self.subViewControllers[previousIndex]
            oldVC.viewDidDisappear(animated)
        }
        let newVC = self.subViewControllers[didShowViewAtIndex]
        newVC.viewDidAppear(animated)
    }
    
    private func setup()
    {
        self.view.addSubview( self.viewPager)
        self.viewPager.fillParent(.Both)
        self.viewPager.delegate = self
        self.viewPager.setAsNormalTabBarStyle(PAViewPager.TabPosition.Top)
        self.viewPager.allowScroll = true
    }
}
