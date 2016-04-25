# RxDataSources-Sample
##導入方法
### TableViewのSectionをstructで定義する
```swift
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
```

### 作成したSection structに`AnimatableSectionModelType`を継承
以下の２点を定義する必要がある。
```swift
associatedtype Item : IdentifiableType, Equatable
public init(original: Self, items: [Self.Item])
```
↓
```swift
extension NumberSection: AnimatableSectionModelType {
    typealias Item = IntItem
    
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
```

### Sectionに持たせるアイテム(この場合はIntItem)に`IdentifiableType, Equatable`を継承
```swift
struct IntItem {
    let number: Int
    let date: NSDate
}

extension IntItem: IdentifiableType, Equatable {
    typealias Identity = Int
    
    var identity: Int {
        return number
    }
}
```

### DataSourceを定義
```swift
`let dataSource = RxTableViewSectionedAnimatedDataSource<NumberSection>()
```

###TableViewのアクションをenumで定義
```swift
enum TableViewEdittingCommand {
    case AppendItem(item: IntItem, section: Int)
    case DeleteItem(NSIndexPath)
}
```

###　SectionedTableViewStateを作成
これを使ってアクション(Add, Delete)などを管理する。
`executeCommand(...)`の中で'command'に応じて新しい`SectionedTableViewState`を返す。
```swift
struct SectionedTableViewState {
    private var sections: [NumberSection]
    
    init(sections: [NumberSection]) {
        self.sections = sections
    }
    
    func executeCommand(command: TableViewEdittingCommand) -> SectionedTableViewState {
      ...
    }
```
## SectionedTableViewStateのInitialを定義する
```swift 
let sections: [NumberSection] = [
            NumberSection(header: "Section 1", numbers: [], updated: NSDate()),
            NumberSection(header: "Section 2", numbers: [], updated: NSDate()),
            NumberSection(header: "Section 3", numbers: [], updated: NSDate())
        ]
        
let initialState = SectionedTableViewState(sections: sections)
```

## Commandを定義すして`rx_itemsAnimatedWithDataSource`にバインド
```swift 
let addCommand = addButton.rx_tap
    .scan(0) { x, _ in x+1 }
    .map { number -> TableViewEdittingCommand in
        let randSection = Int(arc4random_uniform(UInt32(sections.count)))
        let item = IntItem(number: number, date: NSDate())
        return TableViewEdittingCommand.AppendItem(item: item, section: randSection
    }
        
let deleteCommand = tableView.rx_itemDeleted
    .map { indexPath -> TableViewEdittingCommand in
            return TableViewEdittingCommand.DeleteItem(indexPath)
    }
        
Observable
    .of(addCommand, deleteCommand)
    .merge()
    .scan(initialState) { return $0.executeCommand($1) }
    .startWith(initialState)
    .map { $0.sections }
    .shareReplay(1)
    .bindTo(tableView.rx_itemsAnimatedWithDataSource(dataSource))
    .addDisposableTo(disposeBag)
```

##最後にDataSourceからcellの設定
```swift 
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
    }
```
