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

### dataSourceを定義
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



