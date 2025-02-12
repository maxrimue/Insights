//
//  RemindersInterface.swift
//  Insights
//
//  Created by Max on 20.01.25.
//

import EventKit

class RemindersInterface: ObservableObject {
    @Published var reminders: [EKReminder] = []
    @Published var isLoading: Bool = false
    var eventStore: EKEventStore

    init(eventStore: EKEventStore?) {
        self.eventStore = eventStore ?? EKEventStore()
    }

    init() {
        self.eventStore = EKEventStore()
    }

    func isDateInToday(_ date: Date?) -> Bool {
        guard let date = date else {
            return false
        }

        return Calendar.current.isDateInToday(date)
    }

    func isDateBeforeToday(_ date: Date?) -> Bool {
        guard let date = date else {
            return false
        }

        return date < Date() && !Calendar.current.isDateInToday(date)
    }

    func isDateInOrBeforeToday(_ date: Date?) -> Bool {
        isDateBeforeToday(date) || isDateInToday(date)
    }

    func getNormalizedDate(forDaysInFuture days: Int = 0) -> Date {
        let targetDate = Calendar.current.date(
            byAdding: .day, value: days, to: Date())!
        return Calendar.current.startOfDay(for: targetDate)
    }

    func getNormalizedDate(forDateComponents dateComponents: DateComponents)
        -> Date
    {
        let targetDate = Calendar.current.date(from: dateComponents)!
        return Calendar.current.startOfDay(for: targetDate)
    }

    func getRatioOfTasksCompleted() -> Double {
        let remindersDueToday = reminders.filter({
            isDateInOrBeforeToday($0.dueDateComponents?.date)
                && $0.isCompleted == false
        })

        let remindersDoneToday = reminders.filter({
            isDateInToday($0.completionDate) && $0.dueDateComponents != nil
        })

        let totalRemindersApplicableForToday =
            remindersDueToday.count + remindersDoneToday.count

        return Double(remindersDoneToday.count)
            / Double(totalRemindersApplicableForToday)
    }

    func getOverdueTasks() -> Int {
        reminders.filter({
            isDateBeforeToday($0.dueDateComponents?.date)
                && $0.isCompleted == false
        }).count
    }

    func getDueTasksForLastSevenDays() -> [Date: Int] {
        let today = getNormalizedDate()
        let pastDays = (0..<7).map {
            Calendar.current.date(byAdding: .day, value: -$0, to: today)!
        }
        var result: [Date: Int] = Dictionary(
            uniqueKeysWithValues: pastDays.map { ($0, 0) })

        reminders.forEach { reminder in
            if let dueDateComponents = reminder.dueDateComponents {
                let normalizedDueDate = getNormalizedDate(
                    forDateComponents: dueDateComponents)
                if result.keys.contains(normalizedDueDate) {
                    result[normalizedDueDate, default: 0] += 1
                }
            }
        }

        return result
    }

    func fetchReminders() async throws {
        await updateIsLoading(true)
        let granted = try await eventStore.requestFullAccessToReminders()

        guard granted else {
            let accessError = NSError(
                domain: "RemindersFetcher", code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Access to reminders was not granted"
                ])

            throw accessError
        }

        let predicate = self.eventStore.predicateForReminders(in: nil)
        let fetchedReminders =
            await withCheckedContinuation { continuation in
                self.eventStore.fetchReminders(matching: predicate) {
                    reminders in
                    continuation.resume(returning: reminders)
                }
            } ?? []

        await updateReminders(reminders: fetchedReminders)
        await updateIsLoading(false)
    }

    @MainActor
    func updateReminders(reminders: [EKReminder]) {
        self.reminders = reminders
    }

    @MainActor
    func updateIsLoading(_ isLoading: Bool) {
        self.isLoading = isLoading
    }
}

class MockEventStore: EKEventStore {
    var mockReminders: [EKReminder] = []

    override func predicateForReminders(in calendars: [EKCalendar]?)
        -> NSPredicate
    {
        return NSPredicate(value: true)
    }

    override func fetchReminders(
        matching predicate: NSPredicate,
        completion: @escaping ([EKReminder]?) -> Void
    ) -> Any {
        completion(mockReminders)
    }

    override func requestFullAccessToReminders() async throws -> Bool {
        true
    }
}

func createMockEventStore(withReminders reminders: [MockReminder])
    -> MockEventStore
{
    let mockEventStore = MockEventStore()
    let mockReminders = reminders.enumerated().map { index, reminder in
        createMockReminder(
            ForEventStore: mockEventStore, title: "Mock Reminder \(index + 1)",
            dueDate: reminder.dueDate, completionDate: reminder.completionDate)
    }

    mockEventStore.mockReminders = mockReminders

    return mockEventStore
}

struct MockReminder {
    let dueDate: Date?
    let completionDate: Date?
}

func createMockReminder(
    ForEventStore eventStore: EKEventStore, title: String, dueDate: Date?,
    completionDate: Date?
) -> EKReminder {
    let mockReminder = EKReminder(eventStore: eventStore)
    mockReminder.title = title
    mockReminder.isCompleted = completionDate != nil

    if let dueDate = dueDate {
        /// Creates a reminder pinned to hour/minute of day. Leave out to create an all-day reminder.
        mockReminder.dueDateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute], from: dueDate)
    }

    if let completionDate = completionDate {
        mockReminder.completionDate = completionDate
    }

    return mockReminder
}
