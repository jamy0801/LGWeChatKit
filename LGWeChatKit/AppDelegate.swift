//
//  AppDelegate.swift
//  LGChatViewController
//
//  Created by gujianming on 15/10/8.
//  Copyright © 2015年 jamy. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        UINavigationBar.appearance().barTintColor = UIColor(hexString: "39383d")
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(17.0), NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : UIColor(hexString: "68BB1E")!], forState: .Selected)
        
        self.window?.rootViewController = configurationRootViewController()
        
        window?.makeKeyAndVisible()
        
        return true
    }
    
    
    func configurationRootViewController() -> UITabBarController {
        let messageListCtrl = LGConversationListController()
        messageListCtrl.tabBarItem.title = "消息"
        messageListCtrl.tabBarItem.image = UIImage(named: "tabbar_mainframe")?.imageWithRenderingMode(.AlwaysOriginal)
        messageListCtrl.tabBarItem.selectedImage = UIImage(named: "tabbar_mainframeHL")?.imageWithRenderingMode(.AlwaysOriginal)
        let messageNavigationController = UINavigationController(rootViewController: messageListCtrl)
        
        // Create `chatsTableViewController`
        let friendCtrl = LGFriendViewController()
        friendCtrl.tabBarItem.title = "通讯录"
        friendCtrl.tabBarItem.image = UIImage(named: "tabbar_contacts")?.imageWithRenderingMode(.AlwaysOriginal)
        friendCtrl.tabBarItem.selectedImage = UIImage(named: "tabbar_contactsHL")?.imageWithRenderingMode(.AlwaysOriginal)
        let friendNavigationController = UINavigationController(rootViewController: friendCtrl)
        
        // Create `profileTableViewController`
        let finderCtrl = UIStoryboard(name: "findSB", bundle: nil).instantiateInitialViewController() as! LGFindViewController
        finderCtrl.tabBarItem.title = "发现"
        finderCtrl.tabBarItem.image = UIImage(named: "tabbar_discover")?.imageWithRenderingMode(.AlwaysOriginal)
        finderCtrl.tabBarItem.selectedImage = UIImage(named: "tabbar_discoverHL")?.imageWithRenderingMode(.AlwaysOriginal)
        let findNavigationController = UINavigationController(rootViewController: finderCtrl)
        
        // Create `settingsTableViewController`
        let setCtrl = UIStoryboard(name: "setSB", bundle: nil).instantiateInitialViewController() as! LGMeViewController
        setCtrl.tabBarItem.title = "我"
        setCtrl.tabBarItem.image = UIImage(named: "tabbar_me")?.imageWithRenderingMode(.AlwaysOriginal)
        setCtrl.tabBarItem.selectedImage = UIImage(named: "tabbar_meHL")?.imageWithRenderingMode(.AlwaysOriginal)
        let settingsNavigationController = UINavigationController(rootViewController: setCtrl)
        
        let tabBarController = UITabBarController(nibName: nil, bundle: nil)
        tabBarController.viewControllers = [messageNavigationController, friendNavigationController, findNavigationController, settingsNavigationController]
        return tabBarController
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

