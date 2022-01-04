//
//  RewardsAnalytics.swift
//  Rewards
//
//  Created by Anthonio Ez on 16/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit
import Firebase

class RewardsAnalytics: NSObject
{
    static func logEvent(_ type: String, _ data: String)
    {
        Analytics.logEvent(type, parameters: [
            "hash": Prefs.apiHash,
            "id": Prefs.userID,
            "data": data
        ])

        /*
         Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
         AnalyticsParameterItemID: "id-\(title!)",
         AnalyticsParameterItemName: title!,
         AnalyticsParameterContentType: "cont"
         ])
         */
    }
}
