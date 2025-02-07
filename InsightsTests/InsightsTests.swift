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
    private func getDate(daysOffset days: Int = 0, hoursOffset hours: Int = 0) -> Date {
        var date = Calendar.current.startOfDay(for: Date())
        
        date = Calendar.current.date(byAdding: .day, value: days, to: date)!
        date = Calendar.current.date(byAdding: .hour, value: hours, to: date)!
        return date
    }
    
    @Test func getRatioOfTasksCompleted() async throws {
        let mockEventStore = createMockEventStore(withReminders: [
            MockReminder(dueDate: getDate(), completionDate: getDate()),
            MockReminder(dueDate: getDate(), completionDate: nil),
            MockReminder(dueDate: getDate(daysOffset: -1), completionDate: getDate()),
            MockReminder(dueDate: getDate(daysOffset: -1), completionDate: getDate(daysOffset: -1)),
            MockReminder(dueDate: getDate(daysOffset: -1), completionDate: nil),
            MockReminder(dueDate: getDate(hoursOffset: 1), completionDate: nil)
        ])
        
        let remindersInterface = Insights.RemindersInterface()
        remindersInterface.eventStore = mockEventStore
        
        let reminders = try await remindersInterface.fetchReminders()!
        let result = remindersInterface.getRatioOfTasksCompleted(reminders: reminders)
        
        #expect(result.isEqual(to: 0.4))
    }
    
    @Test func getOverdueTasks() async throws {
        let mockEventStore = createMockEventStore(withReminders: [
            MockReminder(dueDate: getDate(), completionDate: getDate()),
            MockReminder(dueDate: getDate(), completionDate: nil),
            MockReminder(dueDate: getDate(daysOffset: -1), completionDate: getDate()),
            MockReminder(dueDate: getDate(daysOffset: -1), completionDate: getDate(daysOffset: -1)),
            MockReminder(dueDate: getDate(daysOffset: -1), completionDate: nil),
            MockReminder(dueDate: getDate(hoursOffset: 1), completionDate: nil)
        ])
        
        let remindersInterface = Insights.RemindersInterface()
        remindersInterface.eventStore = mockEventStore
        
        let reminders = try await remindersInterface.fetchReminders()!
        let result = remindersInterface.getOverdueTasks(reminders: reminders)
        
        #expect(result == 1)
    }
    
    @Test func getDueTasksForLastSevenDays() async throws {
        let mockEventStore = createMockEventStore(withReminders: [
            MockReminder(dueDate: getDate(daysOffset: -7), completionDate: nil),
            MockReminder(dueDate: getDate(daysOffset: -6), completionDate: getDate(daysOffset: -6)),
            MockReminder(dueDate: getDate(daysOffset: -5), completionDate: getDate(daysOffset: -5)),
            MockReminder(dueDate: getDate(daysOffset: -4), completionDate: getDate(daysOffset: -2)),
            MockReminder(dueDate: getDate(daysOffset: -4), completionDate: getDate(daysOffset: -2)),
            MockReminder(dueDate: getDate(daysOffset: -3), completionDate: getDate(daysOffset: -1)),
            MockReminder(dueDate: getDate(daysOffset: -2), completionDate: getDate(daysOffset: -1)),
            MockReminder(dueDate: getDate(daysOffset: -1), completionDate: nil),
            MockReminder(dueDate: getDate(daysOffset: -1), completionDate: getDate(daysOffset: -1)),
            MockReminder(dueDate: getDate(), completionDate: nil),
            MockReminder(dueDate: getDate(daysOffset: 1), completionDate: nil)
        ])
        
        let remindersInterface = Insights.RemindersInterface()
        remindersInterface.eventStore = mockEventStore
        
        let reminders = try await remindersInterface.fetchReminders()!
        let result = remindersInterface.getDueTasksForLastSevenDays(reminders: reminders)
        
        print(result)
        #expect(result[getDate()] == 1)
    }
}
