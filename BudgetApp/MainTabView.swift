//
//  MainTabView.swift
//  BudgetApp
//
//  Created by AKWEYU on 19/11/2026.
//

import SwiftUI

enum AppTab: Int, CaseIterable {
    case home, budgets, reports, account

    var title: String {
        switch self {
        case .home: return "Home"
        case .budgets: return "Budgets"
        case .reports: return "Reports"
        case .account: return "Account"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .budgets: return "square.grid.2x2"
        case .reports: return "chart.bar"
        case .account: return "person"
        }
    }
}

struct MainTabView: View {
    @StateObject private var vm = BudgetViewModel()
    @State private var tab: AppTab = .home
    @State private var showAdd = false

    var body: some View {
        Group {
            switch tab {
            case .home: HomeView()
            case .budgets: BudgetsView()
            case .reports: ReportsView()
            case .account: AccountView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.25), value: tab)
        .safeAreaInset(edge: .bottom, spacing: 0) { bottomBar }
        .environmentObject(vm)
        .fullScreenCover(isPresented: $showAdd) {
            AddBudgetFlow(onFinish: { tab = .home })
                .environmentObject(vm)
        }
    }

    private var bottomBar: some View {
        HStack(alignment: .center) {
            barItem(.home)
            barItem(.budgets)
            Button {
                showAdd = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 30, weight: .regular))
                    .foregroundColor(.white)
                    .frame(width: 62, height: 62)
                    .background(
                        Circle().fill(LinearGradient(
                            colors: [Theme.primary, Theme.secondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                    )
                    .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
            }
            .offset(y: -14)
            .frame(maxWidth: .infinity)
            barItem(.reports)
            barItem(.account)
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
        .background(
            Theme.surface
                .shadow(color: .black.opacity(0.08), radius: 6, y: -2)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func barItem(_ item: AppTab) -> some View {
        Button {
            tab = item
        } label: {
            VStack(spacing: 4) {
                Image(systemName: item.icon).font(.system(size: 20))
                Text(item.title).font(AppFont.regular(11))
            }
            .foregroundColor(tab == item ? Theme.primary : .primary)
            .frame(maxWidth: .infinity)
        }
    }
}
