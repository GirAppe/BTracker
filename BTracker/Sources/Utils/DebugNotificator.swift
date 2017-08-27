import Foundation
import UIKit

public class DebugNotificator {
    let interval: TimeInterval
    var lastFireDate: Date?

    public init(interval: TimeInterval) {
        self.interval = interval
    }

    public func send(message: String) {
        if let date = lastFireDate, Date().timeIntervalSince(date) < interval {
            print("waitin \(interval - Date().timeIntervalSince(date))")
            return
        }

        print("firin")
        lastFireDate = Date()

        let notification = UILocalNotification()

        notification.alertTitle = "Heya!"
        notification.alertBody = message

        UIApplication.shared.presentLocalNotificationNow(notification)
    }
}
