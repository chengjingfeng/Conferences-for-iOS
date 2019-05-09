//
//  ListViewController.swift
//  Conferences
//
//  Created by Zagahr on 23/03/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit
import DifferenceKit

class ConferneceListController: UITableViewController {
    private let footerView = LoadingFooterView()
    private var data: [ConferenceViewModel] = []

    var dataInput: [ConferenceViewModel] {
        get { return data }
        set {
            footerView.showFooter()

            let changeset = StagedChangeset(source: data, target: newValue)
            print(changeset)
            print(changeset.count)
            let selectedRows = self.tableView.indexPathsForSelectedRows ?? []

            tableView.reload(using: changeset, with: .fade) { data in
                self.data = data
            }

            tableView.selectRow(at: selectedRows.first, animated: false, scrollPosition: .none)
        }
    }

    override weak var preferredFocusedView: UIView? {
        return tableView
    }

    var selectionHandler: ((TalkViewModel, IndexPath) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
        extendedLayoutIncludesOpaqueBars = true
        definesPresentationContext = true
    }

    private func configureTableView() {
        clearsSelectionOnViewWillAppear = false
        tableView.remembersLastFocusedIndexPath = true
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
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].talks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TalkViewCell", for: indexPath) as? TalkViewCell else {
            return UITableViewCell()
        }
        
        let talk = data[indexPath.section].talks[indexPath.row]
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
        let conferenceView = ConferenceHeaderView()
        let conference = data[section]
        let tap = UITapGestureRecognizer(target: self, action:#selector(self.didSelectConference))

        conferenceView.configureView(with: conference)
        conferenceView.addGestureRecognizer(tap)
        conferenceView.tag = section

        return conferenceView
    }

    @objc func didSelectConference(sender: UITapGestureRecognizer) {
        guard let conferenceView = sender.view else { return }
        guard let conference = data.indices.contains(conferenceView.tag) ? data[conferenceView.tag] : nil else { return }

        let vc = ConferenceDetailVC(model: conference)
        let navVC = UINavigationController(rootViewController: vc)

        navVC.modalPresentationStyle = .formSheet

        present(navVC, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let talk = data[indexPath.section].talks[indexPath.row]
        selectionHandler?(talk, indexPath)
    }
}
