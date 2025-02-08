//
//  HistoryScreen.swift
//  OTUSDZSUFFIX
//
//  Created by Вячеслав Вовк on 08.02.2025.
//

import SwiftUI

struct HistoryScreen: View {
    
    @EnvironmentObject var jobManager: JobQueueManager
    
    var body: some View {
        List {
            ForEach(jobManager.history) { item in
                NavigationLink {
                    ResultsView(job: item)
                } label: {
                    HStack {
                        Text(item.text)
                        Spacer()
                        Text(item.executionTime.description)
                    }
                }
            }
        }
    }
}

#Preview {
    HistoryScreen()
        .environmentObject(JobQueueManager())
}
