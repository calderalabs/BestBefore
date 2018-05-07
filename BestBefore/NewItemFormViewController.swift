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
        
        if let itemPrototypes = itemPrototypes {
            if let itemPrototype = itemPrototypes.first(where: { prototype in
                prototype.code == code
            }) {
                let expiresAt = Date().startOfDay.addingTimeInterval(itemPrototype.interval)
                (form.rowBy(tag: "nameRow") as? TextRow)?.value = itemPrototype.name
                (form.rowBy(tag: "pictureRow") as? ImageRow)?.value = itemPrototype.picture
                (form.rowBy(tag: "expirationDateRow") as? DateRow)?.value = expiresAt
            }
        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    private func updateSaveButton() {
        let name = (form.rowBy(tag: "nameRow") as? TextRow)!
        
        if let nameValue = name.value {
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
        let expirationInterval = row.value! - Date().startOfDay
        
        let components = expirationInterval.in([.day, .month, .year])
        self.shouldSkipOnChange = true
        daysRow?.value = components[.day]
        monthsRow?.value = components[.month]
        yearsRow?.value = components[.year]
        self.shouldSkipOnChange = false
        daysRow?.updateCell()
        monthsRow?.updateCell()
        yearsRow?.updateCell()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form
            +++ ButtonRow() { row in
                    row.title = "Populate from bar code..."
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
                <<< ImageRow("pictureRow"){ row in
                    row.title = "Picture"
                    row.sourceTypes = [.Camera]
                    }
            +++ Section("Expiration")
                <<< DateRow("expirationDateRow"){ row in
                    row.title = "Expiration Date"
                    row.value = Date().startOfDay + 1.day
                    row.minimumDate = Date().startOfDay + 1.day
                }.onChange{ row in
                    if self.shouldSkipOnChange {
                        return
                    }
                    
                    self.updateIntervalRows()
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
        let picture = (form.rowBy(tag: "pictureRow") as! ImageRow).value
        let expiresAt = (form.rowBy(tag: "expirationDateRow") as! DateRow).value!
        newItem = Item(name: name, picture: picture, expiresAt: expiresAt.startOfDay)
        
        if let code = code {
            newItemPrototype = ItemPrototype(name: name, picture: picture, interval: expiresAt.startOfDay - Date().startOfDay, code: code)
        }
    }
    
    private func computeAbsoluteDate() -> Date {
        let days = (form.rowBy(tag: "daysRow") as? IntRow)?.value ?? 0
        let months = (form.rowBy(tag: "monthsRow") as? IntRow)?.value ?? 0
        let years = (form.rowBy(tag: "yearsRow") as? IntRow)?.value ?? 0
        return ((days + 1).days + months.months + years.years).fromNow()!.startOfDay
    }
    
    private func intervalRow(title: String, tag: String) -> IntRow {
        return IntRow(tag){ row in
            row.title = title
            row.value = 0
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
