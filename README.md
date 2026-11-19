# BudgetApp


Personal budget tracker for iOS. SwiftUI, MVVM, Core Data. Works fully offline, with no API.



## Architecture (MVVM)
| Layer | Files |
|---|---|
| Model | `BudgetCategory.swift` (Expense, BudgetCategory), `PersistenceController.swift` (Core Data) |
| ViewModel | `BudgetViewModel.swift` |
| View | `MainTabView`, `HomeView`, `AddBudgetView`, `BudgetsView`, `ReportsView`, `AccountView`, `Components` |
| Styling | `Theme.swift` (colours, fonts, `money()`) |

## Data flow
Add expense -> `BudgetViewModel.addExpense` -> saved in Core Data -> `load()` -> `remaining`, `totalSpend`, `categoryTotals` and `recentTransactions` update the UI.

## Business rules
- Monthly budget is fixed at Ksh 200,000.
- Remaining = budget - the selected month's spend.
- An expense above the remaining balance is rejected.

## Sample transactions (home page)
- The Home page's Recent Transactions list is pre-filled with 3 constant sample items (KFC Chicken, mitumba, Train) so the screen matches the design on first launch.
- They are seeded once by `seedSamplesIfNeeded()` in `BudgetViewModel.swift` and stored in Core Data like any other expense.
- They are placeholders, not real user data. Delete them from the Budgets tab (swipe to delete) or remove the seed call to start empty.
- To see them again, delete the app from the simulator and reinstall.

## Known limitations
- Single hardcoded user and budget.
- Bottom bar uses SF Symbols, not Google icons.
- Sample transactions use today's date, not the 27 Nov 2024 date in the design.
