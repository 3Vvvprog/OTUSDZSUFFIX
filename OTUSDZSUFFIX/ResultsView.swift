// Экран с результатами анализа
struct ResultsView: View {
    let job: SuffixSearchJob
    
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