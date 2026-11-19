//
//  HomeView.swift
//  BudgetApp
//
//  Created by AKWEYU on 19/11/2026.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var vm: BudgetViewModel
    @State private var showAll = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                headerSection
                spendSection
                transactionsSection
            }
        }
        .background(Theme.background.ignoresSafeArea())
        .sheet(isPresented: $showAll) {
            AllTransactionsView().environmentObject(vm)
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 10) {
                Group {
                    if UIImage(named: "profile") != nil {
                        Image("profile").resizable().scaledToFill()
                    } else {
                        Circle().fill(Theme.secondary)
                    }
                }
                .frame(width: 36, height: 36)
                .clipShape(Circle())

                Text("Welcome back, John Doe 👋")
                    .font(AppFont.bold(14))

                Spacer()

                Image(systemName: "bell")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.primary)
                    .frame(width: 34, height: 34)
                    .overlay(Circle().stroke(Theme.primary, lineWidth: 1))
            }

            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(LinearGradient(
                        colors: [Theme.primary, Theme.secondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                VStack(spacing: 10) {
                    HStack(alignment: .firstTextBaseline, spacing: 3) {
                        Text(money(vm.remaining))
                            .font(AppFont.bold(52))
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                        Text("Ksh.")
                            .font(AppFont.bold(12))
                    }
                    Text("remaining on your monthly budget")
                        .font(AppFont.regular(14))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
            }
            .frame(height: 140)
            .animation(.easeInOut, value: vm.remaining)
        }
        .padding(16)
        .background(Theme.surface)
    }

    private var spendSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Spend this Month")
                        .font(AppFont.regular(13))
                        .foregroundColor(.secondary)
                    Text("Ksh \(money(vm.totalSpend))")
                        .font(AppFont.bold(15))
                }
                Spacer()
                Menu {
                    ForEach(Array(vm.monthSymbols.enumerated()), id: \.offset) { index, name in
                        Button(name) { vm.selectedMonth = index + 1 }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(vm.monthName).font(AppFont.regular(13))
                        Image(systemName: "arrowtriangle.down.fill").font(.system(size: 7))
                    }
                    .foregroundColor(.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Theme.border, lineWidth: 1))
                }
            }

            stackedBar

            VStack(spacing: 10) {
                ForEach(vm.categoryTotals, id: \.category.id) { item in
                    HStack(spacing: 10) {
                        Circle().fill(item.category.color).frame(width: 12, height: 12)
                        Text(item.category.rawValue).font(AppFont.regular(12))
                        Spacer()
                        Text("Ksh. \(money(item.total))").font(AppFont.regular(12))
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface)
    }

    private var stackedBar: some View {
        GeometryReader { proxy in
            let total = vm.totalSpend
            HStack(spacing: 0) {
                if total > 0 {
                    ForEach(vm.categoryTotals.filter { $0.total > 0 }, id: \.category.id) { item in
                        Rectangle()
                            .fill(item.category.color)
                            .frame(width: proxy.size.width * CGFloat(item.total / total))
                    }
                }
            }
        }
        .frame(height: vm.totalSpend <= 0 ? 0 : 28)
        .animation(.easeInOut, value: vm.totalSpend)
    }

    private var transactionsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Recent Transactions").font(AppFont.bold(13))
                Spacer()
                Button {
                    showAll = true
                } label: {
                    HStack(spacing: 4) {
                        Text("View All").font(AppFont.medium(13))
                        Image(systemName: "arrow.up.right.square").font(.system(size: 12))
                    }
                    .foregroundColor(Theme.primary)
                }
            }

            if vm.recentTransactions.isEmpty {
                Text("No transactions yet")
                    .font(AppFont.regular(13))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 180)
            } else {
                VStack(spacing: 8) {
                    ForEach(vm.recentTransactions) { expense in
                        TransactionRow(expense: expense)
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface)
    }
}

struct AllTransactionsView: View {
    @EnvironmentObject var vm: BudgetViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(vm.monthExpenses) { expense in
                        TransactionRow(expense: expense)
                    }
                    if vm.monthExpenses.isEmpty {
                        Text("No transactions yet")
                            .font(AppFont.regular(13))
                            .foregroundColor(.secondary)
                            .padding(.top, 60)
                    }
                }
                .padding(16)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Transactions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                        .foregroundColor(Theme.primary)
                }
            }
        }
    }
}
