//
//  MetricView.swift
//  Insights
//
//  Created by Max Rittmüller on 28.01.25.
//

import Charts
import SwiftUI

struct ChartDataEntry {
    var time: Date
    var count: Int
}

private struct MetricTextView: View {
    var text: String
    var description: String

    var body: some View {
        VStack(spacing: 5) {
            HStack {
                Spacer()

                Text(text)
                    .font(.title)
                    .monospacedDigit()
            }

            Text(description)
                .foregroundStyle(.secondary)
        }
    }
}

private struct MetricChartView: View {
    var chartData: [ChartDataEntry]
    var description: String

    var body: some View {
        VStack(spacing: 5) {
            Chart(chartData, id: \.time) {
                LineMark(
                    x: .value("Date", $0.time),
                    y: .value("Count", $0.count)
                )
                .lineStyle(StrokeStyle(lineWidth: 2))
                .foregroundStyle(.tint)
                .interpolationMethod(.cardinal)
                .symbolSize(10)
            }
            .frame(height: 80)
            .chartYAxis(.visible)
            .chartXAxis(.hidden)

            Text(description)
                .foregroundStyle(.secondary)
        }
    }
}

struct MetricView: View {
    var text: String?
    var chartData: [ChartDataEntry]?
    var description: String

    init(text: String, description: String) {
        self.text = text
        self.description = description
    }

    init(chartData: [ChartDataEntry], description: String) {
        self.chartData = chartData
        self.description = description
    }

    var body: some View {
        if let text = text {
            MetricTextView(text: text, description: description)
        } else if let chartData = chartData {
            MetricChartView(chartData: chartData, description: description)
        }
    }
}

#Preview("Text") {
    MetricView(
        text: "87%", description: "Of tasks completed for today"
    )
    .padding()
    .frame(width: 180)
}

#Preview("Chart") {
    let exampleChartData: [ChartDataEntry] = [
        ChartDataEntry(
            time: Calendar.current.date(
                byAdding: .day, value: -3, to: Date())!, count: 1),
        ChartDataEntry(
            time: Calendar.current.date(
                byAdding: .day, value: -2, to: Date())!, count: 3),
        ChartDataEntry(
            time: Calendar.current.date(
                byAdding: .day, value: -1, to: Date())!, count: 2),
        ChartDataEntry(time: Date(), count: 4),
    ]

    return MetricView(
        chartData: exampleChartData,
        description: "Of tasks due for each day"
    )
    .padding()
    .frame(width: 180)
}
