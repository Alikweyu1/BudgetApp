//
//  AddBudgetView.swift
//  BudgetApp
//
//  Created by AKWEYU on 19/11/2026.
//

import SwiftUI
import StoreKit

struct AddBudgetFlow: View {
    @EnvironmentObject var vm: BudgetViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var created: Expense?

    let onFinish: () -> Void

    var body: some View {
        ZStack {
            if let created = created {
                SuccessView(expense: created) {
                    onFinish()
                    dismiss()
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                AddBudgetView(
                    onCreated: { expense in
                        withAnimation(.easeInOut) { created = expense }
                    },
                    onClose: { dismiss() }
                )
                .transition(.opacity)
            }
        }
        .background(Theme.surface.ignoresSafeArea())
    }
}

struct AddBudgetView: View {
    @EnvironmentObject var vm: BudgetViewModel

    let onCreated: (Expense) -> Void
    let onClose: () -> Void

    @State private var category: BudgetCategory = .food
    @State private var itemName = ""
    @State private var amountText = ""
    @State private var errorMessage: String?
    @FocusState private var focus: Field?

    private enum Field { case name, amount }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Add New Budget Item").font(AppFont.bold(16))
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                }
            }
            .padding(.bottom, 24)

            label("Category")
            Menu {
                ForEach(BudgetCategory.allCases) { item in
                    Button(item.rawValue) { category = item }
                }
            } label: {
                HStack {
                    Text(category.rawValue).font(AppFont.regular(13)).foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "arrowtriangle.down.fill")
                        .font(.system(size: 7))
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 12)
                .frame(height: 48)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Theme.border, lineWidth: 1))
            }
            .padding(.bottom, 20)

            label("Item Name")
            TextField("e.g. KFC Chicken", text: $itemName)
                .font(AppFont.regular(13))
                .focused($focus, equals: .name)
                .submitLabel(.next)
                .onSubmit { focus = .amount }
                .padding(.horizontal, 12)
                .frame(height: 48)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(focus == .name ? Theme.primary : Theme.border, lineWidth: 1.5))
                .padding(.bottom, 20)

            label("Allocation")
            HStack(spacing: 10) {
                HStack(spacing: 4) {
                    Text("Ksh").font(AppFont.regular(11))
                    Image(systemName: "arrowtriangle.down.fill").font(.system(size: 6))
                }
                .foregroundColor(.secondary)
                Rectangle().fill(Theme.border).frame(width: 1, height: 20)
                TextField("0", text: $amountText)
                    .font(AppFont.regular(13))
                    .keyboardType(.decimalPad)
                    .focused($focus, equals: .amount)
            }
            .padding(.horizontal, 12)
            .frame(height: 48)
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(focus == .amount ? Theme.primary : Theme.border, lineWidth: 1.5))

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(AppFont.regular(12))
                    .foregroundColor(Theme.danger)
                    .padding(.top, 8)
            }

            Button(action: submit) {
                Text("Create New Budget Item")
                    .font(AppFont.bold(13))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(RoundedRectangle(cornerRadius: 6).fill(Theme.primary))
            }
            .padding(.top, 28)

            Spacer()
        }
        .padding(20)
        .contentShape(Rectangle())
        .onTapGesture { focus = nil }
    }

    private func label(_ text: String) -> some View {
        Text(text)
            .font(AppFont.regular(12))
            .foregroundColor(.secondary)
            .padding(.bottom, 6)
    }

    private func submit() {
        let trimmed = itemName.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalized = amountText.replacingOccurrences(of: ",", with: "")
        guard !trimmed.isEmpty else {
            errorMessage = "Enter an item name"
            return
        }
        guard let amount = Double(normalized), amount > 0 else {
            errorMessage = "Enter a valid amount"
            return
        }
        guard amount <= vm.remaining else {
            errorMessage = "Amount exceeds your remaining budget"
            return
        }
        errorMessage = nil
        focus = nil
        let expense = vm.addExpense(name: trimmed, category: category, amount: amount)
        onCreated(expense)
    }
}

struct SuccessView: View {
    let expense: Expense
    let onHome: () -> Void

    @Environment(\.requestReview) private var requestReview
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 10) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(Theme.primary)
                    .scaleEffect(appeared ? 1 : 0.3)
                    .opacity(appeared ? 1 : 0)
                Text("Budget Item Added")
                    .font(AppFont.bold(18))
                    .foregroundColor(Theme.secondary)
                Text("Budget item has been added successfully.")
                    .font(AppFont.regular(11))
                    .foregroundColor(.secondary)
            }
            .padding(.top, 70)

            Divider().padding(.vertical, 28)

            VStack(spacing: 14) {
                row("Budget Item Name", expense.name, .primary)
                row("Amount", "Ksh \(money(expense.amount))", Theme.primary)
                row("Date", Formatters.long.string(from: expense.date), .primary)
            }

            Spacer()

            Button(action: onHome) {
                Text("Go back to Home")
                    .font(AppFont.bold(13))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(RoundedRectangle(cornerRadius: 6).fill(Theme.secondary))
            }

            Button {
                requestReview()
            } label: {
                Text("Rate your Experience")
                    .font(AppFont.medium(13))
                    .foregroundColor(Theme.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Theme.border, lineWidth: 1))
            }
            .padding(.top, 10)
        }
        .padding(20)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { appeared = true }
        }
    }

    private func row(_ title: String, _ value: String, _ color: Color) -> some View {
        HStack {
            Text(title).font(AppFont.regular(12)).foregroundColor(.secondary)
            Spacer()
            Text(value).font(AppFont.medium(12)).foregroundColor(color)
        }
    }
}

