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
    }
    
    func createMockEventStoreWithReminders() -> MockEventStore {
        let mockEventStore = MockEventStore()
        
        let mockReminder1 = EKReminder(eventStore: mockEventStore)
        mockReminder1.title = "Reminder 1"
        mockReminder1.isCompleted = true
        mockReminder1.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: today)
        mockReminder1.completionDate = today
        
        let mockReminder2 = EKReminder(eventStore: mockEventStore)
        mockReminder2.title = "Reminder 2"
        mockReminder2.isCompleted = false
        mockReminder2.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: today)
        mockReminder2.completionDate = nil
        
        let mockReminder3 = EKReminder(eventStore: mockEventStore)
        mockReminder3.title = "Reminder 3"
        mockReminder3.isCompleted = true
        mockReminder3.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: yesterday)
        mockReminder3.completionDate = today

        let mockReminder4 = EKReminder(eventStore: mockEventStore)
        mockReminder4.title = "Reminder 4"
        mockReminder4.isCompleted = true
        mockReminder4.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: yesterday)
        mockReminder4.completionDate = yesterday
        
        let mockReminder5 = EKReminder(eventStore: mockEventStore)
        mockReminder5.title = "Reminder 5"
        mockReminder5.isCompleted = false
        mockReminder5.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: yesterday)
        
        mockEventStore.mockReminders = [mockReminder1, mockReminder2, mockReminder3, mockReminder4, mockReminder5]
        
        return mockEventStore
    }
    
    @Test func getPercentageOfTasksCompleted() async throws {
        let mockEventStore = createMockEventStoreWithReminders()
        
        let remindersInterface = Insights.RemindersInterface()
        remindersInterface.eventStore = mockEventStore
        
        let result = try await remindersInterface.getPercentageOfTasksCompleted()
        
        #expect(result == 0.5)
    }
    
}
