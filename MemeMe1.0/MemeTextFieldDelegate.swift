//
//  MemeTextFieldDelegate.swift
//  MemeMe1.0
//
//  Created by John Berndt on 11/14/18.
//  Copyright © 2018 John Berndt. All rights reserved.
//

import UIKit
import Foundation

class MemeTextFieldDelegate : NSObject, UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
        return false
    }

}
