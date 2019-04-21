//
//  SuggestionCell.swift
//  Conferences
//
//  Created by Pedro L. Diaz Montilla on 20/04/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit

class SuggestionCell: UITableViewCell {
    
    let suggestionLbl = UILabel()

    override func layoutSubviews() {
        super.layoutSubviews()
        
        setup()
        layoutViews()
        style()
    }
}

// MARK: Setup
private extension SuggestionCell {
    func setup() {
        suggestionLbl.numberOfLines = 0
        contentView.addSubview(suggestionLbl)
    }
}

// MARK: Layout
private extension SuggestionCell {
    func layoutViews() {
        suggestionLbl.translatesAutoresizingMaskIntoConstraints = false
        suggestionLbl.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        suggestionLbl.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        suggestionLbl.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 15).isActive = true
        suggestionLbl.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -15).isActive = true
    }
}

// MARK: Style
private extension SuggestionCell {
    func style() {
        contentView.backgroundColor = UIColor.clear
        suggestionLbl.textAlignment    = .left
        suggestionLbl.backgroundColor  = UIColor.clear

    }
}

// MARK: render
extension SuggestionCell {
    func render(suggestion: Suggestion) {
        self.suggestionLbl.attributedText = suggestion.getAttributedText()
    }
}


