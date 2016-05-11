//
//  OCKInsightItem+EmptyMessage.swift
//  TestCareKit
//
//  Created by Zachary Bernstein on 5/5/16.
//  Copyright © 2016 Zachary Bernstein. All rights reserved.
//

import CareKit

extension OCKInsightItem {
    /// Returns an `OCKInsightItem` to show when no insights have been calculated.
    static func emptyInsightsMessage() -> OCKInsightItem {
        return OCKMessageItem(title: "No Insights", text: "There are no insights to show.", tintColor: UIColor.greenColor(), messageType: .Tip)
}
}