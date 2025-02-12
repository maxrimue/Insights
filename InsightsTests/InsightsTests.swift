//
//  InsightsTests.swift
//  InsightsTests
//
//  Created by Max on 20.01.25.
//

import Combine
import EventKit
import Testing

@testable import Insights

struct InsightsTests {
    private func getDate(daysOffset days: Int = 0, hoursOffset hours: Int = 0)
        -> Date
    {
        var date = Calendar.current.startOfDay(for: Date())

        date = Calendar.current.date(byAdding: .day, value: days, to: date)!
        date = Calendar.current.date(byAdding: .hour, value: hours, to: date)!
        return date
    }

    @Test func getRatioOfTasksCompleted() async throws {
        let mockEventStore = createMockEventStore(withReminders: [
            MockReminder(dueDate: getDate(), completionDate: getDate()),
            MockReminder(dueDate: getDate(), completionDate: nil),
            MockReminder(
                dueDate: getDate(daysOffset: -1), completionDate: getDate()),
            MockReminder(
                dueDate: getDate(daysOffset: -1),
                completionDate: getDate(daysOffset: -1)),
            MockReminder(dueDate: getDate(daysOffset: -1), completionDate: nil),
            MockReminder(dueDate: getDate(hoursOffset: 1), completionDate: nil),
            MockReminder(dueDate: nil, completionDate: getDate()),
        ])

        let remindersInterface = Insights.RemindersInterface(
            eventStore: mockEventStore)

        try await remindersInterface.fetchReminders()
        let result = remindersInterface.getRatioOfTasksCompleted()

        #expect(result.isEqual(to: 0.4))
    }

    @Test func getOverdueTasks() async throws {
        let mockEventStore = createMockEventStore(withReminders: [
            MockReminder(dueDate: getDate(), completionDate: getDate()),
            MockReminder(dueDate: getDate(), completionDate: nil),
            MockReminder(
                dueDate: getDate(daysOffset: -1), completionDate: getDate()),
            MockReminder(
                dueDate: getDate(daysOffset: -1),
                completionDate: getDate(daysOffset: -1)),
            MockReminder(dueDate: getDate(daysOffset: -1), completionDate: nil),
            MockReminder(dueDate: getDate(hoursOffset: 1), completionDate: nil),
        ])

        let remindersInterface = Insights.RemindersInterface(
            eventStore: mockEventStore)

        try await remindersInterface.fetchReminders()
        let result = remindersInterface.getOverdueTasks()

        #expect(result == 1)
    }

    @Test func getDueTasksForLastSevenDays() async throws {
        let mockEventStore = createMockEventStore(withReminders: [
            MockReminder(dueDate: getDate(daysOffset: -7), completionDate: nil),
            MockReminder(
                dueDate: getDate(daysOffset: -6),
                completionDate: getDate(daysOffset: -6)),
            MockReminder(
                dueDate: getDate(daysOffset: -5),
                completionDate: getDate(daysOffset: -5)),
            MockReminder(
                dueDate: getDate(daysOffset: -4),
                completionDate: getDate(daysOffset: -2)),
            MockReminder(
                dueDate: getDate(daysOffset: -4),
                completionDate: getDate(daysOffset: -2)),
            MockReminder(
                dueDate: getDate(daysOffset: -3),
                completionDate: getDate(daysOffset: -1)),
            MockReminder(
                dueDate: getDate(daysOffset: -2),
                completionDate: getDate(daysOffset: -1)),
            MockReminder(dueDate: getDate(daysOffset: -1), completionDate: nil),
            MockReminder(
                dueDate: getDate(daysOffset: -1),
                completionDate: getDate(daysOffset: -1)),
            MockReminder(dueDate: getDate(), completionDate: nil),
            MockReminder(dueDate: getDate(daysOffset: 1), completionDate: nil),
        ])

        let remindersInterface = Insights.RemindersInterface(
            eventStore: mockEventStore)

        try await remindersInterface.fetchReminders()
        let result = remindersInterface.getDueTasksForLastSevenDays()

        #expect(result[getDate()] == 1)
    }

    @Test func setsLoadingState() async throws {
        let mockEventStore = createMockEventStore(withReminders: [
            MockReminder(dueDate: getDate(daysOffset: -7), completionDate: nil),
            MockReminder(
                dueDate: getDate(daysOffset: -6),
                completionDate: getDate(daysOffset: -6)),
            MockReminder(
                dueDate: getDate(daysOffset: -5),
                completionDate: getDate(daysOffset: -5)),
            MockReminder(
                dueDate: getDate(daysOffset: -4),
                completionDate: getDate(daysOffset: -2)),
            MockReminder(
                dueDate: getDate(daysOffset: -4),
                completionDate: getDate(daysOffset: -2)),
            MockReminder(
                dueDate: getDate(daysOffset: -3),
                completionDate: getDate(daysOffset: -1)),
            MockReminder(
                dueDate: getDate(daysOffset: -2),
                completionDate: getDate(daysOffset: -1)),
            MockReminder(dueDate: getDate(daysOffset: -1), completionDate: nil),
            MockReminder(
                dueDate: getDate(daysOffset: -1),
                completionDate: getDate(daysOffset: -1)),
            MockReminder(dueDate: getDate(), completionDate: nil),
            MockReminder(dueDate: getDate(daysOffset: 1), completionDate: nil),
        ])

        var isLoadingValues: [Bool] = []
        var cancellables: Set<AnyCancellable> = []
        let remindersInterface = Insights.RemindersInterface(
            eventStore: mockEventStore)

        // check isLoading on initialization
        #expect(remindersInterface.isLoading == false)

        remindersInterface.$isLoading
            .sink { value in
                isLoadingValues.append(value)
            }
            .store(in: &cancellables)

        try await remindersInterface.fetchReminders()

        #expect(isLoadingValues.count == 3)
        #expect(isLoadingValues.elementsEqual([false, true, false]))

        #expect(remindersInterface.reminders.isEmpty == false)
    }
}
