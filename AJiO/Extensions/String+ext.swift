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
        
        var phoneNumber = self.replacingOccurrences(of: "-", with: "").replacingOccurrences(of: " ", with: "").filter { !$0.isLetter }
        
        let pattern = #"^48"#
        let regex = try! Regex(pattern)
        
        if phoneNumber.firstMatch(of: regex) != nil {
            phoneNumber = "+" + phoneNumber
        }
        
        return phoneNumber
    }
}
