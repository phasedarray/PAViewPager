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
                vc.removeFromParentViewController()
            }
            subViewControllers.forEach { (vc) -> () in
                self.addChildViewController(vc)
                
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
    
    private func setup()
    {
        self.view.addSubview( self.viewPager)
        self.viewPager.fillParent(.Both)
        self.viewPager.delegate = self
        self.viewPager.setAsNormalTabBarStyle(PAViewPager.TabPosition.Top)
    }
}
