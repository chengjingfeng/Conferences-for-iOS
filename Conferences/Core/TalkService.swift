//
//  TalkService.swift
//  Conferences
//
//  Created by Timon Blask on 13/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation

protocol TalkServiceDelegate: class {
    func didFetch(_ conferences: [Codable])
    func fetchFailed(with error: APIError)
    func getSearchText() -> String
}

final class TalkService {
    weak var delegate: TalkServiceDelegate?
    private let apiClient = APIClient()

    private var conferences = [Codable]()
    private var backup = [Codable]()

    init() {
        observe()
    }

    func observe() {
        NotificationCenter.default.addObserver(self, selector: #selector(filterTalks as () -> Void), name: .refreshTableView, object: nil)
    }

    func fetchData() {
        apiClient.send(resource: ConferenceResource.all, completionHandler: { [weak self] (response: Result<[ConferenceModel], APIError>) in
            switch response {
            case .success(let conferences):
                self?.conferences = conferences
                self?.backup      = conferences
                
                DispatchQueue.main.async {
                    self?.delegate?.didFetch(conferences)
                }

            case .failure(let error):
                DispatchQueue.main.async {
                    self?.delegate?.fetchFailed(with: error)
                }
            }
        })
    }

    func filterTalks(by searchString: String) {
        guard let seachableBackup = self.backup as? [Searchable] else { return }
        let activeTags = TagSyncService.shared.activeTags()
        
        var currentBatch = seachableBackup
        
        for i in 0..<currentBatch.count {
            var conf = currentBatch[i] as? ConferenceModel
            if (conf != nil) {
                if (searchString.count > 0) {
                    conf!.talks = conf!.talks.filter { $0.searchString.contains(searchString.lowercased()) && $0.matchesAll(activeTags: activeTags) }
                }
                else {
                    conf!.talks = conf!.talks.filter { $0.matchesAll(activeTags: activeTags) }
                }
                currentBatch[i] = conf!
            }
        }
        
        currentBatch = currentBatch.filter { ($0 as? ConferenceModel)?.talks.count ?? 0 > 0 }
        
        self.conferences = currentBatch as! [Codable]
        
        DispatchQueue.main.async {
            self.delegate?.didFetch(self.conferences)
        }
    }

    @objc private func filterTalks() {
        filterTalks(by: delegate?.getSearchText() ?? "")
    }
}
