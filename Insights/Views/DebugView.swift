//
//  DebugView.swift
//  Insights
//
//  Created by Max Rittmüller on 29.01.25.
//

import EventKit
import SwiftUI

struct DebugView: View {
    @State var reminders: [EKReminder]?
    @State var searchResult: [EKReminder]?
    @State var searchPhrase: String = ""
    let remindersInterface = RemindersInterface()

    var body: some View {
        VStack {
            TextField(
                "Search for reminders...", text: $searchPhrase,
                prompt: Text("Search for reminders...")
            )
            .textFieldStyle(.roundedBorder)
            .padding(5)

            List(
                !searchPhrase.isEmpty
                    ? (searchResult ?? []) : (reminders ?? []),
                id: \.calendarItemIdentifier
            ) { reminder in
                let title = reminder.title ?? "No Title"
                let identifier = Text(String(reminder.calendarItemIdentifier))
                    .foregroundColor(.secondary)

                HStack(alignment: .top) {
                    if reminder.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                    } else {
                        Image(systemName: "circle")
                    }

                    VStack(alignment: .leading) {
                        Text(
                            "\(title) \(identifier)"
                        )
                        .font(.headline)

                        if let dueDate = reminder.dueDateComponents?.date {
                            Text("Due: \(formattedDate(dueDate))")
                        } else {
                            Text("No due date")
                        }

                        if reminder.hasRecurrenceRules {
                            Text(
                                "Recurrence: \(reminder.recurrenceRules.debugDescription)"
                            )
                        }

                        Text(reminder.debugDescription)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }.task {
                let reminders = try? await remindersInterface.fetchReminders()

                if let reminders {
                    self.reminders = reminders
                }
            }.onChange(of: searchPhrase) { _, newValue in
                if !newValue.isEmpty {
                    self.searchResult = reminders?.filter({
                        $0.title.lowercased().contains(newValue.lowercased())
                    })
                }
            }.textSelection(.enabled)
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
    DebugView()
}
