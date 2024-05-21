//
//  String+ext.swift
//  AJiO
//
//  Created by Maksymilian Stan on 21/05/2024.
//

import Foundation

extension String {
    func formatPhoneNumber() -> String {
        guard self.count > 1 else { return "" }
        
        if self.first != "+" {
            return "+" + self.replacingOccurrences(of: "-", with: "")
        } else {
            return self.replacingOccurrences(of: "-", with: "")
        }
    }
}
