//
//  BudgetViewModel.swift
//  BudgetApp
//
//  Created by AKWEYU on 19/11/2026.
//

import SwiftUI
import CoreData

@MainActor
final class BudgetViewModel: ObservableObject {
    @Published private(set) var expenses: [Expense] = []
    @Published var selectedMonth: Int
    @Published var selectedYear: Int

    let monthlyBudget: Double = 200000

    private let persistence: PersistenceController
    private let calendar = Calendar.current

    init(persistence: PersistenceController = .shared) {
        self.persistence = persistence
        let now = Date()
        selectedMonth = Calendar.current.component(.month, from: now)
        selectedYear = Calendar.current.component(.year, from: now)
        load()
    }

    var monthName: String {
        calendar.monthSymbols[selectedMonth - 1]
    }

    var monthSymbols: [String] {
        calendar.monthSymbols
    }

    var monthExpenses: [Expense] {
        expenses
            .filter {
                calendar.component(.month, from: $0.date) == selectedMonth &&
                calendar.component(.year, from: $0.date) == selectedYear
            }
            .sorted { $0.date > $1.date }
    }

    var totalSpend: Double {
        monthExpenses.reduce(0) { $0 + $1.amount }
    }

    var remaining: Double {
        monthlyBudget - totalSpend
    }

    var categoryTotals: [(category: BudgetCategory, total: Double)] {
        BudgetCategory.allCases.map { category in
            (category, monthExpenses.filter { $0.category == category }.reduce(0) { $0 + $1.amount })
        }
    }

    var recentTransactions: [Expense] {
        Array(monthExpenses.prefix(4))
    }

    func load() {
        let request = NSFetchRequest<ExpenseEntity>(entityName: "ExpenseEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        let result = (try? persistence.context.fetch(request)) ?? []
        expenses = result.compactMap { entity in
            guard let category = BudgetCategory(rawValue: entity.category) else { return nil }
            return Expense(
                id: entity.id,
                name: entity.name,
                category: category,
                amount: entity.amount,
                date: entity.date
            )
        }
    }

    @discardableResult
    func addExpense(name: String, category: BudgetCategory, amount: Double) -> Expense {
        let now = Date()
        let entity = ExpenseEntity(context: persistence.context)
        entity.id = UUID()
        entity.name = name
        entity.category = category.rawValue
        entity.amount = amount
        entity.date = now
        persistence.save()
        selectedMonth = calendar.component(.month, from: now)
        selectedYear = calendar.component(.year, from: now)
        load()
        return Expense(id: entity.id, name: name, category: category, amount: amount, date: now)
    }

    func delete(_ expense: Expense) {
        let request = NSFetchRequest<ExpenseEntity>(entityName: "ExpenseEntity")
        request.predicate = NSPredicate(format: "id == %@", expense.id as CVarArg)
        if let match = try? persistence.context.fetch(request).first {
            persistence.context.delete(match)
            persistence.save()
            load()
        }
    }
}
