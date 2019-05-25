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

    func getWatchlist() -> [Int] {
        return realm?.objects(WatchlistModel.self).map { $0.id } ?? []
    }

    func toggleWatchlist(_ viewModel: TalkModel, completion: @escaping (Bool) -> Void) {
        let model = WatchlistModel()
        model.id = viewModel.id

        try? realm?.write {
            if let objectToRemove = realm?.object(ofType: WatchlistModel.self, forPrimaryKey: model.id) {
                LoggingHelper.register(event: .removeFromWatchlist, info: ["videoId": String(model.id)])

                realm?.delete(objectToRemove)

                completion(false)
            } else {
                LoggingHelper.register(event: .addToWatchlist, info: ["videoId": String(model.id)])

                realm?.add(model, update: true)
                completion(true)
            }
        }
    }

    func toggleWatched(_ viewModel: TalkModel) -> Bool {
        if let model = getProgress(for: viewModel.id) {
            try? realm?.write {
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
        try? realm?.write {
            realm?.add(object, update: true)
        }
    }
}
