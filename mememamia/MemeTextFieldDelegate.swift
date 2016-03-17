//
//  MemeTextFieldDelegate.swift
//  mememamia
//
//  Created by Timur Ridjanovic on 1/31/16.
//  Copyright © 2016 Timur Ridjanovic. All rights reserved.
//

import Foundation
import UIKit

let maxCharacters = 35

class MemeTextFieldDelegate: NSObject, UITextFieldDelegate {
    internal var imageView: UIImageView!
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField.text?.characters.count >= maxCharacters && range.length == 0 {
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.clearsOnBeginEditing = false
    }
}
