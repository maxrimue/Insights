//
//  InsightsApp.swift
//  Insights
//
//  Created by Max on 20.01.25.
//

import SwiftUI

#if DEBUG
    let runningInPreviews =
        ProcessInfo.processInfo.environment[
            "XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    let runningInUnitTests =
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"]
        != nil

    @main
    struct InsightsApp: App {
        @StateObject var remindersInterface = RemindersInterface(
            eventStore: runningInPreviews || runningInUnitTests
                ? createMockEventStore(withReminders: []) : nil)

        var body: some Scene {
            WindowGroup {
                ContentView().environmentObject(remindersInterface)
            }.windowResizability(.contentSize)

            Window("Debug", id: "debug") {
                DebugView().environmentObject(remindersInterface)
            }
        }
    }

#else

    @main
    struct InsightsApp: App {
        @StateObject var remindersInterface = RemindersInterface()

        var body: some Scene {
            WindowGroup {
                ContentView().environmentObject(remindersInterface)
            }.windowResizability(.contentSize)

            Window("Debug", id: "debug") {
                DebugView().environmentObject(remindersInterface)
            }
        }
    }

#endif
