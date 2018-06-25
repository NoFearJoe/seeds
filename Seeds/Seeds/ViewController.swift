//
//  ViewController.swift
//  Seeds
//
//  Created by Илья Харабет on 15.06.2018.
//  Copyright © 2018 Илья Харабет. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private var gameField: UICollectionView!
    
    var cells: [CellModel] = []
    private var selectedCell: CellModel?
    private var suggestedCells: (CellModel, CellModel)?
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cells = generateInitialCells()
        gameField.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func addNewRows() {
        cells.append(contentsOf: generateDuplicatedCells())
        gameField.reloadData()
    }
    
    @IBAction func suggest() {
        guard self.suggestedCells == nil else { return }
        if let suggestedCells = self.makeSuggestedCells() {
            self.suggestedCells = suggestedCells
            suggestedCells.0.isHighlighted = true
            suggestedCells.1.isHighlighted = true
            let indexPaths = [getIndexPath(for: suggestedCells.0), getIndexPath(for: suggestedCells.1)]
            gameField.reloadItems(at: indexPaths)
        } else {
            
        }
    }
    
    @IBAction func rollback() {
        
    }
    
    @IBAction func refresh() {
        selectedCell = nil
        suggestedCells = nil
        cells = generateInitialCells()
        gameField.reloadData()
    }

}

extension ViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! Cell
        
        let model = cells[indexPath.item]
        cell.label.text = "\(model.value)"
        
        cell.isHidden = !model.isAvailable
        cell.isSuggested = model.isHighlighted
        cell.isPicked = model.isSelected
        
        return cell
    }
    
}

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = cells[indexPath.item]
        guard model.isAvailable else { return }
        
        if model.isSelected {
            model.isSelected = false
            self.selectedCell = nil
            collectionView.reloadItems(at: [indexPath])
        } else {
            if selectedCell == nil {
                model.isSelected = true
                selectedCell = model
                collectionView.reloadItems(at: [indexPath])
            } else if canSelectCell(model) {
                let selectedIndexPath = self.getIndexPath(for: selectedCell!)
                let selectedRow = selectedCell?.row ?? 0
                self.selectedCell?.isSelected = false
                self.selectedCell?.isAvailable = false
                self.selectedCell?.isHighlighted = false
                model.isHighlighted = false
                model.isAvailable = false
                var suggestedIndexPaths: [IndexPath] = []
                if let suggestedCells = suggestedCells,
                    [suggestedCells.0, suggestedCells.1].contains(where: { $0.row == model.row && $0.column == model.column }) ||
                    [suggestedCells.0, suggestedCells.1].contains(where: { $0.row == selectedCell!.row && $0.column == selectedCell!.column }) {
                    suggestedIndexPaths = self.suggestedCells.flatMap { [$0.0, $0.1] }?.map { getIndexPath(for: $0) } ?? []
                    suggestedCells.0.isHighlighted = false
                    suggestedCells.1.isHighlighted = false
                    self.suggestedCells = nil
                }
                self.selectedCell = nil
                collectionView.reloadItems(at: ([indexPath, selectedIndexPath] + suggestedIndexPaths).unique)
                removeRowsIfNeeded([model.row, selectedRow])
            }
        }
    }
    
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = (min(collectionView.frame.width, collectionView.frame.height) - 20) - (4 * 8)
        let size = availableWidth / 9
        return CGSize(width: size, height: size)
    }
    
}

private extension ViewController {
    
    func generateInitialCells() -> [CellModel] {
        let columns = 9
        let rows = 3
        
        var cells = [CellModel]()
        for row in (0..<rows) {
            for column in (0..<columns) {
                let value: Int
                if row == 0 {
                    value = column + 1
                } else {
                    value = Int(arc4random_uniform(8)) + 1
                }
                cells.append(CellModel(value: value, row: row, column: column))
            }
        }
        
        return cells
    }
    
    func generateDuplicatedCells() -> [CellModel] {
        var cells = [CellModel]()
        var row = (self.cells.max(by: { $0.row < $1.row })?.row ?? -1) + 1
        var column = 0
        for cell in (self.cells.filter { $0.isAvailable }) {
            cells.append(CellModel(value: cell.value, row: row, column: column, isSelected: false, isAvailable: true, isHighlighted: false))
            if column == 8 {
                row += 1
                column = 0
            } else {
                column += 1
            }
        }
        if column != 0 {
            for c in (column..<9) {
                let value = Int(arc4random_uniform(8)) + 1
                cells.append(CellModel(value: value, row: row, column: c))
            }
        }
        return cells
    }
    
