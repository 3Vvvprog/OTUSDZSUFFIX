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
    @State private var searchText = ""
    @State private var text = "abracadabraabrabrbrabarababraabraabrabrabra"
    @State private var suffixArray: [String] = []
    @State private var suffixStatistics: [String: Int] = [:]
    @State private var selectedType: SelectionType = .all
    @State private var searchResults: [String] = []
    @State private var textPublisher = PassthroughSubject<String, Never>()
    var body: some View {
        VStack {
            VStack(spacing: 20) {
                    
                    Text("Суффиксный массив:")
                        .font(.headline)
                    
                    Picker("Suffix Category", selection: $selectedType) {
                        ForEach(SelectionType.allCases) { category in
                            Text(category.title).tag(category)
                       }
                    }
                    .pickerStyle(.segmented)
                
                    if selectedType == .all {
                        
                        TextField("Введите строку для поиска", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onReceive(Just(searchText)) { value in
                                // Отправляем новое значение в издатель
                                textPublisher.send(value)
                            }
                        
                        if searchText.isEmpty {
                            List(suffixArray, id: \.self) { suffix in
                                Text(suffix)
                            }
                        }else {
                            List(searchResults, id: \.self) { suffix in
                                Text(suffix)
                            }
                        }
                    }else {
                        if !suffixStatistics.isEmpty {
                            Text("Статистика совпадений суффиксов:")
                                .font(.headline)
                            List {
                                ForEach(suffixStatistics
                                    .sorted { $0.value > $1.value }
                                    .map { "\($0.key) – \($0.value)" },
                                        id: \.self) { item in
                                    Text(item)
                                }
                            }
                        }
                    }
                
            }
            
            Spacer()
            TextField("Введите строку", text: $text,  axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Spacer()
            
            Button("Button") {
                suffixArray = createSuffixArray(from: text)
                suffixStatistics = calculateSuffixStatistics(suffixArray: suffixArray)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        
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
