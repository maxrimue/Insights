//
//  InsightsTests.swift
//  InsightsTests
//
//  Created by Max on 20.01.25.
//

import Testing
@testable import Insights

import EventKit

struct InsightsTests {
    private let today = Date()
    private let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    
    @Test func getRatioOfTasksCompleted() async throws {
        let mockEventStore = createMockEventStore(withReminders: [
            MockReminder(dueDate: today, completionDate: today),
            MockReminder(dueDate: today, completionDate: nil),
            MockReminder(dueDate: yesterday, completionDate: today),
            MockReminder(dueDate: yesterday, completionDate: yesterday),
            MockReminder(dueDate: yesterday, completionDate: nil),
            MockReminder(dueDate: Calendar.current.date(byAdding: .hour, value: 1, to: today), completionDate: nil)
        ])
        
        let remindersInterface = Insights.RemindersInterface()
        remindersInterface.eventStore = mockEventStore
        
        let reminders = try await remindersInterface.fetchReminders()!
        let result = remindersInterface.getRatioOfTasksCompleted(reminders: reminders)
        
        #expect(result.isEqual(to: 0.4))
    }
    
    @Test func getOverdueTasks() async throws {
        let mockEventStore = createMockEventStore(withReminders: [
            MockReminder(dueDate: today, completionDate: today),
            MockReminder(dueDate: today, completionDate: nil),
            MockReminder(dueDate: yesterday, completionDate: today),
            MockReminder(dueDate: yesterday, completionDate: yesterday),
            MockReminder(dueDate: yesterday, completionDate: nil),
            MockReminder(dueDate: Calendar.current.date(byAdding: .hour, value: 1, to: today), completionDate: nil)
        ])
        
        let remindersInterface = Insights.RemindersInterface()
        remindersInterface.eventStore = mockEventStore
        
        let reminders = try await remindersInterface.fetchReminders()!
        let result = remindersInterface.getOverdueTasks(reminders: reminders)
        
        #expect(result == 1)
    }
}
