import Foundation
import SwiftUI
import CoreData

func formatDate(_ date: Date) -> String {
    let calendar = Calendar.current
    let now = Date()
    let formatter = DateFormatter()
    formatter.locale = Locale.current
    
    if calendar.isDateInToday(date) {
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    } else if calendar.isDateInYesterday(date) {
        formatter.dateStyle = .medium
        formatter.doesRelativeDateFormatting = true
        return formatter.string(from: date)
    } else {
        let startOfNow = calendar.startOfDay(for: now)
        let startOfDate = calendar.startOfDay(for: date)

        if let diffWeeks = calendar.dateComponents([.weekOfYear], from: startOfDate, to: startOfNow).weekOfYear, diffWeeks < 1 {
            formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "EEEE", options: 0, locale: Locale.current)
            return formatter.string(from: date)
        } else {
            formatter.dateStyle = .short
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }
    }
}

extension NavigationLink where Label == EmptyView, Destination == EmptyView {

   /// Useful in cases where a `NavigationLink` is needed but there should not be
   /// a destination. e.g. for programmatic navigation.
   static var empty: NavigationLink {
       self.init(destination: EmptyView(), label: { EmptyView() })
   }
}

