//
//  BudgetsView.swift
//  BudgetApp
//
//  Created by AKWEYU on 19/11/2026.
//

import SwiftUI

struct BudgetsView: View {
    @EnvironmentObject var vm: BudgetViewModel

    var body: some View {
        NavigationStack {
            List {
                ForEach(BudgetCategory.allCases) { category in
                    let items = vm.monthExpenses.filter { $0.category == category }
                    if !items.isEmpty {
                        Section {
                            ForEach(items) { expense in
                                HStack {
                                    Text(expense.name).font(AppFont.regular(14))
                                    Spacer()
                                    Text("Ksh. \(money(expense.amount))").font(AppFont.medium(13))
                                }
                            }
                            .onDelete { offsets in
                                offsets.map { items[$0] }.forEach(vm.delete)
                            }
                        } header: {
                            HStack(spacing: 8) {
                                Circle().fill(category.color).frame(width: 10, height: 10)
                                Text(category.rawValue).font(AppFont.bold(12))
                            }
                        }
                    }
                }
            }
            .overlay {
                if vm.monthExpenses.isEmpty {
                    Text("No budget items for \(vm.monthName)")
                        .font(AppFont.regular(13))
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Budgets")
        }
    }
}

