//
//  NumberSection.swift
//  RxDataSourceSample
//
//  Created by mercari on 4/18/16.
//  Copyright © 2016 Ryo. All rights reserved.
//

import Foundation
import RxDataSources

struct NumberSection {
    var header: String
    var numbers: [IntItem]
    var updated: NSDate
    
    init(header: String, numbers: [IntItem], updated: NSDate) {
        self.header = header
        self.numbers = numbers
        self.updated = updated
    }
}

struct IntItem {
    let number: Int
    let date: NSDate
}

extension NumberSection: AnimatableSectionModelType {
    typealias Item = IntItem
    typealias Identity = String
    
    var identity: String {
        return header
    }
    
    var items: [IntItem] {
        return numbers
    }
    
    init(original: NumberSection, items: [Item]) {
        self = original
        self.numbers = items
    }
}

extension IntItem: IdentifiableType, Equatable {
    typealias Identity = Int
    
    var identity: Int {
        return number
    }
}

// equatable, this is needed to detect changes
func == (lhs: IntItem, rhs: IntItem) -> Bool {
    return lhs.number == rhs.number && lhs.date.isEqualToDate(rhs.date)
}
