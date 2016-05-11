//
//  SectionedTableViewState.swift
//  RxDataSourceSample
//
//  Created by mercari on 5/11/16.
//  Copyright © 2016 Ryo. All rights reserved.
//

import Foundation

struct SectionedTableViewState {
    var sections: [NumberSection]
    
    init(sections: [NumberSection]) {
        self.sections = sections
    }
    
    func executeCommand(command: TableViewEdittingCommand) -> SectionedTableViewState {
        switch command {
        case .AppendItem(let appendEvent):
            var sections = self.sections
            let items = sections[appendEvent.section].items + appendEvent.item
            sections[appendEvent.section] = NumberSection(original: sections[appendEvent.section], items: items)
            return SectionedTableViewState(sections: sections)
        case .AppendItems(let appendEvent):
            var sections = self.sections
            let items = sections[appendEvent.section].items + appendEvent.items
            sections[appendEvent.section] = NumberSection(original: sections[appendEvent.section], items: items)
            return SectionedTableViewState(sections: sections)
        case .DeleteItem(let indexPath):
            var sections = self.sections
            var items = sections[indexPath.section].items
            items.removeAtIndex(indexPath.row)
            sections[indexPath.section] = NumberSection(original: sections[indexPath.section], items: items)
            return SectionedTableViewState(sections: sections)
        }
    }
}

enum TableViewEdittingCommand {
    case AppendItem(item: IntItem, section: Int)
    case AppendItems(items: [IntItem], section: Int)
    case DeleteItem(NSIndexPath)
}

func + <T>(lhs: [T], rhs: T) -> [T] {
    var copy = lhs
    copy.append(rhs)
    return copy
}
