enum AppSection {
  dashboard,
  budget,
  transactions,
  debts,
  investments,
  wishlist,
  reports,
}

extension AppSectionMeta on AppSection {
  String get label {
    switch (this) {
      case AppSection.dashboard:
        return 'Dashboard';
      case AppSection.budget:
        return 'Smart Budget';
      case AppSection.transactions:
        return 'Transactions';
      case AppSection.debts:
        return 'Debts';
      case AppSection.investments:
        return 'Investments';
      case AppSection.wishlist:
        return 'Wishlist';
      case AppSection.reports:
        return 'Reports';
    }
  }
}
