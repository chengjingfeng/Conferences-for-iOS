//
//  TagListView.swift
//  Conferences
//
//  Created by Pedro L. Diaz Montilla on 02/04/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit

protocol SuggestionDelegate {
    func didSelectSuggestion(_ suggestion: Suggestion)
    func getSearchText() -> String
}

class TagListView: UIInputView {
    
    var suggestions: [Suggestion] = []
    
    var suggestionsDelegate: SuggestionDelegate?
    
    static private let TAGLIST_HEIGHT: CGFloat            = 35
    static let SUGGESTIONROW_HEIGHT: CGFloat              = 25
    static private let SUGGESTIONTABLE_MAXROWS: CGFloat   = 4
    static private let SUGGESTIONTABLE_MAXHEIGHT: CGFloat = TagListView.SUGGESTIONROW_HEIGHT * TagListView.SUGGESTIONTABLE_MAXROWS

    init() {
        super.init(frame: .zero, inputViewStyle: .default)
        configureView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var tags = TagSyncService.shared.tags
    
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        cv.delegate = self
        cv.dataSource = self
        cv.register(TagCell.self, forCellWithReuseIdentifier: "TagViewCell")
        cv.allowsMultipleSelection = false
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.allowsSelection = true
        cv.height(TagListView.TAGLIST_HEIGHT)
        
        if let layout = cv.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = CGSize(width: 50, height: 20)
            layout.scrollDirection = .horizontal
            layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 0, right: 5)
        }
        
        return cv
    }()
    
    private lazy var suggestionsTable: UITableView = {
        let table = UITableView()
        
        table.delegate        = self
        table.dataSource      = self
        table.backgroundColor = .clear
        table.rowHeight       = TagListView.SUGGESTIONROW_HEIGHT
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(SuggestionCell.self, forCellReuseIdentifier: "SuggestionCell")
        
        return table
    }()
    
    private var stack: UIStackView = {
        let st = UIStackView()

        st.axis    = .vertical
        st.spacing = 0
        
        return st
    }()
    
    func configureView() {
        allowsSelfSizing = true
        self.translatesAutoresizingMaskIntoConstraints = false

        stack.addArrangedSubview(suggestionsTable)
        stack.addArrangedSubview(collectionView)
        
        addSubview(stack)
        stack.edgesToSuperview()
        
        collectionView.reloadData()
    }
    
    func hideSuggestionsTable() {

        if (areSuggestionsShown()) {
            suggestionsTable.removeFromSuperview()

            stack.edgesToSuperview()
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 0, right: 5)
            }

        }
    }
    
    func showSuggestionsTable() {

        if (!areSuggestionsShown()) {
            stack.removeArrangedSubview(suggestionsTable)
            stack.removeArrangedSubview(collectionView)
            
            stack.addArrangedSubview(suggestionsTable)
            stack.addArrangedSubview(collectionView)

            stack.edgesToSuperview()
        }
    }

    func areSuggestionsShown() -> Bool {
        return self.suggestionsTable.superview != nil
    }
    
    func updateSuggestions(to newSuggestions: [Suggestion]) {
        self.suggestions = newSuggestions
        
        if let constraint = (suggestionsTable.constraints.filter{$0.firstAttribute == .height}.first) {
            constraint.constant = min(TagListView.SUGGESTIONTABLE_MAXHEIGHT, CGFloat(suggestions.count) * TagListView.SUGGESTIONROW_HEIGHT)
        }
        else {
            suggestionsTable.height(min(TagListView.SUGGESTIONTABLE_MAXHEIGHT, CGFloat(suggestions.count) * TagListView.SUGGESTIONROW_HEIGHT))
        }
        
        suggestionsTable.reloadData()
    }
}

extension TagListView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagViewCell", for: indexPath) as? TagCell else { return UICollectionViewCell() }
        
        let tag = tags[indexPath.row]
        cell.configureView(with: tag)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var tag = tags[indexPath.row]
        tag.isActive.toggle()
        
        TagSyncService.shared.handleTag(&tag)
        self.tags = TagSyncService.shared.tags
        collectionView.reloadData()
    }
}

// MARK: - Suggestions Table
extension TagListView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = suggestionsTable.dequeueReusableCell(withIdentifier: "SuggestionCell", for: indexPath) as? SuggestionCell else {
            return UITableViewCell()
        }
        
        cell.render(suggestion: suggestions[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < suggestions.count else { return }
        
        suggestionsDelegate?.didSelectSuggestion(suggestions[indexPath.row])
    }
}
