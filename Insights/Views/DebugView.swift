//
//  DebugView.swift
//  Insights
//
//  Created by Max Rittmüller on 29.01.25.
//

import EventKit
import SwiftUI

struct DebugView: View {
    @State var searchResult: [EKReminder]?
    @State var searchPhrase: String = ""
    @EnvironmentObject var remindersInterface: RemindersInterface

    var body: some View {
        VStack {
            HStack {
                TextField(
                    "Search for reminders...", text: $searchPhrase,
                    prompt: Text("Search for reminders...")
                )
                .textFieldStyle(.roundedBorder)

                Button {
                    Task {
                        try await remindersInterface.fetchReminders()
                    }
                } label: {
                    Text("Fetch Reminders")
                }
            }.padding(5)

            List(
                !searchPhrase.isEmpty
                    ? (searchResult ?? []) : (remindersInterface.reminders),
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
            }.onChange(of: searchPhrase) { _, newValue in
                if !newValue.isEmpty {
                    self.searchResult = remindersInterface.reminders.filter({
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
    let mockEventStore = createMockEventStore(withReminders: [
        MockReminder(dueDate: Date(), completionDate: Date()),
        MockReminder(dueDate: Date(), completionDate: nil),
        MockReminder(
            dueDate: Calendar.current.date(
                byAdding: .day, value: -1, to: Date())!, completionDate: Date()),
        MockReminder(
            dueDate: Calendar.current.date(
                byAdding: .day, value: -1, to: Date())!, completionDate: nil),
    ])

    return DebugView().environmentObject(
        RemindersInterface(eventStore: mockEventStore))
}
