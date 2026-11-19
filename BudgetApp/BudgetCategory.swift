//
//  BudgetCategory.swift
//  BudgetApp
//
//  Created by AKWEYU on 19/11/2026.

import SwiftUI

enum BudgetCategory: String, CaseIterable, Identifiable {
    case food = "Food & Beverage"
    case transport = "Transport & Fuel"
    case clothing = "Clothing"
    case fees = "Transaction Fees"

    static let allCases: [BudgetCategory] = [.food, .transport, .clothing, .fees]

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .food: return Color(hex: 0x0D2B4E)
        case .transport: return Color(hex: 0x80BA27)
        case .clothing: return Color(hex: 0x6FCBE8)
        case .fees: return Color(hex: 0xF26B3A)
        }
    }
}

struct Expense: Identifiable, Equatable {
    let id: UUID
    let name: String
    let category: BudgetCategory
    let amount: Double
    let date: Date
}
