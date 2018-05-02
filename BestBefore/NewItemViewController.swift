//
//  NewItemViewController.swift
//  BestBefore
//
//  Created by Matteo Depalo on 31/01/2018.
//  Copyright © 2018 Caldera Labs. All rights reserved.
//

import UIKit
import os.log

protocol NewItemDelegate
{
    func addItem(picture: UIImage?, days: Int?)
}

class NewItemViewController: UIViewController, UINavigationControllerDelegate {
    @IBOutlet weak var days: UITextField!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    var delegate: NewItemDelegate?
    var imageSelected: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        days.delegate = self
        addDoneButtonOnKeyboard()
        updateSaveButton()
    }
    
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.days.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction() {
        self.days.resignFirstResponder()
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        if let daysText = self.days.text, let days = Int(daysText), let picture = picture.image {
            self.delegate?.addItem(picture: picture, days: days)
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func takePhoto(_ sender: UITapGestureRecognizer) {
        days.resignFirstResponder()
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    private func enableSaveButton() -> Bool {
        if let daysText = self.days.text, let imageSelected = imageSelected {
            return !daysText.isEmpty && imageSelected
        } else {
            return false
        }
    }
    
    public func updateSaveButton() {
        saveButton.isEnabled = enableSaveButton()
    }
}

extension NewItemViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButton()
    }
}

extension NewItemViewController: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            os_log("Expected a dictionary containing an image, but was provided the following: %@", log: OSLog.default, type: .error, info)
            return
        }
        
        picture.image = selectedImage
        self.imageSelected = true
        updateSaveButton()
        dismiss(animated: true, completion: nil)
    }
}
