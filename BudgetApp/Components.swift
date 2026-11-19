//
//  Components.swift
//  BudgetApp
//
//  Created by AKWEYU on 19/11/2026.
//

import SwiftUI

enum Formatters {
    static let transaction: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy h:mm a"
        return formatter
    }()

    static let long: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()
}

struct MerchantIcon: View {
    let name: String
    var size: CGFloat = 40

    private var assetName: String? {
        let lowered = name.lowercased()
        if lowered.contains("kfc") { return "kfc" }
        if lowered.contains("mitumba") { return "mitumba" }
        if lowered.contains("train") || lowered.contains("total") || lowered.contains("fuel") { return "total" }
        if lowered.contains("fee") || lowered.contains("paul") { return "paul" }
        return nil
    }

    var body: some View {
        if let asset = assetName, UIImage(named: asset) != nil {
            Image(asset)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(Circle())
        } else {
            Text(String(name.prefix(1)).uppercased())
                .font(AppFont.bold(size * 0.4))
                .foregroundColor(.white)
                .frame(width: size, height: size)
                .background(Circle().fill(Theme.secondary))
        }
    }
}

struct TransactionRow: View {
    let expense: Expense

    var body: some View {
        HStack(spacing: 12) {
            MerchantIcon(name: expense.name)
            VStack(alignment: .leading, spacing: 3) {
                Text(expense.name)
                    .font(AppFont.bold(13))
                    .foregroundColor(.primary)
                Text(Formatters.transaction.string(from: expense.date))
                    .font(AppFont.regular(10))
                    .foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text("Ksh. \(money(expense.amount))")
                    .font(AppFont.bold(12))
                    .foregroundColor(Theme.danger)
                Text(expense.category.rawValue)
                    .font(AppFont.regular(10))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Theme.surface)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Theme.border, lineWidth: 1))
        )
    }
}
