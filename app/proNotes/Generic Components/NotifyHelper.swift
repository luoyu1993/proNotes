//
//  NotifyHelper.swift
//  proNotes
//
//  Created by Leo Thomas on 27/04/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

class NotifyHelper {
    class func fireNotification() {
        if Preferences.allowsNotification() {
            let localNotification = UILocalNotification()
            localNotification.fireDate = NSDate(timeIntervalSinceNow: 1)
            localNotification.alertBody = "The Data is ready"
            localNotification.soundName = UILocalNotificationDefaultSoundName
            localNotification.applicationIconBadgeNumber = 1
            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        }
    }
}
