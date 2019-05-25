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
    func didSelectSuggestionSource(suggestionSource: SuggestionSource, completeWord: String)
    func getSearchText() -> String
}

class TagListView: UIInputView {
    
    var suggestions: [Suggestion] = []
    var selectedSuggestion: Suggestion?
    
    var suggestionsDelegate: SuggestionDelegate?
    
    static private let TAGLIST_HEIGHT: CGFloat            = 35
    static let SUGGESTIONROW_HEIGHT: CGFloat              = 30
    static private let SUGGESTIONTABLE_MAXROWS: CGFloat   = 4
    static private let SUGGESTIONTABLE_MAXHEIGHT: CGFloat = TagListView.SUGGESTIONROW_HEIGHT * TagListView.SUGGESTIONTABLE_MAXROWS
    var selectionHandler: ((String) -> Void)?

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
    
    private lazy var suggestionSourcesTable: UITableView = {
        let table = UITableView()
        
        table.delegate                                  = self
        table.dataSource                                = self
        table.backgroundColor                           = .clear
        table.rowHeight                                 = TagListView.SUGGESTIONROW_HEIGHT
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(SuggestionSourcesCell.self, forCellReuseIdentifier: "SuggestionSourcesCell")
        
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
        stack.addArrangedSubview(suggestionSourcesTable)
        stack.addArrangedSubview(collectionView)
        
        addSubview(stack)
        stack.edgesToSuperview()
        
        collectionView.reloadData()
    }
    
    func hideSuggestionsTable() {
        guard areSuggestionsShown() else { return }

        suggestionsTable.removeFromSuperview()
        stack.edgesToSuperview()
    }
    
    func hideSuggestionSourcesTable() {
        guard areSuggestionSourcesShown() else { return }

        suggestionSourcesTable.removeFromSuperview()
        stack.edgesToSuperview()
    }
    
    func showSuggestionsTable() {
        guard !areSuggestionsShown() else { return }

        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        stack.addArrangedSubview(suggestionsTable)
        stack.addArrangedSubview(collectionView)

        stack.edgesToSuperview()
    }
    
    func showSuggestionSourcesTable() {
        guard !areSuggestionSourcesShown() else { return }
        
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        stack.addArrangedSubview(suggestionSourcesTable)
        stack.addArrangedSubview(collectionView)
        
        stack.edgesToSuperview()        
    }

    func areSuggestionsShown() -> Bool {
        return self.suggestionsTable.superview != nil
    }
    
    func areSuggestionSourcesShown() -> Bool {
        return self.suggestionSourcesTable.superview != nil
    }
    
    func updateSuggestions(to newSuggestions: [Suggestion]) {
        self.suggestions = newSuggestions
        
        suggestionsTable.updateConstraint(attribute: .height, constant: min(TagListView.SUGGESTIONTABLE_MAXHEIGHT, CGFloat(suggestions.count) * TagListView.SUGGESTIONROW_HEIGHT))
        
        suggestionsTable.reloadData()
    }
    
    func updateSuggestionSources(to newSuggestion: Suggestion) {
        self.selectedSuggestion = newSuggestion
        
        suggestionSourcesTable.updateConstraint(attribute: .height, constant: min(TagListView.SUGGESTIONTABLE_MAXHEIGHT, CGFloat(newSuggestion.sources.count) * TagListView.SUGGESTIONROW_HEIGHT))
        
        suggestionSourcesTable.reloadData()
    }
    
    func reloadTables() {
        if (areSuggestionsShown()) {
            suggestionsTable.reloadData()
        }
        if (areSuggestionSourcesShown()) {
            suggestionSourcesTable.reloadData()
        }
    }
}

// MARK: - collectionView Delegate & DataSource
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
        selectionHandler?("")
        collectionView.reloadData()
    }
}

// MARK: - TableView Delegate & DataSource
extension TagListView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == suggestionsTable) {
            return suggestions.count
        }
        else if (tableView == suggestionSourcesTable) {
            return selectedSuggestion?.sources.count ?? 0
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == suggestionsTable) {
            guard let cell = suggestionsTable.dequeueReusableCell(withIdentifier: "SuggestionCell", for: indexPath) as? SuggestionCell else {
                return UITableViewCell()
            }
            
            cell.render(suggestion: suggestions[indexPath.row])
            
            return cell
        }
        else if (tableView == suggestionSourcesTable) {
            guard let cell = suggestionSourcesTable.dequeueReusableCell(withIdentifier: "SuggestionSourcesCell", for: indexPath) as? SuggestionSourcesCell else {
                return UITableViewCell()
            }
            
            cell.render(source: selectedSuggestion?.sources[indexPath.row] ?? nil, completeWord: selectedSuggestion?.completeWord)
            
            return cell
        }
        else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView == suggestionsTable) {
            guard indexPath.row < suggestions.count else { return }
            
            if (suggestions[indexPath.row].sources.count > 1) {
                self.selectedSuggestion = suggestions[indexPath.row]
            }
            else {
                self.selectedSuggestion = nil
            }
            
            suggestionsDelegate?.didSelectSuggestion(suggestions[indexPath.row])
        }
        else if (tableView == suggestionSourcesTable) {
            guard let sug_sources = selectedSuggestion else { return }
            guard indexPath.row < sug_sources.sources.count else { return }
            
            suggestionsDelegate?.didSelectSuggestionSource(suggestionSource: sug_sources.sources[indexPath.row], completeWord: sug_sources.completeWord)
        }
    }
}
