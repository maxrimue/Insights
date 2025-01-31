//
//  ContentView.swift
//  Insights
//
//  Created by Max on 20.01.25.
//

import EventKit
import SwiftUI

struct ContentView: View {
    @State var reminders: [EKReminder]?
    @State var remindersRatioComplete: Double?
    @State var errorMsg: String?

    var remindersInterface = RemindersInterface()

    var body: some View {
        let remindersRatioComplete =
            remindersInterface.getRatioOfTasksCompleted(
                reminders: reminders ?? [])
        let remindersPercentageDone = remindersRatioComplete.formatted(
            .percent.precision(.fractionLength(0)))
        let remindersOverdue = remindersInterface.getOverdueTasks(
            reminders: reminders ?? [])

        VStack {
            if errorMsg != nil {
                Text(errorMsg!).foregroundStyle(.red)
            } else {
                MetricView(
                    metric: String(remindersPercentageDone),
                    metricDescription: "Of reminders due today are done."
                )
                .padding()
                .background(MetricBackground())

                MetricView(
                    metric: String(remindersOverdue),
                    metricDescription: "Tasks overdue today."
                )
                .padding()
                .background(MetricBackground())
            }
        }.frame(width: 200)
            .padding()
            .task {
                do {
                    self.reminders = try await self.remindersInterface
                        .fetchReminders()
                } catch {
                    errorMsg = error.localizedDescription
                }
            }
    }
}

struct MetricBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.1))
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
                byAdding: .day, value: -1, to: Date())!, completionDate: nil)
    ])

    let remindersInterface = Insights.RemindersInterface()
    remindersInterface.eventStore = mockEventStore

    return ContentView(remindersInterface: remindersInterface)
}
