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
    
    class MockEventStore: EKEventStore {
        var mockReminders: [EKReminder] = []
        
        override func predicateForReminders(in calendars: [EKCalendar]?) -> NSPredicate {
            return NSPredicate(value: true) // Return a basic predicate
        }
        
        override func fetchReminders(matching predicate: NSPredicate, completion: @escaping ([EKReminder]?) -> Void) -> Any {
            completion(mockReminders)
        }
        
        override func requestFullAccessToReminders() async throws -> Bool {
            true
        }
    }
    
    func createMockReminder(ForEventStore eventStore: EKEventStore, title: String, dueDate: Date?, completionDate: Date?) -> EKReminder {
        let mockReminder = EKReminder(eventStore: eventStore)
        mockReminder.title = title
        mockReminder.isCompleted = completionDate != nil
        
        if let dueDate = dueDate {
            /// Creates a reminder pinned to hour/minute of day. Leave out to create an all-day reminder.
            mockReminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
        }
        
        if let completionDate = completionDate {
            mockReminder.completionDate = completionDate
        }
        
        return mockReminder
    }
    
    struct MockReminder {
        let dueDate: Date?
        let completionDate: Date?
    }
    
    func createMockEventStore(withReminders reminders: [MockReminder]) -> MockEventStore {
        let mockEventStore = MockEventStore()
        let mockReminders = reminders.enumerated().map { index, reminder in createMockReminder(ForEventStore: mockEventStore, title: "Mock Reminder \(index + 1)", dueDate: reminder.dueDate, completionDate: reminder.completionDate) }

        mockEventStore.mockReminders = mockReminders
        
        return mockEventStore
    }
    
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