    func canSelectCell(_ cell: CellModel) -> Bool {
        guard let selectedCell = selectedCell else { return true }
        return availableForSelectionCells(for: selectedCell).contains(where: { $0.column == cell.column && $0.row == cell.row })
    }
    
    func availableForSelectionCells(for cell: CellModel) -> [CellModel] {
        guard cell.isAvailable else { return [] }
        let nextAvailableCell = cells.first(where: { c in
            guard c.isAvailable else { return false }
            if c.row == cell.row {
                return c.column > cell.column
            } else if c.row > cell.row {
                return true
            } else {
                return false
            }
        })
        let previousAvailableCell = cells.filter { c in
            guard c.isAvailable else { return false }
            if c.row == cell.row {
                return c.column < cell.column
            } else if c.row < cell.row {
                return true
            } else {
                return false
            }
        }.last
        let nextVerticalCell = cells.first(where: { c in
            guard c.isAvailable else { return false }
            return c.row > cell.row && c.column == cell.column
        })
        let previousVerticalCell = cells.filter { c in
            guard c.isAvailable else { return false }
            return c.column == cell.column && c.row < cell.row
        }.last
        // horizontal + next + vertical
        return [nextAvailableCell, previousAvailableCell, nextVerticalCell, previousVerticalCell]
            .compactMap { $0 }
            .filter { $0.value == cell.value || $0.value + cell.value == 10 }
    }
    
    func makeSuggestedCells() -> (CellModel, CellModel)? {
        for cell in self.cells {
            guard let availableCell = self.availableForSelectionCells(for: cell).first else { continue }
            return (cell, availableCell)
        }
        return nil
    }
    
    func getIndexPath(for cell: CellModel) -> IndexPath {
        return IndexPath(item: (cell.row * 9) + cell.column, section: 0)
    }
    
    // Нужно сдвигать все row у ячеек
    func removeRowsIfNeeded(_ rows: [Int]) {
        let firstRowCells = cells.filter { $0.row == rows[0] }
        if rows[0] == rows[1] {
            guard !firstRowCells.contains(where: { $0.isAvailable }) else { return }
            gameField.performBatchUpdates({
                removeRow(rows[0])
            }, completion: { _ in
                self.shiftRows(after: rows[0])
                self.gameField.reloadData()
            })
        } else {
            let secondRowCells = cells.filter { $0.row == rows[1] }
            let canRemoveFirstRow = !firstRowCells.contains(where: { $0.isAvailable })
            let canRemoveSecondRow = !secondRowCells.contains(where: { $0.isAvailable })
            if canRemoveFirstRow, canRemoveSecondRow {
                gameField.performBatchUpdates({
                    removeRow(rows[0])
                    removeRow(rows[1])
                }, completion: { _ in
                    self.shiftRows(after: rows[0])
                    self.shiftRows(after: rows[1] - 1)
                    self.gameField.reloadData()
                })
            } else if canRemoveFirstRow {
                gameField.performBatchUpdates({
                    removeRow(rows[0])
                }, completion: { _ in
                    self.shiftRows(after: rows[0])
                    self.gameField.reloadData()
                })
            } else if canRemoveSecondRow {
                gameField.performBatchUpdates({
                    removeRow(rows[1])
                }, completion: { _ in
                    self.shiftRows(after: rows[1])
                    self.gameField.reloadData()
                })
            }
        }
    }
    
    func removeRow(_ row: Int) {
        var indexesToRemove: [Int] = []
        for column in (0..<9) {
            guard let index = cells.index(where: { $0.row == row && $0.column == column }) else { continue }
            indexesToRemove.append(index)
        }
        guard !indexesToRemove.isEmpty else { return }
        cells.removeSubrange(indexesToRemove.min()!...indexesToRemove.max()!)
        gameField.deleteItems(at: indexesToRemove.map { IndexPath(item: $0, section: 0) })
    }
    
    func shiftRows(after row: Int) {
        cells.forEach { cell in
            guard cell.row > row else { return }
            cell.row -= 1
        }
    }
    
}
