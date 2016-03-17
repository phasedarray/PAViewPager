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
        let vc0 = self.storyboard?.instantiateViewControllerWithIdentifier("tab0")
        self.subViewControllers = [vc0!]
    }
}
