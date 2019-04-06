//
//  TagListView.swift
//  Conferences
//
//  Created by Pedro L. Diaz Montilla on 02/04/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit

protocol TagListViewDelegate: class {
    func didTagSelected()
    func didTagFilter()
    func getFilterResult() -> (conferences: Int, talks: Int)
}

class TagListView: UIView {

    private var tagButtons: [TagButton] = []
    private var rowViews: [UIView] = []
    weak var delegate: TagListViewDelegate?
    
    init() {
        super.init(frame: CGRect.zero)
        
        configureTags()
        self.backgroundColor = UIColor.elementBackground
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        defer { configureTags() }
        super.layoutSubviews()
    }
    
    func configureTags() {
        let tags = TagSyncService.shared.tags
        
        let xPadding: CGFloat = 25
        let yPadding: CGFloat = 10
        
        var rowView: UIView!
        var rowNumber: Int        = 0
        var rowTagCount: Int      = 0
        var rowWidth: CGFloat     = 0
        var buttonHeight: CGFloat = 0
        
        let resultRow = UIView()
        let doneButton = UIButton()
        let resultText = UILabel()
        
        let views = tagButtons as [UIView] + rowViews + [resultRow, doneButton, resultText]
        views.forEach { $0.removeFromSuperview() }
        tagButtons.removeAll(keepingCapacity: true)
        rowViews.removeAll(keepingCapacity: true)
        
        rowViews.append(resultRow)
        resultRow.frame.origin.y = 1
        self.addSubview(resultRow)

        resultRow.addSubview(resultText)
        resultRow.addSubview(doneButton)

        if let del = delegate {
            let filterResult = del.getFilterResult()
            didFilter(conferences: filterResult.conferences, talks: filterResult.talks)
        }
        else {
            resultText.text = ""
        }
        resultText.textColor = .tertiaryText
        resultText.font = .systemFont(ofSize: 13)
        
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(.secondaryText, for: .normal)
        doneButton.titleLabel?.font = .systemFont(ofSize: 15)
        doneButton.addTarget(self, action: #selector(donePressed), for: .touchUpInside)
        
        resultText.frame.size = resultText.intrinsicContentSize
        doneButton.frame.size = doneButton.intrinsicContentSize

        resultRow.frame.size.width  = UIScreen.main.bounds.width
        resultRow.frame.size.height = max(resultText.frame.height, doneButton.frame.height)

        resultText.translatesAutoresizingMaskIntoConstraints = false
        resultText.leftAnchor.constraint(equalTo: resultRow.leftAnchor, constant: 10).isActive = true
        resultText.centerYAnchor.constraint(equalTo: resultRow.centerYAnchor).isActive = true
        
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.rightAnchor.constraint(equalTo: resultRow.rightAnchor, constant: -10).isActive = true
        doneButton.centerYAnchor.constraint(equalTo: resultRow.centerYAnchor).isActive = true
        
        tags.forEach { (tag) in
            
            let button = TagButton()
            tagButtons.append(button)
            button.setTag(to: tag)
            button.setDelegate(to: self)
            
            button.frame.size = button.intrinsicContentSize
            buttonHeight = button.frame.height
            
            if (rowTagCount == 0 || rowWidth + button.frame.width > UIScreen.main.bounds.width) {
                rowNumber   = rowNumber + 1
                rowWidth    = 0
                rowTagCount = 0
                rowView     = UIView()
                rowViews.append(rowView)
                rowView.frame.origin.y = (resultRow.frame.size.height + yPadding) + CGFloat(rowNumber - 1) * (buttonHeight + yPadding)

                self.addSubview(rowView)
                button.frame.size.width = min(button.frame.size.width, UIScreen.main.bounds.width)
            }
            
            button.frame.origin = CGPoint(x: rowWidth + xPadding, y: 0)
            rowView.addSubview(button)
            
            rowTagCount = rowTagCount + 1
            rowWidth += button.frame.width + xPadding
            
            rowView.frame.size.width = rowWidth + xPadding
            rowView.frame.size.height = max(buttonHeight, rowView.frame.height)
            
            rowView.frame.origin.x = (UIScreen.main.bounds.width - (rowView.frame.size.width)) / 2
        }
        
        self.frame.size.width = UIScreen.main.bounds.width
        self.frame.size.height = rowViews.map { $0.frame.size.height + yPadding }.reduce(0, +) - yPadding/2
    }
    
    @objc func donePressed() {
        delegate?.didTagFilter()
    }

}

extension TagListView: TagButtonDelegate {
    func didSelectTag(_ tag: TagModel) {
        var copy = tag
        copy.isActive.toggle()
        TagSyncService.shared.handleTag(&copy)
        
        delegate?.didTagSelected()
    }
}

extension TagListView: ListViewUpdater {
    func didFilter(conferences: Int, talks: Int) {
        let label = rowViews.first?.subviews.filter { $0 is UILabel }.first as? UILabel
        label?.text = "\(conferences) conferences, \(talks) talks"
    }
}

