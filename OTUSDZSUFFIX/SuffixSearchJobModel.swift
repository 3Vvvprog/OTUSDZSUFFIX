//
//  SuffixSearchJob.swift
//  OTUSDZSUFFIX
//
//  Created by Вячеслав Вовк on 08.02.2025.
//

import SwiftUI

struct SuffixSearchJobModel: Identifiable {
    var id = UUID()
    let text: String
    var suffixes: [String] = []
    var statistics: [String: Int] = [:]
    var executionTime: TimeInterval = 0
}
