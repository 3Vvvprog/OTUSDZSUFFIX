// Job Queue Manager
class JobQueueManager: ObservableObject {
    @Published var jobQueue: [SuffixSearchJob] = []
    @Published var history: [SuffixSearchJob] = []
    @Published var summary: String = "Сводка пуста."
    
    // Добавление новой задачи в очередь
    func addJob(text: String) {
        let job = SuffixSearchJob(text: text)
        jobQueue.append(job)
        processJobs()
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
    private func performJob(_ job: SuffixSearchJob) async {
        let startTime = Date()
        
        // Асинхронное выполнение поиска суффиксов
        let suffixArray = createSuffixArray(from: job.text)
        let statistics = calculateSuffixStatistics(suffixArray: suffixArray)
        
        let endTime = Date()
        let executionTime = endTime.timeIntervalSince(startTime)
        
        // Обновляем данные задачи
        let updatedJob = SuffixSearchJob(
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