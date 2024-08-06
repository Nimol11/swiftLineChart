//
//  AppDelegate.swift
//  SwiftLineChart
//
//  Created by Nimol on 24/7/24.
//

import UIKit

var applicationIsActive: Bool = false

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        applicationIsActive = false
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        applicationIsActive = true
    }
}
