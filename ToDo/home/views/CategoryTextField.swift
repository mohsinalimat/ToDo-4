//
//  Category.swift
//  ToDo
//
//  Created by Tuyen Le on 07.04.19.
//  Copyright © 2019 Tuyen Le. All rights reserved.
//

import UIKit

class CategoryTextField: UITextField {
    
    lazy var picker: UIPickerView = {
        let picker: UIPickerView = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.dataSource = self
        picker.delegate = self
        picker.showsSelectionIndicator = true
        return picker
    }()
    
    var toolBar: UIToolbar {
        let toolBar: UIToolbar = UIToolbar()
        let doneButton: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneCategoryAction))
        let spaceButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton: UIBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelCategoryAction))

        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        return toolBar
    }
    
    var categoryChoice: ((Type) -> Void)?

    init() {
        super.init(frame: .zero)
        inputView = picker
        inputAccessoryView = toolBar
        becomeFirstResponder()
    }
    
    @objc func doneCategoryAction() {
        let selectedIndex: Int = picker.selectedRow(inComponent: 0)

        if Type.Home.rawValue == todoCategories[selectedIndex] {
            categoryChoice?(Type.Home)
        } else if Type.Grocery.rawValue == todoCategories[selectedIndex] {
            categoryChoice?(Type.Grocery)
        } else if Type.Other.rawValue == todoCategories[selectedIndex] {
            categoryChoice?(Type.Other)
        } else if Type.Personal.rawValue == todoCategories[selectedIndex] {
            categoryChoice?(Type.Personal)
        } else if Type.Travel.rawValue == todoCategories[selectedIndex] {
            categoryChoice?(Type.Travel)
        } else {
            categoryChoice?(Type.Work)
        }

        resignFirstResponder()
        removeFromSuperview()
    }
    
    @objc func cancelCategoryAction() {
        resignFirstResponder()
        removeFromSuperview()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CategoryTextField: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 6
    }
}

extension CategoryTextField: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return todoCategories[row]
    }
}
