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
        self.viewPager = PAViewPager(frame: CGRectZero)
        super.init(coder: aDecoder)
        self.view = self.viewPager
        self.viewPager.delegate = self
        self.viewPager.setAsNormalTabBarStyle(PAViewPager.TabPosition.Top)
    }
    
    public var subViewControllers:[UIViewController] = []
    {
        didSet(oldValues)
        {
            oldValues.forEach { (vc) -> () in
                vc.removeFromParentViewController()
            }
            subViewControllers.forEach { (vc) -> () in
                self.addChildViewController(vc)
                
            }
            viewPager.reloadData()
        }
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
}
