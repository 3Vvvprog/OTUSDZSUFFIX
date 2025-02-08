//
//  ContentView.swift
//  OTUSDZSUFFIX
//
//  Created by Вячеслав Вовк on 08.02.2025.
//

import SwiftUI
import Combine

enum SelectionType: CaseIterable, Identifiable {
    case all, top
    
    var title: String {
        switch self {
        case .all:
            "All"
        case .top:
            "Top"
        }
    }
    
    var id: SelectionType { self }
}

func createSuffixArray(from string: String) -> [String] {
    let suffixes = string.indices.map { string.suffix(from: $0) }
    
    let suffixArray = suffixes.map { String($0) }
    
    return suffixArray.sorted()
}

func longestCommonPrefix(_ s1: String, _ s2: String) -> String {
    let minLength = min(s1.count, s2.count)
    var prefix = ""
    
    for i in 0..<minLength {
        if s1[s1.index(s1.startIndex, offsetBy: i)] == s2[s2.index(s2.startIndex, offsetBy: i)] {
            prefix.append(s1[s1.index(s1.startIndex, offsetBy: i)])
        } else {
            break
        }
    }
    
    return prefix
}

func calculateSuffixStatistics(suffixArray: [String]) -> [String: Int] {
    var statistics: [String: Int] = [:]
    
    for i in 0..<(suffixArray.count - 1) {
        let lcp = longestCommonPrefix(suffixArray[i], suffixArray[i + 1])
        
        if lcp.count > 3 {
            statistics[lcp, default: 0] += 1
        }
    }
    
    return statistics
}

struct ContentView: View {
    
    @StateObject private var jobManager = JobQueueManager()
    @State private var showHistory: Bool = false
    @State private var showResult: Bool = false
    
    @State private var searchText = ""
    @State private var text = "abracadabraabrabrbrabarababraabraabrabrabra"
    @State private var suffixArray: [String] = []
    @State private var suffixStatistics: [String: Int] = [:]
    @State private var selectedType: SelectionType = .all
    @State private var searchResults: [String] = []
    @State private var textPublisher = PassthroughSubject<String, Never>()
    var body: some View {
        NavigationStack {
            VStack {
                VStack(spacing: 20) {
                    
                    HStack {
                        
                        Spacer()
                        Button("History") {
                            showHistory.toggle()
                        }
                    }
                    
                }
                
                Spacer()
                TextField("Введите строку", text: $text,  axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Spacer()
                
                Button("Button") {
                    jobManager.addJob(text: text)
                    showResult.toggle()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationDestination(isPresented: $showResult) {
                if let job = jobManager.history.first(where: { $0.text == text }) {
                    ResultsView(job: job)
                }
            }
            .navigationDestination(isPresented: $showHistory) {
                HistoryScreen()
                    .environmentObject(jobManager)
            }
        }
        .onAppear {
            setupSearch()
        }
    }
    
    // Настройка поиска с debounce
        private func setupSearch() {
            // Используем debounce для задержки обработки ввода
            textPublisher
                .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
                .removeDuplicates() // Убираем дубликаты последовательных значений
                .sink { query in
                    // Выполняем поиск по суффиксам при каждом новом запросе
                    self.searchResults = performSearch(query: query, in: suffixArray)
                }
                .store(in: &cancellables)
        }
    // Функция для создания суффиксного массива
     private func createSuffixArray(from string: String) -> [String] {
         let suffixes = string.indices.map { string.suffix(from: $0) }
         return suffixes.map { String($0) }.sorted()
     }
     
     // Функция для поиска совпадений среди суффиксов
     private func performSearch(query: String, in suffixes: [String]) -> [String] {
         guard !query.isEmpty else { return [] }
         
         // Фильтруем суффиксы, которые содержат запрос
         return suffixes.filter { $0.contains(query.lowercased()) }
     }
}

// Хранилище для cancellable-объектов
var cancellables = Set<AnyCancellable>()

#Preview {
    ContentView()
}
