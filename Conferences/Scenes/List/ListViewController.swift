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
    var filteredConferences: [ConferenceModel] = []
    
    var conferences: [ConferenceModel] = [] {
        didSet {
            filteredConferences = conferences
            
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
        
        tagListView.delegate = self
        searchController.searchBar.inputAccessoryView = tagListView
                
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
                let talk = filteredConferences[indexPath.section].talks[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.configureView(with: talk)
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return filteredConferences.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredConferences[section].talks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TalkViewCell", for: indexPath) as? TalkViewCell else {
            return UITableViewCell()
        }
        
        let talk = filteredConferences[indexPath.section].talks[indexPath.row]
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
        filterContent()
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
    
    func filterContent() {
        
        let searchText = searchController.searchBar.text ?? ""
        
        filteredConferences = conferences.map { conference in
            var newConference   = conference
            let filteredTalks   = conference.talks.filter { talk in
                return (searchText.count == 0 || talk.searchString.contains(searchText.lowercased())) &&
                       talk.matchesAll(activeTags: tagListView.activeTags())
            }
            newConference.talks = filteredTalks
            
            return newConference
            }
            .filter { $0.talks.count > 0 }
        
        let result = getFilterResult()
        tagListView.didFilter(conferences: result.conferences, talks: result.talks)
        
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && (!searchBarIsEmpty() || tagListView.activeTags().count > 0)
    }
}

// MARK: - UISearchBar Delegate
extension ListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContent()
    }
}

// MARK: - UISearchBar Delegate
extension ListViewController: TagListViewDelegate {
    func didTagSelected() {
        filterContent()
    }
    
    func didTagFilter() {
        didTagSelected()
        searchController.isActive = false
    }

    func getFilterResult() -> (conferences: Int, talks: Int) {
        return (conferences: filteredConferences.count, talks: filteredConferences.map { $0.talks.count }.reduce(0,+))
    }
}

