//
//  Suggestion.swift
//  Conferences
//
//  Created by Pedro L. Diaz Montilla on 21/04/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation
import UIKit


struct Suggestion {
    var text: String
    var completeWord: String
    private var attributedText: NSAttributedString
    
    init(text: String, completeWord: String) {
        
        self.text = text
        self.completeWord = completeWord
        self.attributedText = NSAttributedString()
        
        self.attributedText = setAttributedText()
    }
    
    func getAttributedText() -> NSAttributedString {
        return self.attributedText
    }
    
    private func setAttributedText() -> NSAttributedString {
        var attributed = NSMutableAttributedString()
        
        if let index = completeWord.startIndex(of: text) {
            let str = String(completeWord.prefix(upTo: index))
            attributed = NSMutableAttributedString(string: str, attributes: [NSMutableAttributedString.Key.font: UIFont.systemFont(ofSize: 13),
                                                                             NSMutableAttributedString.Key.foregroundColor: UIColor.tertiaryText])
        }
        
        attributed.append(NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 13)]))
        
        if let index = completeWord.endIndex(of: text) {
            let str = String(completeWord.suffix(from: index))
            attributed.append(NSMutableAttributedString(string: str, attributes: [NSMutableAttributedString.Key.font: UIFont.systemFont(ofSize: 13),
                                                                                  NSMutableAttributedString.Key.foregroundColor: UIColor.tertiaryText]))
        }
        
        return attributed
    }
}

extension StringProtocol where Index == String.Index {
    func startIndex(of string: Self, options: String.CompareOptions = []) -> Index? {
        return range(of: string, options: options)?.lowerBound
    }
    
    func endIndex(of string: Self, options: String.CompareOptions = []) -> Index? {
        return range(of: string, options: options)?.upperBound
    }
}


