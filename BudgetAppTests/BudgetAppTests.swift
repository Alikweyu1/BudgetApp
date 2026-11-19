//
//  BudgetAppTests.swift
//  BudgetAppTests
//
//  Created by AKWEYU on 19/11/2026.
//

import XCTest
@testable import BudgetApp

@MainActor
final class BudgetViewModelTests: XCTestCase {
    private let seedKey = "didSeedSampleTransactions"

    private func makeViewModel(
        seedSamples: Bool = false,
        persistence: PersistenceController = PersistenceController(inMemory: true)
    ) -> BudgetViewModel {
        if seedSamples {
            UserDefaults.standard.removeObject(forKey: seedKey)
        } else {
            UserDefaults.standard.set(true, forKey: seedKey)
        }
        return BudgetViewModel(persistence: persistence)
    }

    func testEmptyStateRemainingEqualsMonthlyBudget() {
        let vm = makeViewModel()
        XCTAssertEqual(vm.totalSpend, 0)
        XCTAssertEqual(vm.remaining, 200000)
        XCTAssertTrue(vm.recentTransactions.isEmpty)
    }

    func testAddExpenseReducesRemainingBalance() {
        let vm = makeViewModel()
        vm.addExpense(name: "KFC Chicken", category: .food, amount: 2000)
        XCTAssertEqual(vm.totalSpend, 2000)
        XCTAssertEqual(vm.remaining, 198000)
    }

    func testAddExpenseReturnsCreatedExpense() {
        let vm = makeViewModel()
        let expense = vm.addExpense(name: "Train", category: .transport, amount: 6000)
        XCTAssertEqual(expense.name, "Train")
        XCTAssertEqual(expense.category, .transport)
        XCTAssertEqual(expense.amount, 6000)
    }

    func testCategoryTotalsAreGroupedCorrectly() {
        let vm = makeViewModel()
        vm.addExpense(name: "KFC Chicken", category: .food, amount: 2000)
        vm.addExpense(name: "Java House", category: .food, amount: 5000)
        vm.addExpense(name: "Train", category: .transport, amount: 6000)
        vm.addExpense(name: "all Fees", category: .fees, amount: 500)

        let totals = Dictionary(uniqueKeysWithValues: vm.categoryTotals.map { ($0.category, $0.total) })
        XCTAssertEqual(totals[.food], 7000)
        XCTAssertEqual(totals[.transport], 6000)
        XCTAssertEqual(totals[.clothing], 0)
        XCTAssertEqual(totals[.fees], 500)
        XCTAssertEqual(vm.totalSpend, 13500)
    }

    func testRecentTransactionsAreLimitedToFour() {
        let vm = makeViewModel()
        for index in 1...6 {
            vm.addExpense(name: "Item \(index)", category: .food, amount: 100)
        }
        XCTAssertEqual(vm.monthExpenses.count, 6)
        XCTAssertEqual(vm.recentTransactions.count, 4)
    }

    func testExpensesAreFilteredBySelectedMonth() {
        let vm = makeViewModel()
        vm.addExpense(name: "KFC Chicken", category: .food, amount: 2000)
        XCTAssertEqual(vm.monthExpenses.count, 1)

        vm.selectedMonth = (vm.selectedMonth % 12) + 1
        XCTAssertTrue(vm.monthExpenses.isEmpty)
        XCTAssertEqual(vm.totalSpend, 0)
        XCTAssertEqual(vm.remaining, 200000)
    }

    func testDeleteRemovesExpenseAndRestoresBalance() {
        let vm = makeViewModel()
        let expense = vm.addExpense(name: "mitumba", category: .clothing, amount: 1500)
        XCTAssertEqual(vm.remaining, 198500)

        vm.delete(expense)
        XCTAssertTrue(vm.monthExpenses.isEmpty)
        XCTAssertEqual(vm.remaining, 200000)
    }

    func testExpensesPersistAcrossViewModels() {
        let persistence = PersistenceController(inMemory: true)
        let first = makeViewModel(persistence: persistence)
        first.addExpense(name: "KFC Chicken", category: .food, amount: 2000)

        let second = makeViewModel(persistence: persistence)
        XCTAssertEqual(second.monthExpenses.count, 1)
        XCTAssertEqual(second.monthExpenses.first?.name, "KFC Chicken")
        XCTAssertEqual(second.remaining, 198000)
    }

    func testSampleTransactionsMatchDesignTotals() {
        let vm = makeViewModel(seedSamples: true)
        XCTAssertEqual(vm.totalSpend, 17000)
        XCTAssertEqual(vm.remaining, 183000)
        XCTAssertEqual(vm.recentTransactions.count, 4)
        XCTAssertEqual(vm.recentTransactions.first?.name, "KFC Chicken")
    }

    func testSamplesAreSeededOnlyOnce() {
        let persistence = PersistenceController(inMemory: true)
        let first = makeViewModel(seedSamples: true, persistence: persistence)
        let count = first.monthExpenses.count

        let second = BudgetViewModel(persistence: persistence)
        XCTAssertEqual(second.monthExpenses.count, count)
    }

    func testBudgetCategoriesMatchDesign() {
            XCTAssertEqual(BudgetCategory.food.rawValue, "Food & Beverage")
            XCTAssertEqual(BudgetCategory.transport.rawValue, "Transport & Fuel")
            XCTAssertEqual(BudgetCategory.clothing.rawValue, "Clothing")
            XCTAssertEqual(BudgetCategory.fees.rawValue, "Transaction Fees")
        }

    func testMoneyFormatting() {
        XCTAssertEqual(money(183000), "183000.0")
        XCTAssertEqual(money(0), "0.0")
        XCTAssertEqual(money(500), "500.0")
    }
}
