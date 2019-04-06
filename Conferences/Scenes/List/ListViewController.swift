//
//  ListViewController.swift
//  Conferences
//
//  Created by Zagahr on 23/03/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit

protocol ListViewUpdater {
    func didFilter(conferences: Int, talks: Int)
}

class ListViewController: UITableViewController {
    
    weak var splitDelegate: SplitViewDelegate?
    var detailViewController: DetailViewController? = nil
    var apiClient = APIClient()
    let searchController = UISearchController(searchResultsController: nil)
    let tagListView = TagListView()
    let dataSource = ListViewDataSource()
    private let talkService = TalkService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.delegate = self

        configureTableView()
        configureSearchBar()
        talkService.delegate = self
        talkService.fetchData()
    }
    
    func reloadTableView() {
        tableView.reloadData()
    }
    
    private func configureTableView() {
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.panelBackground
        tableView.sectionHeaderHeight = 220
        tableView.rowHeight = 70
        tableView.register(TalkViewCell.self, forCellReuseIdentifier: "TalkViewCell")
    }
    
    func configureSearchBar() {
        searchController.searchBar.delegate = self
        searchController.searchBar.barStyle = .blackTranslucent
        searchController.searchBar.placeholder = "search ..."
        searchController.searchBar.autocapitalizationType = .none
        
        tagListView.delegate = self
        searchController.searchBar.inputAccessoryView = tagListView
                
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        
        navigationItem.searchController = searchController
        self.definesPresentationContext = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let talk = dataSource.conferences[indexPath.section].talks[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.configureView(with: talk)
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.conferences.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.conferences[section].talks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TalkViewCell", for: indexPath) as? TalkViewCell else {
            return UITableViewCell()
        }
        
        let talk = dataSource.conferences[indexPath.section].talks[indexPath.row]
        cell.configureView(with: talk)
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.elementBackground
        cell.selectedBackgroundView = bgColorView
        cell.backgroundColor = UIColor.elementBackground
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let conferenceView = ConferenceHeaderView(safeAreaInsets: tableView.safeAreaInsets)
        let conference = dataSource.conferences[section]
        
        conferenceView.configureView(with: conference)
        
        return conferenceView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let talk = dataSource.conferences[indexPath.section].talks[indexPath.row]
        splitDelegate?.didSelectTalk(talk: talk)
    }
}

extension ListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        talkService.filterTalks(by: searchController.searchBar.text ?? "")
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        reload()
    }
}

// MARK: - Search methods
extension ListViewController {
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && (!searchBarIsEmpty() || TagSyncService.shared.activeTags().count > 0)
    }
}

// MARK: - UISearchBar Delegate
extension ListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {

    }
}

// MARK: - TagListView Delegate
extension ListViewController: TagListViewDelegate {
    func didTagSelected() {
        tagListView.configureTags()
    }
    
    func didTagFilter() {
        didTagSelected()
        searchController.isActive = false
    }

    func getFilterResult() -> (conferences: Int, talks: Int) {
        return (conferences: dataSource.conferences.count, talks: dataSource.conferences.map { $0.talks.count }.reduce(0,+))
    }
}

extension ListViewController: ListViewDataSourceDelegate {
    func didSelectTalk(_ talk: TalkModel) {
        self.splitDelegate?.didSelectTalk(talk: talk)
    }
    
    func reload() {
        let result = getFilterResult()
        tagListView.didFilter(conferences: result.conferences, talks: result.talks)
        tableView.reloadData()
    }
}

extension ListViewController: TalkServiceDelegate {
    func didFetch(_ conferences: [Codable]) {
        dataSource.conferences = conferences as? [ConferenceModel] ?? []
    }
    
    func fetchFailed(with error: APIError) {
        dataSource.conferences = []
    }

    func getSearchText() -> String {
        return searchController.searchBar.text ?? ""
    }
    
}
