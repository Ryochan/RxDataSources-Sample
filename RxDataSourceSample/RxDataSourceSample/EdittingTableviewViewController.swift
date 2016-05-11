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
    @IBOutlet weak var addItemsButton: UIBarButtonItem!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        bindTableViewDataSource()
    }
    
    private func bindTableViewDataSource() {
        let dataSource = RxTableViewSectionedAnimatedDataSource<NumberSection>()
        
        let sections: [NumberSection] = [
            NumberSection(header: "Section 1", numbers: [], updated: NSDate()),
            ]
        
        let initialState = SectionedTableViewState(sections: sections)
        let addCommand = addButton.rx_tap.asDriver()
            .map { _ -> TableViewEdittingCommand in
                let number = arc4random_uniform(UInt32(Int(100)))
                let item = IntItem(number: Int(number), date: NSDate())
                return TableViewEdittingCommand.AppendItem(item: item, section: 0)
        }
        
        let deleteCommand = tableView.rx_itemDeleted.asDriver()
            .map { indexPath -> TableViewEdittingCommand in
                return TableViewEdittingCommand.DeleteItem(indexPath)
        }
        
        let addItemsCommand = addItemsButton.rx_tap.asDriver()
            .map { _ -> TableViewEdittingCommand in
                let items = [IntItem(number: 150, date: NSDate()), IntItem(number: 151, date: NSDate()), IntItem(number: 152, date: NSDate())]
                return TableViewEdittingCommand.AppendItems(items: items, section: 0)
            }
        
        let updatedState = Driver
            .of(addCommand, deleteCommand, addItemsCommand)
            .merge()
            .scan(initialState) { return $0.executeCommand($1) }
            .startWith(initialState)
            .map { $0.sections }
        
        updatedState
            .drive(tableView.rx_itemsAnimatedWithDataSource(dataSource))
            .addDisposableTo(disposeBag)
        
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
