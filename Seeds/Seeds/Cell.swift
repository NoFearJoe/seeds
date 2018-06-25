//
//  Cell.swift
//  Seeds
//
//  Created by Илья Харабет on 16.06.2018.
//  Copyright © 2018 Илья Харабет. All rights reserved.
//

import UIKit

class CellModel {
    let value: Int
    var row: Int
    let column: Int
    var isSelected: Bool
    var isAvailable: Bool
    var isHighlighted: Bool
    
    init(value: Int, row: Int, column: Int, isSelected: Bool, isAvailable: Bool, isHighlighted: Bool) {
        self.value = value
        self.row = row
        self.column = column
        self.isSelected = isSelected
        self.isAvailable = isAvailable
        self.isHighlighted = isHighlighted
    }
    
    convenience init(value: Int, row: Int, column: Int) {
        self.init(value: value, row: row, column: column, isSelected: false, isAvailable: true, isHighlighted: false)
    }
    
}

extension CellModel: Equatable {
    static func == (lhs: CellModel, rhs: CellModel) -> Bool {
        return lhs.value == rhs.value && lhs.column == rhs.column && lhs.row == rhs.row
    }
}

final class Cell: UICollectionViewCell {
    
    @IBOutlet var label: UILabel!
    
    var isPicked: Bool = false {
        didSet {
            updateState()
        }
    }
    
    var isSuggested: Bool = false {
        didSet {
            updateState()
        }
    }
    
    private func updateState() {
        if isPicked {
            backgroundColor = .yellow
        } else if isSuggested {
            backgroundColor = .green
        } else {
            backgroundColor = .white
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 6
    }
    
}
