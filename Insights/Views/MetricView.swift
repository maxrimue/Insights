//
//  MetricView.swift
//  Insights
//
//  Created by Max Rittmüller on 28.01.25.
//

import Charts
import SwiftUI

struct ChartDataEntry {
    var id: UUID = UUID()
    var xAxis: Date
    var xAxisDescriptor: String
    var yAxis: Int
    var yAxisDescriptor: String
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
            Chart(chartData, id: \.id) {
                LineMark(
                    x: .value($0.xAxisDescriptor, $0.xAxis),
                    y: .value($0.yAxisDescriptor, $0.yAxis)

                )
                .lineStyle(StrokeStyle(lineWidth: 2))
                .foregroundStyle(.tint)
                .interpolationMethod(.linear)
                //                .interpolationMethod(.cardinal)
                //                .symbolSize(50)
                //                .symbol(Circle().strokeBorder(lineWidth: 1))
                .symbol(.circle)
            }
            .frame(height: 80)
            .chartYAxis(.visible)
            .chartXAxis(.visible)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 1)) {
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))

                    AxisGridLine()
                    AxisTick()
                }
            }

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
    let today = Calendar.current.startOfDay(for: Date())
    let exampleChartData: [ChartDataEntry] = [
        ChartDataEntry(
            xAxis: today,
            xAxisDescriptor: "Day",
            yAxis: 12,
            yAxisDescriptor: "Due tasks"),
        ChartDataEntry(
            xAxis: Calendar.current.date(byAdding: .day, value: 1, to: today)!,
            xAxisDescriptor: "Day",
            yAxis: 9,
            yAxisDescriptor: "Due tasks"),
    ]

    return MetricView(
        chartData: exampleChartData,
        description: "Of tasks due for each day"
    )
    .padding()
    .frame(width: 180)
}
