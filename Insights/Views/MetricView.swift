//
//  MetricView.swift
//  Insights
//
//  Created by Max Rittmüller on 28.01.25.
//

import SwiftUI

struct MetricView: View {
    var metric: String
    var metricDescription: String
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                Text(metric)
                    .font(.title)
                    .monospacedDigit()
            }
            
            Text(metricDescription)
        }
    }
}

#Preview {
    MetricView(metric: "87%", metricDescription: "Of tasks completed for today")
        .padding()
        .frame(width: 180)
}
