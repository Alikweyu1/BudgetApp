//
//  ReportsView.swift
//  BudgetApp
//
//  Created by AKWEYU on 19/11/2026.
//

import SwiftUI
import Charts

struct ReportsView: View {
    @EnvironmentObject var vm: BudgetViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Total Spend").font(AppFont.regular(13)).foregroundColor(.secondary)
                            Text("Ksh \(money(vm.totalSpend))").font(AppFont.bold(22))
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Remaining").font(AppFont.regular(13)).foregroundColor(.secondary)
                            Text("Ksh \(money(vm.remaining))")
                                .font(AppFont.bold(22))
                                .foregroundColor(Theme.primary)
                        }
                    }

                    Chart(vm.categoryTotals, id: \.category.id) { item in
                        BarMark(
                            x: .value("Category", item.category.rawValue),
                            y: .value("Amount", item.total)
                        )
                        .foregroundStyle(item.category.color)
                        .cornerRadius(4)
                    }
                    .chartLegend(.hidden)
                    .frame(height: 260)

                    VStack(spacing: 10) {
                        ForEach(vm.categoryTotals, id: \.category.id) { item in
                            HStack(spacing: 10) {
                                Circle().fill(item.category.color).frame(width: 12, height: 12)
                                Text(item.category.rawValue).font(AppFont.regular(13))
                                Spacer()
                                Text("Ksh. \(money(item.total))").font(AppFont.medium(13))
                            }
                        }
                    }
                }
                .padding(16)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Reports")
        }
    }
}
