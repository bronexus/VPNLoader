//
//  UIApplicationExtensions.swift
//  Cocoacasts
//
//  Created by Dumitru on 27.03.2022.
//

import UIKit

extension UIApplication {
	func endEditing() {
		sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
	}
}
