//
//  RemindersInterface.swift
//  Insights
//
//  Created by Max on 20.01.25.
//

import EventKit

class RemindersInterface {
    var eventStore = EKEventStore()
    
    func isDateInToday(_ date: Date?) -> Bool {
        guard let date = date else {
            return false
        }
        
        return Calendar.current.isDateInToday(date)
    }
    
    func isDateInOrBeforeToday(_ date: Date?) -> Bool {
        guard let date = date else {
            return false
        }
        
        return date <= Date()
    }
    
    func getPercentageOfTasksCompleted() async throws -> Double {
        let reminders = try await fetchReminders() ?? []
        
        let remindersDueToday = reminders.filter({ isDateInOrBeforeToday($0.dueDateComponents?.date) && $0.isCompleted == false })
        let remindersDoneToday = reminders.filter({ isDateInToday($0.completionDate) })
        
        let totalRemindersApplicableForToday = remindersDueToday.count + remindersDoneToday.count
        
        return Double(remindersDoneToday.count) / Double(totalRemindersApplicableForToday)
    }
    
    func fetchReminders() async throws -> [EKReminder]? {
        if (ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1") {
            return nil
        }
        
        let granted = try await eventStore.requestFullAccessToReminders()
        
        guard granted else {
            let accessError = NSError(domain: "RemindersFetcher", code: 1, userInfo: [NSLocalizedDescriptionKey: "Access to reminders was not granted"])
            
            throw accessError
        }
        
        // Fetch reminders
        let predicate = self.eventStore.predicateForReminders(in: nil)
        return await withCheckedContinuation { continuation in
            self.eventStore.fetchReminders(matching: predicate) { reminders in
                continuation.resume(returning: reminders)
            }
        }
    }
}
