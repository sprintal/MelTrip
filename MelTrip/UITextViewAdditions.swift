//
//  UITextViewAdditions.swift
//  MelTrip
//
//  Created by Kang Meng on 5/9/19.
//  Copyright © 2019 Kang Meng. All rights reserved.
//

import Foundation
import UIKit

extension UITextView {
    /// Add toolbar and button when keyboard appears for text view
    /// From http://www.swiftdevcenter.com/uitextview-dismiss-keyboard-swift/
    func addDoneButton(title: String, target: Any, selector: Selector)  {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44.0))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let barButton = UIBarButtonItem(title: title, style: .plain, target: target, action: selector)
        toolBar.setItems([flexible, barButton], animated: false)
        self.inputAccessoryView = toolBar
    }
}
