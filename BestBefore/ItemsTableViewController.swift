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
import UserNotifications
import UIEmptyState

class ItemTableViewCell: UITableViewCell {
    var expiresAt: Date!
    
    public func updateDetails() {
        if expiresAt > Date() {
            let expirationInterval = expiresAt - Date()
            let days = expirationInterval.in(.day)!
            detailTextLabel?.text = "Expires in \(days + 1) days"
            detailTextLabel?.textColor = UIColor.darkGray
        } else {
            detailTextLabel?.text = "Expired"
            detailTextLabel?.textColor = UIColor.red
        }
    }
}

class ItemsTableViewController: UITableViewController, UIEmptyStateDataSource, UIEmptyStateDelegate {
    private var items = [Item]()
    private var itemPrototypes = Set<ItemPrototype>()
    
    @IBAction func unwindFromModal(unwindSegue: UIStoryboardSegue) {
        if let sourceViewController = unwindSegue.source as? NewItemFormViewController, let item = sourceViewController.newItem {
            if let itemPrototype = sourceViewController.newItemPrototype {
                addItemPrototype(itemPrototype)
            }
            items.append(item)
            self.items = items.sorted { $0.expiresAt < $1.expiresAt }
            let newIndex = items.index(of: item)!
            tableView.insertRows(at: [IndexPath(row: newIndex, section: 0)], with: .top)
            saveItems()
            scheduleNotification(item, newIndex)
        }
    }
    
    // MARK: Empty State Delegate
    
    func emptyStateViewWillShow(view: UIView) {
        guard let emptyView = view as? UIEmptyStateView else { return }
        emptyView.button.layer.cornerRadius = 5
        emptyView.button.layer.backgroundColor = AppDelegate.color.cgColor
    }
    
    func emptyStatebuttonWasTapped(button: UIButton) {
        performSegue(withIdentifier: "AddItem", sender: self)
    }
    
    var emptyStateTitle = NSAttributedString(string: "There are no items to display.")
    var emptyStateButtonTitle: NSAttributedString? {
        let attrs = [NSAttributedStringKey.foregroundColor: UIColor.white,
                     NSAttributedStringKey.font: AppDelegate.boldFont!]
        return NSAttributedString(string: "Add Your First Item", attributes: attrs)
    }
    
    var emptyStateButtonSize: CGSize? {
        return CGSize(width: 180, height: 40)
    }

    
    //MARK: initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emptyStateDataSource = self
        self.emptyStateDelegate = self
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.reloadEmptyState()
        
        if let savedItems = loadItems() {
            items += savedItems
        }
        
        if let savedItemPrototypes = loadItemPrototypes() {
            itemPrototypes = savedItemPrototypes
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! ItemTableViewCell
        
        if indexPath.row < items.count
        {
            let item = items[indexPath.row]
            cell.textLabel?.text = item.name
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
            tableView.deleteRows(at: [indexPath], with: .top)
            saveItems()
            unscheduleNotification(indexPath.row)
        }
    }
    
    //MARK: Private Methods
    
    private func saveItems() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(items, toFile: Item.ArchiveURL.path)
        
        self.reloadEmptyState()
        
        if isSuccessfulSave {
            os_log("Items successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save items.", log: OSLog.default, type: .error)
        }
    }
    
    private func saveItemPrototypes() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(itemPrototypes, toFile: ItemPrototype.ArchiveURL.path)
        
        if isSuccessfulSave {
            os_log("Item prototypes successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save item prototypes.", log: OSLog.default, type: .error)
        }
    }
    
    private func loadItems() -> [Item]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Item.ArchiveURL.path) as? [Item]
    }
    
    private func addItemPrototype(_ prototype: ItemPrototype) {
        itemPrototypes.update(with: prototype)
        saveItemPrototypes()
    }
    
    private func loadItemPrototypes() -> Set<ItemPrototype>? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: ItemPrototype.ArchiveURL.path) as? Set<ItemPrototype>
    }
    
    private func scheduleNotification(_ item: Item, _ index: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Item About to Expire"
        content.body = "\"\(item.name)\" is going to expire tomorrow."
        content.sound = UNNotificationSound.default()
    
        let time = (item.expiresAt - 1.day)
        let interval = (time.atTime(hour: 8, minute: 0, second: 0) ?? time) - Date()
        
        if interval > 0 {
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
            let request = UNNotificationRequest(identifier: "ExpirationAlarm.\(index)", content: content, trigger: trigger)
            let center = UNUserNotificationCenter.current()
            
            center.add(request) { (error : Error?) in
                if let _ = error {
                    os_log("Failed to schedule notification.", log: OSLog.default, type: .error)
                }
            }
        }
    }
    
    private func unscheduleNotification(_ index: Int) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["ExpirationAlarm.\(index)"])
    }
}

