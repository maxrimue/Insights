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
    @State var errorMsg: String?
    
    let remindersInterface = RemindersInterface()
    
    var body: some View {
        VStack {
            if (errorMsg != nil) {
                Text(errorMsg!).foregroundStyle(.red)
            } else if (reminders == nil) {
                Text("No reminders loaded")
            } else if (reminders != nil) {
                List(reminders!, id: \.calendarItemIdentifier) { reminder in
                    VStack(alignment: .leading) {
                        Text(reminder.title ?? "No Title")
                            .font(.headline)
                        //                        if let dueDate = reminder.dueDateComponents?.date {
                        //                            Text("Due: \(formattedDate(dueDate))")
                        //                                .font(.subheadline)
                        //                                .foregroundColor(.secondary)
                        //                        }
                        Text(reminder.debugDescription)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .task {
            do {
                self.reminders = try await self.remindersInterface.fetchReminders()
            } catch {
                errorMsg = error.localizedDescription
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    ContentView()
}
