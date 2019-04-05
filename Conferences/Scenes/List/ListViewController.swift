//
//  ListViewController.swift
//  Conferences
//
//  Created by Zagahr on 23/03/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {
    
    weak var splitDelegate: SplitViewDelegate?
    var detailViewController: DetailViewController? = nil
    var apiClient = APIClient()
    let searchController = UISearchController(searchResultsController: nil)
    
    var conferences: [ConferenceModel] = [] {
        didSet {
            DispatchQueue.main.async {
                if let talk = self.conferences.first?.talks.first,
                    let window = UIApplication.shared.keyWindow,
                    window.traitCollection.horizontalSizeClass == .regular {
                    self.splitDelegate?.didSelectTalk(talk: talk)
                }
                
                self.tableView.reloadData()
            }
        }
    }
    
    var filteredConferences: [ConferenceModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        configureSearchBar()
        fetchData()
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
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        
        navigationItem.searchController = searchController
        self.definesPresentationContext = true
    }
    
    private func fetchData() {
        apiClient.send(resource: ConferenceResource.all, completionHandler: { [weak self] (response: Result<[ConferenceModel], APIError>) in
            switch response {
            case .success(let models):
                self?.conferences = models
            case .failure(let error):
                print("error")
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let talk = isFiltering() ? filteredConferences[indexPath.section].talks[indexPath.row]: conferences[indexPath.section].talks[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.configureView(with: talk)
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return isFiltering() ? filteredConferences.count : conferences.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltering() ? filteredConferences[section].talks.count : conferences[section].talks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TalkViewCell", for: indexPath) as? TalkViewCell else {
            return UITableViewCell()
        }
        
        let talk = isFiltering() ? filteredConferences[indexPath.section].talks[indexPath.row] : conferences[indexPath.section].talks[indexPath.row]
        cell.configureView(with: talk)
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.elementBackground
        cell.selectedBackgroundView = bgColorView
        cell.backgroundColor = UIColor.elementBackground
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let conferenceView = ConferenceHeaderView(safeAreaInsets: tableView.safeAreaInsets)
        let conference = conferences[section]
        
        conferenceView.configureView(with: conference)
        
        return conferenceView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let talk = conferences[indexPath.section].talks[indexPath.row]
        splitDelegate?.didSelectTalk(talk: talk)
    }
}

extension ListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text ?? "")
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filteredConferences = conferences
        tableView.reloadData()
    }
}

// MARK: - Search methods
extension ListViewController {
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        
        guard (searchText.count > 0) else { return }
        
        filteredConferences = conferences.map { conference in
            var newConference   = conference
            let filteredTalks   = conference.talks.filter { talk in
                return talk.searchString.contains(searchText.lowercased()) &&
                    (scope == "All" || talk.tags.filter { tag in tag.lowercased().contains(scope.lowercased()) }.count > 0)
            }
            newConference.talks = filteredTalks
            
            return newConference
            }
            .filter { $0.talks.count > 0 }
        
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
}

// MARK: - UISearchBar Delegate
extension ListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text ?? "", scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

