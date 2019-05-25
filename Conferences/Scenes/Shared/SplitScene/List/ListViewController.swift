//
//  ListViewController.swift
//  Conferences
//
//  Created by Zagahr on 23/03/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {
    private let footerView = LoadingFooterView()
    private let headerView = TableViewHeader()

    var headerModel: ListRepresentable? {
        didSet {
            guard headerModel != nil else { return }

            headerView.configureView(with: headerModel)
            tableView.tableHeaderView = headerView

        }
    }

    var data: [ListRepresentable] = [] {
        didSet {
            if let _ = headerModel as? ConferenceModel {
                tableView.sectionHeaderHeight = 0
            }
            
            tableView.reloadData()
        }
    }

    var selectionHandler: ((TalkModel, IndexPath) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTheming()
        configureTableView()
        
        definesPresentationContext = true
        extendedLayoutIncludesOpaqueBars = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if headerModel != nil && UIDevice.current.userInterfaceIdiom == .pad {
            navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    private func configureTableView() {
        clearsSelectionOnViewWillAppear = false
        tableView.remembersLastFocusedIndexPath = true
        footerView.frame.size = CGSize(width: footerView.frame.width, height: 200)
        tableView.tableFooterView = footerView
        tableView.separatorStyle = .none
        tableView.sectionHeaderHeight = 100
        tableView.rowHeight = 70
        tableView.register(TalkViewCell.self, forCellReuseIdentifier: "TalkViewCell")
        footerView.showFooter()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].children?.count ?? data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TalkViewCell", for: indexPath) as? TalkViewCell else {
            return UITableViewCell()
        }

        let talk = data[indexPath.section].children?[indexPath.row]
        cell.configureView(with: talk!)

        return cell
    }

    func showEmtpyWatchlist() {
        footerView.showEmptyWatchlist()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard headerModel as? ConferenceModel == nil else { return nil }

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
        guard let conference = data.indices.contains(conferenceView.tag) ? data[conferenceView.tag] as? ConferenceModel : nil else { return }

        let vc = ConferenceDetailVC(model: conference)
        let navVC = UINavigationController(rootViewController: vc)

        navVC.modalPresentationStyle = .formSheet

        present(navVC, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let talk = data[indexPath.section].children?[indexPath.row] as? TalkModel {
            selectionHandler?(talk, indexPath)
        }
    }
}

extension ListViewController: Themed {
    func applyTheme(_ theme: AppTheme) {
        tableView.backgroundColor = theme.backgroundColor
        navigationController?.navigationBar.barTintColor = theme.backgroundColor
        navigationController?.navigationBar.tintColor = theme.textColor
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: theme.textColor]
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: theme.textColor]
    }
}
