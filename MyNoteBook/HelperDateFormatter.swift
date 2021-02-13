//
//  HelperDateFormatter.swift
//  MyNoteBook
//
//  Created by Jorge Sanchez on 03/02/2021.
//

import Foundation

enum HelperDateFormatter {
    static var format: DateFormatter{
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
    
    static func textFrom(date: Date)-> String{
        
        return format.string(from: date)
    }
    
}
