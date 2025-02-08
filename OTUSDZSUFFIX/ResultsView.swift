//
//  ResultsView.swift
//  OTUSDZSUFFIX
//
//  Created by Вячеслав Вовк on 08.02.2025.
//
import SwiftUI

// Экран с результатами анализа
struct ResultsView: View {
    let job: SuffixSearchJobModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Суффиксы:")
                .font(.headline)
            
            List(job.suffixes, id: \.self) { suffix in
                Text(suffix)
            }
            
            Text("Статистика совпадений:")
                .font(.headline)
            
            List {
                ForEach(job.statistics.keys.sorted(), id: \.self) { key in
                    Text("\(key) – \(job.statistics[key]!)")
                }
            }
        }
        .navigationTitle("Результаты для '\(job.text)'")
        .padding()
    }
}


#Preview {
    ResultsView(job: SuffixSearchJobModel(text: "abra", suffixes: ["abra", "abeacaed"] , statistics: ["abra": 1, "abr": 3], executionTime: 2))
}
