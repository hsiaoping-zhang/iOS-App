//
//  LocationMessageApp.swift
//  LocationMessage
//
//  Created by 張筱萍 on 2021/4/5.
//

import SwiftUI
import Firebase

@main
struct LocationMessageApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State var signInSuccess = false

    var body: some Scene {
        WindowGroup {
//            AudioView()
            if(signInSuccess){
                ContentView()
//                MapView()
            }
            else{
                LoginView(signInSuccess: $signInSuccess)
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate{
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Configure FirebaseApp
        FirebaseApp.configure()
        print("connect to firebase")
        return true
    }
}
