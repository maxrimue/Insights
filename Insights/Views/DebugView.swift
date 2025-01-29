//
//  DebugView.swift
//  Insights
//
//  Created by Max Rittmüller on 29.01.25.
//

import SwiftUI
import EventKit

struct DebugView: View {
    @State var reminders: [EKReminder]?
    @State var searchResult: [EKReminder]?
    @State var searchPhrase: String = ""
    let remindersInterface = RemindersInterface()
    
    var body: some View {
        VStack {
            TextField("Search for reminders...", text: $searchPhrase, prompt: Text("Search for reminders..."))
                .textFieldStyle(.roundedBorder)
                .padding(5)
            
            
            List(!searchPhrase.isEmpty ? (searchResult ?? []) : (reminders ?? []), id: \.calendarItemIdentifier) { reminder in
                HStack(alignment: .top) {
                    reminder.isCompleted ? Image(systemName: "checkmark.circle.fill") : Image(systemName: "circle")
                    
                    VStack(alignment: .leading) {
                        Text("\(reminder.title ?? "No Title") \(Text(String(reminder.calendarItemIdentifier)).foregroundColor(.secondary))")
                            .font(.headline)
                        
                        if let dueDate = reminder.dueDateComponents?.date {
                            Text("Due: \(formattedDate(dueDate))")
                        } else {
                            Text("No due date")
                        }
                        
                        Text(reminder.debugDescription)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }.task {
                if let reminders = try? await remindersInterface.fetchReminders() {
                    self.reminders = reminders
                }
            }.onChange(of: searchPhrase) { oldValue, newValue in
                if !newValue.isEmpty {
                    self.searchResult = reminders?.filter({ $0.title.lowercased().contains(newValue.lowercased())
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
