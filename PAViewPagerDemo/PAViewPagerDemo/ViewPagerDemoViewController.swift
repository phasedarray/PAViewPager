//
//  ViewPagerDemoViewController.swift
//  PAViewPagerDemo
//
//  Created by VincentX on 2/23/16.
//
//

import UIKit

class ViewPagerDemoViewController: UIViewController, PAViewPagerDelegate {
    @IBOutlet var viewPager: PAViewPager!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewPager.delegate = self
        viewPager.reloadData()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfPageInViewPager(viewPager: PAViewPager) -> Int
    {
        return 5
    }
    
    func viewPager(viewPager: PAViewPager, reusableIdentifierForIndex: Int)-> String
    {
        return "Content"
    }
    
    func viewPager(viewPager: PAViewPager, resuableView: UIView?, viewForIndex: Int) -> UIView
    {
        var view = resuableView as? ContentView
        if view == nil
        {
            view = NSBundle.mainBundle().loadNibNamed("ContentView", owner: nil, options: [:])[0] as? ContentView
        }
        view!.label.text = "Content \(viewForIndex)"
        return view!
    }
    
    func viewPager(viewPager: PAViewPager, titleForIndex: Int) -> String
    {
        return "Page \(titleForIndex)"
    }

}

