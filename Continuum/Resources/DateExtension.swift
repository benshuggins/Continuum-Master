//
//  DateExtension.swift
//  Continuum
//
//  Created by Ben Huggins on 2/26/19.
//  Copyright © 2019 trevorAdcock. All rights reserved.
//

import Foundation

extension Date {
    func stringWith(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        return formatter.string(from: self)
    }
}
