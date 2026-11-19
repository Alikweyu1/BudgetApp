//
//  AccountView.swift
//  BudgetApp
//
//  Created by AKWEYU on 19/11/2026.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject var vm: BudgetViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Group {
                    if UIImage(named: "profile") != nil {
                        Image("profile").resizable().scaledToFill()
                    } else {
                        Circle().fill(Theme.secondary)
                    }
                }
                .frame(width: 96, height: 96)
                .clipShape(Circle())
                .padding(.top, 32)

                Text("John Doe").font(AppFont.bold(20))

                VStack(spacing: 0) {
                    HStack {
                        Text("Monthly Budget").font(AppFont.regular(14))
                        Spacer()
                        Text("Ksh. \(money(vm.monthlyBudget))").font(AppFont.medium(14))
                    }
                    .padding(16)
                }
                .background(RoundedRectangle(cornerRadius: 8).fill(Theme.surface))
                .padding(.horizontal, 16)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

