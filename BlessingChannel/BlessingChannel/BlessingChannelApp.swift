//
//  BlessingChannelApp.swift
//  BlessingChannel
//
//  Created by 김동준 on 5/25/25.
//

import Foundation
import SwiftUI


@main
struct BlessingChannelApp: App {
    // AppDelegate 연동
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            LoginView()
        }
    }
}
