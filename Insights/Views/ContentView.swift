//
//  ContentView.swift
//  Insights
//
//  Created by Max on 20.01.25.
//

import EventKit
import SwiftUI

struct ContentView: View {
    @State var remindersRatioComplete: Double?
    @State var errorMsg: String?

    @Environment(\.openWindow) var openWindow
    @EnvironmentObject var remindersInterface: RemindersInterface

    func getPercentageOfCompletedTasks(_ ratio: Double?) -> String? {
        guard let ratio = ratio else {
            return nil
        }

        return ratio.formatted(
            .percent.precision(.fractionLength(0)))
    }

    func mapOverdueRemindersToChart(_ overdueReminders: [Date: Int]?)
        -> [ChartDataEntry]?
    {
        guard let overdueReminders = overdueReminders else {
            return nil
        }

        return overdueReminders.sorted {
            $0.key < $1.key
        }.map { (key: Date, value: Int) in
            ChartDataEntry(
                xAxis: key, xAxisDescriptor: "Day", yAxis: value,
                yAxisDescriptor: "Count")
        }
    }

    var body: some View {
        let remindersPercentageDone =
            getPercentageOfCompletedTasks(
                remindersInterface.ratioOfTasksCompleted) ?? "--"
        let remindersOverdue =
            remindersInterface.countOfOverdueTasks != nil
            ? String(remindersInterface.countOfOverdueTasks!) : "--"
        let remindersCountPastSevenDays = mapOverdueRemindersToChart(
            remindersInterface.countsOfTasksCompletedByDay)

        ZStack {
            if remindersInterface.isLoading == true {
                ProgressView()
            }

            VStack(spacing: 10) {
                #if DEBUG
                    HStack {
                        Spacer()

                        Button("Open Debug View") {
                            openWindow(id: "debug")
                        }.disabled(remindersInterface.isLoading)

                    }
                #endif

                if errorMsg != nil {
                    Text(errorMsg!).foregroundStyle(.red)
                } else {
                    HStack(spacing: 10) {
                        MetricView(
                            text: remindersPercentageDone,
                            description: "Of reminders due today are done"
                        )
                        .padding()
                        .background(MetricBackground())

                        MetricView(
                            text: String(remindersOverdue),
                            description: "Tasks overdue today"
                        )
                        .padding()
                        .background(MetricBackground())
                    }

                    MetricView(
                        chartData: remindersCountPastSevenDays ?? [],
                        description:
                            "Due reminders per day over the last seven days"
                    )
                    .padding()
                    .background(MetricBackground())
                }
            }
            .blendMode(remindersInterface.isLoading == true ? .color : .normal)
        }
        .frame(width: 300)
        .padding()
        .task {
            do {
                try await self.remindersInterface
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
                byAdding: .day, value: -1, to: Date())!, completionDate: nil),
    ])

    return ContentView().environmentObject(
        RemindersInterface(eventStore: mockEventStore))
}
