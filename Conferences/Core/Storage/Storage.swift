//
//  Storage.swift
//  Conferences
//
//  Created by Timon Blask on 03/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import RealmSwift

final class Storage {
    static let shared = Storage()

    private lazy var realm: Realm? = {
        return try? Realm()
    }()

    func getProgress(for id: Int) ->  ProgressModel? {
        return realm?.object(ofType: ProgressModel.self, forPrimaryKey: id)
    }

    func isOnWatchlist(for id: Int) -> WatchlistModel? {
        return realm?.object(ofType: WatchlistModel.self, forPrimaryKey: id)
    }

    func getModelsForContinue() -> [Int] {
        return realm?.objects(ProgressModel.self).filter { $0.watched == false && $0.relativePosition > 0 }.map { $0.id } ?? []
    }

    func getWatchlist() -> [Int] {
        return realm?.objects(WatchlistModel.self).filter { $0.active == true }.map { $0.id } ?? []
    }

    func togggleWatchlist(_ viewModel: TalkViewModel) -> Bool  {
        let model = WatchlistModel()
        model.id = viewModel.id
        model.active = viewModel.onWatchlist

        try! realm?.write {
            if model.active {
                if let objectToRemove = realm?.object(ofType: WatchlistModel.self, forPrimaryKey: model.id) {
                    LoggingHelper.register(event: .removeFromWatchlist, info: ["videoId": String(model.id)])
                    realm?.delete(objectToRemove)
                }
            } else {
                LoggingHelper.register(event: .addToWatchlist, info: ["videoId": String(model.id)])
                realm?.add(model, update: true)
            }
        }

        return !viewModel.onWatchlist
    }

    func toggleWatched(_ viewModel: TalkViewModel) -> Bool {
        if let model = getProgress(for: viewModel.id) {
            try! realm?.write {
                model.currentPosition = viewModel.watched ? 0.0 : 1.0
                model.relativePosition = viewModel.watched ? 0.0 : 1.0
                model.watched = !viewModel.watched
            }

            trackProgress(object: model)
        } else {
            let model = ProgressModel()
            model.currentPosition = viewModel.watched ? 0.0 : 1.0
            model.relativePosition = viewModel.watched ? 0.0 : 1.0
            model.watched = !viewModel.watched

            trackProgress(object: model)
        }

        return !viewModel.watched
    }

    func trackProgress(object: ProgressModel)   {
        try! realm?.write {
            realm?.add(object, update: true)
        }
    }

    func currentlyWatching(object: CurrentlyWatchingModel)   {
        try! realm?.write {
            if let objectToRemove = realm?.object(ofType: CurrentlyWatchingModel.self, forPrimaryKey: object.id) {
                realm?.delete(objectToRemove)
            } else {
                realm?.add(object, update: true)
            }
        }
    }

    func currentlyWatching(for id: Int) -> Bool {
        if let _ = realm?.object(ofType: CurrentlyWatchingModel.self, forPrimaryKey: id) {
            return true
        } else {
            return false
        }
    }

    func clearCurrentlyWatching() {
        guard let currentlyWatching = realm?.objects(CurrentlyWatchingModel.self) else { return }

        try! realm?.write {
            realm?.delete(currentlyWatching)
        }
    }
}
