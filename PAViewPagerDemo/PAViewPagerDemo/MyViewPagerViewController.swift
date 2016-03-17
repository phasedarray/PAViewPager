//
//  MyViewPagerViewController.swift
//  PAViewPagerDemo
//
//  Created by VincentX on 3/17/16.
//
//

import UIKit

class MyViewPagerViewController: PAViewPagerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.brownColor()
        let vc0 = self.storyboard?.instantiateViewControllerWithIdentifier("tab0")
        vc0?.title = "Tab 0"
        let vc1 = self.storyboard?.instantiateViewControllerWithIdentifier("tab0")
        vc1?.title = "Tab 1"
        self.subViewControllers = [vc0!, vc1!]
    }
}
