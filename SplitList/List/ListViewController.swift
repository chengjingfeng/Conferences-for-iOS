//
//  ListViewController.swift
//  Conferences
//
//  Created by Zagahr on 23/03/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit

class ConferneceListController: UITableViewController {
    private let footerView = LoadingFooterView()

    var items: [ConferenceModel] = [] {
        didSet {
            UIView.transition(with: tableView, duration: 0.35, options: .transitionCrossDissolve, animations: {
                self.tableView.reloadData()
            }) { (_) in
                self.footerView.isHidden = !self.items.isEmpty
            }
        }
    }

    var selectionHandler: ((TalkModel, IndexPath) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
        self.extendedLayoutIncludesOpaqueBars = true
       // definesPresentationContext = true
    }

    private func configureTableView() {
        footerView.frame.size = CGSize(width: footerView.frame.width, height: 200)
        footerView.startAnimating()

        tableView.tableFooterView = footerView
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.panelBackground
        tableView.sectionHeaderHeight = 100
        tableView.rowHeight = 70
        tableView.register(TalkViewCell.self, forCellReuseIdentifier: "TalkViewCell")
    }
    
    // MARK: - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].talks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TalkViewCell", for: indexPath) as? TalkViewCell else {
            return UITableViewCell()
        }
        
        let talk = items[indexPath.section].talks[indexPath.row]
        cell.configureView(with: talk)
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.elementBackground
        cell.selectedBackgroundView = bgColorView
        cell.backgroundColor = UIColor.elementBackground
        
        return cell
    }

    func showEmtpyWatchlist() {
        footerView.showEmptyWatchlist()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let conferenceView = ConferenceHeaderView(safeAreaInsets: tableView.safeAreaInsets)
        let conference = items[section]
        
        conferenceView.configureView(with: conference)
        
        return conferenceView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let talk = items[indexPath.section].talks[indexPath.row]
        selectionHandler?(talk, indexPath)
    }
}
