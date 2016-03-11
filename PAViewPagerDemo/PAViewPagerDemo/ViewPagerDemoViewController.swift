//
//  ViewPagerDemoViewController.swift
//  PAViewPagerDemo
//
//  Created by VincentX on 2/23/16.
//
//

import UIKit

class ViewPagerDemoViewController: UIViewController, PAViewPagerDelegate, UITextFieldDelegate {
    @IBOutlet var viewPager: PAViewPager!
    
    @IBOutlet var tabWidthTextField: UITextField!
    @IBOutlet var tabHeightTextField: UITextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewPager.delegate = self
        viewPager.reloadData()
        viewPager.setSelectedIndex(2, animated: false)
        viewPager.setAsNormalTabBarStyle(.Top)

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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

    
    internal func textFieldDidEndEditing(textField: UITextField)
    {
        if textField == tabHeightTextField && tabHeightTextField.text != nil
        {
            if let height = Float(tabHeightTextField.text!)
            {
                viewPager.tabHeight = CGFloat(height)
            }
        }
        else if textField == tabWidthTextField && tabWidthTextField.text != nil
        {
            if let width = Float(tabWidthTextField.text!)
            {
                viewPager.tabWidth = CGFloat(width)
            }
        }
    }
    
    @IBAction func changeTabPosition ()
    {
        if viewPager.tabPosition == PAViewPager.TabPosition.Top
        {
            viewPager.tabPosition = PAViewPager.TabPosition.Bottom
        }
        else
        {
            viewPager.tabPosition = .Top
        }
    }
}

