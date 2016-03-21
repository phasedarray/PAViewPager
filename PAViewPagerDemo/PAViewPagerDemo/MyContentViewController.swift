//
//  MyContentViewController.swift
//  PAViewPagerDemo
//
//  Created by VincentX on 3/21/16.
//
//

import UIKit

class MyContentViewController: UIViewController {
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSLog("\(self.title): viewWillDisappear")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSLog("\(self.title): viewWillAppear")
    }
}
