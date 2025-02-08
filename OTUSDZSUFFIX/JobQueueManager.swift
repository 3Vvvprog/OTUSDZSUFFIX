//
//  JobQueueManager.swift
//  OTUSDZSUFFIX
//
//  Created by Вячеслав Вовк on 08.02.2025.
//
import SwiftUI
import Combine

// Job Queue Manager
class JobQueueManager: ObservableObject {
    @Published var jobQueue: [SuffixSearchJobModel] = []
    @Published var history: [SuffixSearchJobModel] = []
    @Published var summary: String = "Сводка пуста."
    
    // Добавление новой задачи в очередь
    func addJob(text: String) {
        let job = SuffixSearchJobModel(text: text)
        guard !history.contains(where: { $0.text == text }) else { return }
        jobQueue.append(job)
        Task {
            await processJobs()
        }
    }
    
    // Обработка очереди задач
    @MainActor
    func processJobs() async {
        for job in jobQueue {
            await performJob(job)
        }
        jobQueue.removeAll()
        updateSummary()
    }
    
    // Выполнение одной задачи
    private func performJob(_ job: SuffixSearchJobModel) async {
        let startTime = Date()
        
        // Асинхронное выполнение поиска суффиксов
        let suffixArray = createSuffixArray(from: job.text)
        let statistics = calculateSuffixStatistics(suffixArray: suffixArray)
        
        let endTime = Date()
        let executionTime = endTime.timeIntervalSince(startTime)
        
        // Обновляем данные задачи
        let updatedJob = SuffixSearchJobModel(
            text: job.text,
            suffixes: suffixArray,
            statistics: statistics,
            executionTime: executionTime
        )
        
        // Добавляем выполненную задачу в историю
        history.append(updatedJob)
    }
    
    // Обновление сводки
    private func updateSummary() {
        let totalExecutionTime = history.reduce(0) { $0 + $1.executionTime }
        let totalJobs = history.count
        summary = """
        Всего задач: \(totalJobs)
        Общее время выполнения: \(String(format: "%.2f", totalExecutionTime)) секунд
        """
    }
}
