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
    var apps: [App]
    var id: Int
    
    init(header: String, apps: [App], id: Int) {
        self.header = header
        self.apps = apps
        self.id = id
    }
}

struct App {
    let id: Int
    let name: String
}

extension NumberSection: AnimatableSectionModelType {
    typealias Item = App
    typealias Identity = String
    
    var identity: Identity {
        return header
    }
    
    var items: [Item] {
        return apps
    }
    
    init(original: NumberSection, items: [Item]) {
        self = original
        self.apps = items
    }
}

extension App: IdentifiableType, Equatable {
    typealias Identity = Int
    
    var identity: Int {
        return id
    }
}

// equatable, this is needed to detect changes
func == (lhs: App, rhs: App) -> Bool {
    return lhs.id == rhs.id
}
