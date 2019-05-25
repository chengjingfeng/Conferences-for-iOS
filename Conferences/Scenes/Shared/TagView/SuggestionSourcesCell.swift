//
//  SuggestionSourcesCell.swift
//  Conferences
//
//  Created by Pedro L. Diaz Montilla on 27/04/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit

class SuggestionSourcesCell: UITableViewCell {
    
    private let sourceLbl               = UILabel()
    private let sourceImg               = UIImageView()
    private let talksLbl                = UILabel()
    private let imgHeightWidth: CGFloat = TagListView.SUGGESTIONROW_HEIGHT * 0.5
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setup()
        layoutViews()
        style()
    }
}

// MARK: Setup
private extension SuggestionSourcesCell {
    func setup() {
        sourceLbl.numberOfLines = 0
        contentView.addSubview(sourceImg)
        contentView.addSubview(sourceLbl)
        contentView.addSubview(talksLbl)
    }
}

// MARK: Layout
private extension SuggestionSourcesCell {
    func layoutViews() {
        sourceImg.translatesAutoresizingMaskIntoConstraints = false
        sourceImg.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 15).isActive = true
        sourceImg.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        sourceImg.heightAnchor.constraint(equalToConstant: imgHeightWidth).isActive = true
        sourceImg.widthAnchor.constraint(equalToConstant: imgHeightWidth).isActive = true
        
        sourceLbl.translatesAutoresizingMaskIntoConstraints = false
        sourceLbl.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        sourceLbl.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        sourceLbl.leftAnchor.constraint(equalTo: sourceImg.rightAnchor, constant: 5).isActive = true
        sourceLbl.rightAnchor.constraint(equalTo: talksLbl.leftAnchor).isActive = true
        
        talksLbl.translatesAutoresizingMaskIntoConstraints = false
        talksLbl.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        talksLbl.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        talksLbl.leftAnchor.constraint(equalTo: sourceLbl.rightAnchor).isActive = true
        talksLbl.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -15).isActive = true
    }
}

// MARK: Style
private extension SuggestionSourcesCell {
    func style() {
        contentView.backgroundColor    = UIColor.clear
        sourceLbl.textAlignment        = .left
        sourceLbl.backgroundColor      = UIColor.clear
        talksLbl.textAlignment         = .right
        talksLbl.backgroundColor       = UIColor.clear
    }
}

// MARK: render
extension SuggestionSourcesCell {
    func render(source: SuggestionSource?, completeWord: String?) {
        
        guard let source = source, let completeWord = completeWord else { return }
        
        sourceLbl.attributedText = source.source.getAttributedText(for: completeWord)
        sourceImg.image = source.source.getImage()?.resized(to: imgHeightWidth)
        talksLbl.attributedText = NSMutableAttributedString(string: "(" + String(source.inTalks.count) + " talk" + (source.inTalks.count > 1 ? "s" : "") + ")",
                                                                 attributes: [NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 12),
                                                                              NSMutableAttributedString.Key.foregroundColor: UIColor.tertiaryText])
    }
}
