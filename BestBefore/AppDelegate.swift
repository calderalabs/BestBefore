//
//  AppDelegate.swift
//  BestBefore
//
//  Created by Matteo Depalo on 31/01/2018.
//  Copyright © 2018 Caldera Labs. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import SwiftDate
import Eureka

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    static var font = UIFont.init(name: "Avenir", size: 16)
    static var boldFont = UIFont.init(name: "Avenir-Heavy", size: 16)
    static var color = UIColor.init(red: 69.0 / 255, green: 157.0 / 255, blue: 246.0 / 255, alpha: 1)
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let barButtonAppearance = UIBarButtonItem.appearance()
        
        barButtonAppearance.setTitleTextAttributes([NSAttributedStringKey.font: AppDelegate.boldFont!], for: .normal)
        barButtonAppearance.setTitleTextAttributes([NSAttributedStringKey.font: AppDelegate.boldFont!, NSAttributedStringKey.foregroundColor: UIColor.init(white: 1.0, alpha: 0.5)], for: .disabled)
        barButtonAppearance.setTitleTextAttributes([NSAttributedStringKey.font: AppDelegate.boldFont!], for: .selected)
        
        ButtonRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.font = AppDelegate.boldFont
            cell.textLabel?.textColor = AppDelegate.color
        }
        
        DateRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.font = AppDelegate.font
            cell.detailTextLabel?.font = AppDelegate.font
        }
        
        LabelRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.font = AppDelegate.font
        }
        
        IntRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.font = AppDelegate.font
            cell.textField?.font = AppDelegate.font
        }
        
        TextRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.font = AppDelegate.font
            cell.textField?.font = AppDelegate.font
        }
        
        Date.setDefaultRegion(Region.Local())
        FirebaseApp.configure()
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options:[.badge, .alert, .sound]) { (_, _) in }
        return true
    }
    
}



