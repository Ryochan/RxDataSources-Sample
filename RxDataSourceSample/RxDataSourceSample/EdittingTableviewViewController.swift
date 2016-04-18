//
//  ViewController.swift
//  RxDataSourceSample
//
//  Created by mercari on 4/18/16.
//  Copyright © 2016 Ryo. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift
import RxCocoa

class EdittingTableviewViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dataSource = RxTableViewSectionedAnimatedDataSource<NumberSection>()
        let sections: [NumberSection] = [
            NumberSection(header: "Section 1", numbers: [], updated: NSDate()),
            NumberSection(header: "Section 2", numbers: [], updated: NSDate()),
            NumberSection(header: "Section 3", numbers: [], updated: NSDate())
        ]
        
        let initialState = SectionedTableViewState(sections: sections)
        let addCommand = addButton.rx_tap
            .scan(0) { x, _ in x+1 }
            .map { number -> TableViewEdittingCommand in
                let randSection = Int(arc4random_uniform(UInt32(sections.count)))
                let item = IntItem(number: number, date: NSDate())
                return TableViewEdittingCommand.AppendItem(item: item, section: randSection)
            }
        
        let moveCommand = tableView.rx_itemMoved
            .map { (sourceIndex, destinationIndex) -> TableViewEdittingCommand in
                return TableViewEdittingCommand.MoveItem(sourceIndex: sourceIndex, destinationIndexPath: destinationIndex)
            }
        
        let deleteCommand = tableView.rx_itemDeleted
            .map { indexPath -> TableViewEdittingCommand in
                return TableViewEdittingCommand.DeleteItem(indexPath)
            }
        
        Observable
            .of(addCommand, moveCommand, deleteCommand)
            .merge()
            .scan(initialState) { return $0.executeCommand($1) }
            .startWith(initialState)
            .map { $0.sections }
            .shareReplay(1)
            .bindTo(tableView.rx_itemsAnimatedWithDataSource(dataSource))
            .addDisposableTo(disposeBag)
        
        skinTableViewDataSource(dataSource)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func skinTableViewDataSource(dataSource: RxTableViewSectionedAnimatedDataSource<NumberSection>) {
        dataSource.animationConfiguration = AnimationConfiguration(insertAnimation: .Top, reloadAnimation: .Fade, deleteAnimation: .Left)
        
        dataSource.configureCell = { (dataSource, tableView, indexPath, item) in
            let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
            
            cell.textLabel?.text = "\(item)"
            
            return cell
        }
        
        dataSource.titleForHeaderInSection = { (dataSource, section) -> String in
            return dataSource.sectionAtIndex(section).header
        }
        
        dataSource.canEditRowAtIndexPath = { _ in
            return true
        }
        
        dataSource.canMoveRowAtIndexPath = { _ in
            return false
        }
    }
}

enum TableViewEdittingCommand {
    case AppendItem(item: IntItem, section: Int)
    case MoveItem(sourceIndex: NSIndexPath, destinationIndexPath: NSIndexPath)
    case DeleteItem(NSIndexPath)
}

struct SectionedTableViewState {
    private var sections: [NumberSection]
    
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
        case .DeleteItem(let indexPath):
            var sections = self.sections
            var items = sections[indexPath.section].items
            items.removeAtIndex(indexPath.row)
            sections[indexPath.section] = NumberSection(original: sections[indexPath.section], items: items)
            return SectionedTableViewState(sections: sections)
        case .MoveItem(let moveEvent):
            var sections = self.sections
            var sourceItems = sections[moveEvent.sourceIndex.section].items
            var destItems = sections[moveEvent.destinationIndexPath.section].items
            
            if moveEvent.sourceIndex.section == moveEvent.destinationIndexPath.section {
                destItems.insert(destItems.removeAtIndex(moveEvent.sourceIndex.row), atIndex: moveEvent.destinationIndexPath.row)
                let destinationSection = NumberSection(original: sections[moveEvent.destinationIndexPath.section], items: destItems)
                sections[moveEvent.sourceIndex.section] = destinationSection
                return SectionedTableViewState(sections: sections)
            } else {
                let item = sourceItems.removeAtIndex(moveEvent.sourceIndex.row)
                destItems.insert(item, atIndex: moveEvent.destinationIndexPath.row)
                let sourceSection = NumberSection(original: sections[moveEvent.sourceIndex.section], items: sourceItems)
                let destSection = NumberSection(original: sections[moveEvent.destinationIndexPath.section], items: destItems)
                
                sections[moveEvent.sourceIndex.section] = sourceSection
                sections[moveEvent.destinationIndexPath.section] = destSection
                
                return SectionedTableViewState(sections: sections)
            }
        }
    }
}

func + <T>(lhs: [T], rhs: T) -> [T] {
    var copy = lhs
    copy.append(rhs)
    return copy
}
