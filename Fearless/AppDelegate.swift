//
//  AppDelegate.swift
//  Fearless
//
//  Created by Water Flower on 2019/4/22.
//  Copyright © 2019 Water Flower. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import MediaPlayer
import AVKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var storyboard = UIStoryboard()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            print("-----------ipad--------------")
            
            let font = UIFont.systemFont(ofSize: 25)
            UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: font]

            storyboard = UIStoryboard(name: "MainiPad", bundle: nil)
            self.window!.rootViewController = storyboard.instantiateInitialViewController()!
        } else {
            print("----------iphone-----------")
            storyboard = UIStoryboard(name: "Main", bundle: nil)
            self.window!.rootViewController = storyboard.instantiateInitialViewController()!
        }
        self.window!.makeKeyAndVisible()
      
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            
            Messaging.messaging().delegate = self
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        FirebaseApp.configure()
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .moviePlayback)
        }
        catch {
          print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        
        return true
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        
        if let rootViewController = self.window?.rootViewController as? UINavigationController {
            if let viewController = rootViewController.viewControllers.last as? VideoPlayerViewController {
                viewController.disconnectAVPlayer()
            } else if let viewController = rootViewController.viewControllers.last as? VideoPlayeriPadViewController {
                viewController.disconnectAVPlayer()
            }
        }

    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        if let rootViewController = self.window?.rootViewController as? UINavigationController {
            if let viewController = rootViewController.viewControllers.last as? VideoPlayerViewController {
                viewController.reconnectAVPlayer()
            } else if let viewController = rootViewController.viewControllers.last as? VideoPlayeriPadViewController {
                viewController.reconnectAVPlayer()
            }
        }

    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if let navigationController = self.window?.rootViewController as? UINavigationController {
            if navigationController.visibleViewController is VideoPlayerViewController {
                return UIInterfaceOrientationMask.all
            } else {
                return UIInterfaceOrientationMask.portrait
            }
        }
        return UIInterfaceOrientationMask.portrait
    }


}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
}

extension AppDelegate: MessagingDelegate {
    
}

