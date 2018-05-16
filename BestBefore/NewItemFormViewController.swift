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

class NewItemFormViewController: FormViewController, UINavigationControllerDelegate {
    @IBOutlet weak var saveButton: UIBarButtonItem!
    var newItem: Item?
    var newItemPrototype: ItemPrototype?
    var code: String?
    var itemPrototypes: Set<ItemPrototype>?
    
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
        
        func defaultSetupSection(_ text: String) -> ((Section) -> ()) {
            return { section in
                var header = HeaderFooterView<UITableViewHeaderFooterView>(.class)
                header.height = {UITableViewAutomaticDimension}
                header.onSetupView = { view, section in
                    view.textLabel?.numberOfLines = 0
                    view.textLabel?.font = AppDelegate.font?.withSize(14)
                    view.textLabel?.text = text.uppercased()
                }
                
                section.header = header
            }
        }
        
        form
            +++ Section(defaultSetupSection("Details"))
                <<< TextRow("nameRow"){ row in
                    row.title = "Name"
                    row.placeholder = "Enter product name here"
                }.onChange{ row in
                    self.updateSaveButton()
                }
            +++ Section(defaultSetupSection("Expiration"))
                <<< DateRow("expirationDateRow"){ row in
                    row.title = "Date"
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
            +++ Section(defaultSetupSection("From Now"))
                <<< intervalRow(title: "Days", tag: "daysRow")
                <<< intervalRow(title: "Months", tag: "monthsRow")
                <<< intervalRow(title: "Years", tag: "yearsRow")
        
        
        if let savedItemPrototypes = loadItemPrototypes() {
            itemPrototypes = savedItemPrototypes
        }
        
        if let code = code, let itemPrototypes = itemPrototypes {
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
        
        updateSaveButton()
        updateIntervalRows()
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
            row.placeholder = "Enter number of \(title.lowercased())"
        }.onChange{ row in
            if self.shouldSkipOnChange {
                return
            }
            self.shouldSkipOnChange = true
            let expirationDateRow = self.form.rowBy(tag: "expirationDateRow") as? DateRow
            expirationDateRow?.value = self.computeAbsoluteDate()
            expirationDateRow?.updateCell()
            self.shouldSkipOnChange = false
            self.updateSaveButton()
        }
    }
    
    private var shouldSkipOnChange = false
}
