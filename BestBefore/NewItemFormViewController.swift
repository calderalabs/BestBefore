//
//  NewItemFormViewController.swift
//  BestBefore
//
//  Created by Eugenio Depalo on 02/05/2018.
//  Copyright © 2018 Caldera Labs. All rights reserved.
//

import UIKit
import Eureka
import SwiftDate
import BarcodeScanner

class NewItemFormViewController: FormViewController, UINavigationControllerDelegate, BarcodeScannerCodeDelegate, BarcodeScannerDismissalDelegate {
    @IBOutlet weak var saveButton: UIBarButtonItem!
    var newItem: Item?
    var newItemPrototype: ItemPrototype?
    var code: String?
    var itemPrototypes: Set<ItemPrototype>?
    
    func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        self.code = code
        
        let codeRow = (form.rowBy(tag: "codeRow") as? LabelRow)
        codeRow?.value = code
        codeRow?.updateCell()
        
        if let itemPrototypes = itemPrototypes {
            if let itemPrototype = itemPrototypes.first(where: { prototype in
                return prototype.code == code
            }) {
                let expiresAt = Date().addingTimeInterval(itemPrototype.interval)

                if let nameRow = (form.rowBy(tag: "nameRow") as? TextRow) {
                    nameRow.value = itemPrototype.name
                    nameRow.updateCell()
                }
                
                if let expirationDateRow = (form.rowBy(tag: "expirationDateRow") as? DateRow) {
                    expirationDateRow.value = expiresAt
                    expirationDateRow.updateCell()
                }
            }
        }
        
        controller.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    private func updateSaveButton() {
        let nameRow = (form.rowBy(tag: "nameRow") as? TextRow)
        let expirationDateRow = (form.rowBy(tag: "expirationDateRow") as? DateRow)
        
        if let nameValue = nameRow?.value, let _ = expirationDateRow?.value {
            saveButton.isEnabled = nameValue != ""
        } else {
            saveButton.isEnabled = false
        }
    }
    
    private func updateIntervalRows() {
        let daysRow = self.form.rowBy(tag: "daysRow") as? IntRow
        let monthsRow = self.form.rowBy(tag: "monthsRow") as? IntRow
        let yearsRow = self.form.rowBy(tag: "yearsRow") as? IntRow
        let row = form.rowBy(tag: "expirationDateRow") as! DateRow
        if let rowValue = row.value {
            let expirationInterval = rowValue.inDefaultRegion().startOfDay - Date().inDefaultRegion().startOfDay
            let components = expirationInterval.in([.day, .month, .year])
            self.shouldSkipOnChange = true
            daysRow?.value = components[.day] == 0 ? nil : components[.day]
            monthsRow?.value = components[.month] == 0 ? nil : components[.month]
            yearsRow?.value = components[.year] == 0 ? nil : components[.year]
            self.shouldSkipOnChange = false
            daysRow?.updateCell()
            monthsRow?.updateCell()
            yearsRow?.updateCell()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form
            +++ ButtonRow() { row in
                    row.title = "Scan bar code"
                }.onCellSelection({ (cell, row) in
                    let viewController = BarcodeScannerViewController()
                    viewController.codeDelegate = self
                    viewController.dismissalDelegate = self
                    
                    self.present(viewController, animated: true, completion: nil)
                })
            +++ Section("Details")
                <<< TextRow("nameRow"){ row in
                    row.title = "Name"
                    row.placeholder = "Enter product name here"
                    }.onChange{ row in
                        self.updateSaveButton()
                    }
                <<< LabelRow("codeRow"){ row in
                    row.title = "Bar Code"
                    }
            +++ Section("Expiration")
                <<< DateRow("expirationDateRow"){ row in
                    row.title = "Expiration Date"
                    row.minimumDate = Date().startOfDay + 1.day
                }.onChange{ row in
                    if self.shouldSkipOnChange {
                        return
                    }
                    
                    self.updateSaveButton()
                    self.updateIntervalRows()
                }.onCellHighlightChanged{ cell, row in
                    if !row.isHighlighted {
                        row.value = row.value ?? row.minimumDate
                    }
                }
                <<< intervalRow(title: "Days From Now", tag: "daysRow")
                <<< intervalRow(title: "Months From Now", tag: "monthsRow")
                <<< intervalRow(title: "Years From Now", tag: "yearsRow")
        
        
        updateSaveButton()
        updateIntervalRows()
        
        if let savedItemPrototypes = loadItemPrototypes() {
            itemPrototypes = savedItemPrototypes
        }
    }
    
    private func loadItemPrototypes() -> Set<ItemPrototype>? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: ItemPrototype.ArchiveURL.path) as? Set<ItemPrototype>
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            return
        }
        
        let name = (form.rowBy(tag: "nameRow") as! TextRow).value!
        let expiresAt = (form.rowBy(tag: "expirationDateRow") as! DateRow).value!
        newItem = Item(name: name, expiresAt: expiresAt)
        
        if let code = code {
            newItemPrototype = ItemPrototype(name: name, interval: expiresAt - Date(), code: code)
        }
    }
    
    private func computeAbsoluteDate() -> Date {
        let days = (form.rowBy(tag: "daysRow") as? IntRow)?.value ?? 0
        let months = (form.rowBy(tag: "monthsRow") as? IntRow)?.value ?? 0
        let years = (form.rowBy(tag: "yearsRow") as? IntRow)?.value ?? 0
        return (days.days + months.months + years.years).fromNow()!
    }
    
    private func intervalRow(title: String, tag: String) -> IntRow {
        return IntRow(tag){ row in
            row.title = title
        }.onChange{ row in
            if self.shouldSkipOnChange {
                return
            }
            self.shouldSkipOnChange = true
            let expirationDateRow = self.form.rowBy(tag: "expirationDateRow") as? DateRow
            expirationDateRow?.value = self.computeAbsoluteDate()
            expirationDateRow?.updateCell()
            self.shouldSkipOnChange = false
        }
    }
    
    private var shouldSkipOnChange = false
}
