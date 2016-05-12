//
//  EdittingTableViewCell.swift
//  RxDataSourceSample
//
//  Created by mercari on 5/12/16.
//  Copyright © 2016 Ryo. All rights reserved.
//

import UIKit

class EdittingTableViewCell: UITableViewCell {

    @IBOutlet weak var itemNameLabel: UILabel!
    
    var item: App! {
        didSet {
            itemNameLabel.text = item.name
        }
    }
}
