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
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form
            +++ Section("Details")
                <<< TextRow(){ row in
                    row.title = "Name"
                    row.placeholder = "Enter product name here"
                }
                <<< ImageRow(){ row in
                    row.title = "Photo"
                    row.sourceTypes = [.Camera]
                }
            +++ Section("Expiration")
                <<< DateRow("expirationDateRow"){ row in
                    row.title = "Expiration Date"
                    row.value = Date()
                }.onChange{ row in
                    if self.shouldSkipOnChange {
                        return
                    }
                    let daysRow = self.form.rowBy(tag: "daysRow") as? IntRow
                    let monthsRow = self.form.rowBy(tag: "monthsRow") as? IntRow
                    let yearsRow = self.form.rowBy(tag: "yearsRow") as? IntRow
                    let expirationInterval = row.value! - Date()
                    
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
                <<< intervalRow(title: "Days From Now", tag: "daysRow")
                <<< intervalRow(title: "Months From Now", tag: "monthsRow")
                <<< intervalRow(title: "Years From Now", tag: "yearsRow")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func computeAbsoluteDate() -> Date {
        let days = (form.rowBy(tag: "daysRow") as? IntRow)?.value ?? 0
        let months = (form.rowBy(tag: "monthsRow") as? IntRow)?.value ?? 0
        let years = (form.rowBy(tag: "yearsRow") as? IntRow)?.value ?? 0
        return ((days + 1).days + months.months + years.years).fromNow()!
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
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
