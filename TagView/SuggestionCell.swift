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
    let talksLbl      = UILabel()
    
    private let stackImg: UIStackView = {
        let s = UIStackView()
        
        s.axis    = .horizontal
        s.spacing = 2
        
        return s
    }()

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
        contentView.addSubview(stackImg)
        contentView.addSubview(suggestionLbl)
        contentView.addSubview(talksLbl)
    }
}

// MARK: Layout
private extension SuggestionCell {
    func layoutViews() {
        stackImg.translatesAutoresizingMaskIntoConstraints = false
        stackImg.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 15).isActive = true
        stackImg.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        
        suggestionLbl.translatesAutoresizingMaskIntoConstraints = false
        suggestionLbl.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        suggestionLbl.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        suggestionLbl.leftAnchor.constraint(equalTo: stackImg.rightAnchor, constant: 5).isActive = true
        suggestionLbl.rightAnchor.constraint(equalTo: talksLbl.leftAnchor).isActive = true
        
        talksLbl.translatesAutoresizingMaskIntoConstraints = false
        talksLbl.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        talksLbl.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        talksLbl.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -15).isActive = true
    }
}

// MARK: Style
private extension SuggestionCell {
    func style() {
        contentView.backgroundColor = UIColor.clear
        suggestionLbl.textAlignment    = .left
        suggestionLbl.backgroundColor  = UIColor.clear
        talksLbl.textAlignment         = .right
        talksLbl.backgroundColor       = UIColor.clear
    }
}

// MARK: render
extension SuggestionCell {
    func render(suggestion: Suggestion) {
        var imgview: UIImageView
        let imgHeightWidth: CGFloat = TagListView.SUGGESTIONROW_HEIGHT * 0.5

        for v in stackImg.arrangedSubviews { v.removeFromSuperview() }
        
        for source in suggestion.sources.sorted(by: { ($0.source.rawValue.order ?? 0) < ($1.source.rawValue.order ?? 0) }) {
            imgview = UIImageView(image: source.source.getImage()?.resized(to: imgHeightWidth))
            self.stackImg.addArrangedSubview(imgview)
        }
        
        if let constraint = (stackImg.constraints.filter{$0.firstAttribute == .width}.first) {
            constraint.constant = (imgHeightWidth + 2) * CGFloat(suggestion.sources.count)
        }
        else {
            stackImg.width((imgHeightWidth + 2) * CGFloat(suggestion.sources.count))
        }

        
        self.suggestionLbl.attributedText = suggestion.getAttributedText()
        self.talksLbl.attributedText = NSMutableAttributedString(string: "(" + String(suggestion.inTalks.count) + " talk" + (suggestion.inTalks.count > 1 ? "s" : "") + ")",
                                                                 attributes: [NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 12),
                                                                              NSMutableAttributedString.Key.foregroundColor: UIColor.tertiaryText])

    }
}

extension UIImage {
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

