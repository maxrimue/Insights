//
//  ContentView.swift
//  Insights
//
//  Created by Max on 20.01.25.
//

import SwiftUI
import EventKit

struct ContentView: View {
    @State var reminders: [EKReminder]?
    @State var remindersPercentageDone: Double?
    @State var errorMsg: String?
    
    let remindersInterface = RemindersInterface()
    
    var body: some View {
        VStack {
            if (errorMsg != nil) {
                Text(errorMsg!).foregroundStyle(.red)
            } else {
                MetricView(metric: "\(String((remindersPercentageDone ?? 0) * 100))%", metricDescription: "Of reminders due today are done")
            }
        }
        .padding()
        .task {
            do {
                self.reminders = try await self.remindersInterface.fetchReminders()

                self.remindersPercentageDone = try await self.remindersInterface.getPercentageOfTasksCompleted()
            } catch {
                errorMsg = error.localizedDescription
            }
        }
    }
}

#Preview {
    ContentView()
}
