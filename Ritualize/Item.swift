//
//  Item.swift
//  Ritualize
//
//  Created by Raazi Muhammed on 19/05/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
