 //
//  Extention.swift
//  Instagram
//
//  Created by zaki kasem  on 1/11/20.
//  Copyright © 2020 zaki kasem . All rights reserved.
//

import Foundation
import UIKit
 
 extension UIColor {
    static func rgb (red:CGFloat, green:CGFloat, blue:CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    static func mainBlue() -> UIColor {
        return UIColor.rgb(red: 17, green: 154, blue: 237)
    }
 }
 extension Date {
    func timeAgoDisplay () -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 4 * week
        let quotient:Int
        let unit:String
        if secondsAgo < minute {
            quotient = secondsAgo
            unit = "second"
        } else if secondsAgo < hour {
            quotient = secondsAgo / minute
            unit = "min"
        } else if secondsAgo < day {
            quotient = secondsAgo / hour
            unit = "hour"
        }else if secondsAgo < week {
            unit = "day"
            quotient = secondsAgo / day
        }else if secondsAgo < month {
            quotient = secondsAgo / week
            unit = "week"
        }else {
            quotient = secondsAgo / month
            unit = "month"
        }
        return "\(quotient) \(unit) \(quotient == 1 ? "" : "s") ago"
    }
 }
 extension UIViewController {
     func hideKeyboardWhenTappedAround() {
         let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
         tap.cancelsTouchesInView = false
         view.addGestureRecognizer(tap)
     }
     @objc func dismissKeyboard() {
         view.endEditing(true)
     }
 }
 extension UIView {
     func setAnchor(top:NSLayoutYAxisAnchor? ,left:NSLayoutXAxisAnchor?,right:NSLayoutXAxisAnchor?,bottom:NSLayoutYAxisAnchor?,paddingBottom:CGFloat,paddingLeft:CGFloat,paddingRight:CGFloat, paddingTop :CGFloat,height:CGFloat,width:CGFloat ) {
         self.translatesAutoresizingMaskIntoConstraints = false
         if let top = top {
             self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
         }
         if let left = left {
             self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
         }
         if let right = right {
             self.rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
         }
         if let bottom = bottom {
             self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
         }
         if height != 0 {
             heightAnchor.constraint(equalToConstant: height).isActive = true
         }
         if width != 0 {
             widthAnchor.constraint(equalToConstant: width).isActive = true
         }
     }
 }
