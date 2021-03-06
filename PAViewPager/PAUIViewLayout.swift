//
//  PAUIViewLayout.swift
//  PAViewPager
//
//  Created by VincentX on 3/7/16.
//
//

import UIKit

extension UIView
{
    enum Direction: Int
    {
        case Vertical
        case Horizontal
        case Both
    }
    
    func fillParent(direction: Direction) -> [NSLayoutConstraint]?
    {
        guard let superview = self.superview else
        {
            return nil
        }
        var constraints: [NSLayoutConstraint] = []
        self.translatesAutoresizingMaskIntoConstraints = false
        if direction == .Vertical || direction == .Both
        {
            let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options:NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": self])
            superview.addConstraints(vConstraints)
            constraints.appendContentsOf(vConstraints)
        }
        if direction == .Horizontal || direction == .Both
        {
            let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options:NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": self])
            superview.addConstraints(hConstraints)
            constraints.appendContentsOf(constraints)
        }
        return constraints
    }
}