//
//  ItemsTableViewController.swift
//  BestBefore
//
//  Created by Matteo Depalo on 31/01/2018.
//  Copyright © 2018 Caldera Labs. All rights reserved.
//

import UIKit
import SwiftDate
import os.log

class ItemTableViewCell: UITableViewCell {
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var picture: UIImageView!
    
    var expiresAt: Date!
    
    public func updateDetails() {
        if expiresAt > Date() {
            let expirationInterval = expiresAt - Date()
            let days = expirationInterval.in(.day)!
            detailsLabel.text = "Expires in: \(days + 1) days"
        } else {
            detailsLabel.text = "Expired!"
        }
    }
}

class ItemsTableViewController: UITableViewController {
    private var items = [Item]()
    
    //MARK: initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let savedItems = loadItems() {
            items += savedItems
        }
    }
    
    //MARK: timer
    
    weak var timer: Timer?
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.tableView.visibleCells.forEach { cell in
                let tableCell = cell as? ItemTableViewCell
                tableCell?.updateDetails()
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        startTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopTimer()
    }
    
    //MARK: table
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_item", for: indexPath) as! ItemTableViewCell
        
        if indexPath.row < items.count
        {
            let item = items[indexPath.row]
            cell.picture.image = item.picture
            cell.expiresAt = item.expiresAt
            cell.updateDetails()
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if indexPath.row < items.count
        {
            items.remove(at: indexPath.row)
            saveItems()
            tableView.deleteRows(at: [indexPath], with: .top)
        }
    }
    
    //MARK: Private Methods
    
    private func addNewItem(picture: UIImage, expiresAt: Date)
    {
        let item = Item(picture: picture, expiresAt: expiresAt)
        items.append(item)
        self.items = items.sorted { $0.expiresAt < $1.expiresAt }
        let newIndex = items.index(of: item)!
        tableView.insertRows(at: [IndexPath(row: newIndex, section: 0)], with: .top)
        saveItems()
    }
    
    private func saveItems() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(items, toFile: Item.ArchiveURL.path)
        
        if isSuccessfulSave {
            os_log("Items successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save items...", log: OSLog.default, type: .error)
        }
    }
    
    private func loadItems() -> [Item]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Item.ArchiveURL.path) as? [Item]
    }
}

extension ItemsTableViewController: NewItemDelegate {
    func addItem(picture: UIImage?, days: Int?) {
        if let picture = picture, let days = days {
            let expiresAt = Date() + days.days
            addNewItem(picture: picture, expiresAt: expiresAt)
        } else {
            print("No values selected in the form")
        }
    }
}


