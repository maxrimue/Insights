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

        var ratioOfTasksCompleted: [Double?] = []
        var cancellables: Set<AnyCancellable> = []
        let remindersInterface = Insights.RemindersInterface(
            eventStore: mockEventStore)

        #expect(remindersInterface.ratioOfTasksCompleted == nil)

        remindersInterface.$ratioOfTasksCompleted
            .sink { value in
                ratioOfTasksCompleted.append(value)
            }
            .store(in: &cancellables)

        try await remindersInterface.fetchReminders()

        #expect(ratioOfTasksCompleted.count == 2)
        #expect(ratioOfTasksCompleted.elementsEqual([nil, 0.4]))
    }

    @Test func getCountOfOverdueTasks() async throws {
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

        var countOfOverdueTasks: [Int?] = []
        var cancellables: Set<AnyCancellable> = []
        let remindersInterface = Insights.RemindersInterface(
            eventStore: mockEventStore)

        #expect(remindersInterface.countOfOverdueTasks == nil)

        remindersInterface.$countOfOverdueTasks
            .sink { value in
                countOfOverdueTasks.append(value)
            }
            .store(in: &cancellables)

        try await remindersInterface.fetchReminders()

        #expect(countOfOverdueTasks.count == 2)
        #expect(countOfOverdueTasks.elementsEqual([nil, 1]))
    }

    @Test func getCountsOfTasksCompletedByDay() async throws {
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

        var countsOfTasksCompletedByDayValues: [[Date: Int]?] = []
        var cancellables: Set<AnyCancellable> = []
        let remindersInterface = Insights.RemindersInterface(
            eventStore: mockEventStore)

        #expect(remindersInterface.countsOfTasksCompletedByDay == nil)

        remindersInterface.$countsOfTasksCompletedByDay
            .sink { value in
                countsOfTasksCompletedByDayValues.append(value)
            }
            .store(in: &cancellables)

        try await remindersInterface.fetchReminders()

        let result =
            countsOfTasksCompletedByDayValues.indices.contains(1)
            ? countsOfTasksCompletedByDayValues[1] : nil

        #expect(countsOfTasksCompletedByDayValues.count == 2)
        #expect(result != nil)
        #expect(
            result?.first(where: { (key: Date, value: Int) in
                return key == getDate(daysOffset: -1) && value == 2
            }) != nil)

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
