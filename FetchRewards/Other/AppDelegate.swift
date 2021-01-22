//
//  AppDelegate.swift
//  FetchRewards
//
//  Created by Arseniy  Oddler on 1/20/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // Really deprecated. Did it just to let app run on IOS 12
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let eventsListController = EventsListView()
        guard let window = window else {
            return false
        }
        window.rootViewController = eventsListController
        window.makeKeyAndVisible()
        return true
    }
}

