//
//  APIClient.swift
//  Conferences
//
//  Created by Timon Blask on 02/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation
import ConferencesCore

final class APIClient {
    static let shared = APIClient()

    private(set) var models: [ConferenceModel] = []

    func fetchConferences(completion: @escaping(_ error: APIError? ) -> Void) {
        send(resource: ConferenceResource.all, completionHandler: { [weak self] (response: Result<[ConferenceModel], APIError>) in

            var error: APIError?

            switch response {
            case .success(let conferences):
                self?.models = conferences
            case .failure(let apiError):
                error = apiError
            }

            completion(error)
        })
    }


   private func send<T: Codable>(resource: Resource, completionHandler: @escaping (Result<[T], APIError>) -> Void) {
        let request = resource.urlRequest()

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completionHandler(.failure(.http(error)))
                return
            }

            guard let data = data else {
                completionHandler(.failure(.unknown))
                return
            }

            if let models = try? JSONDecoder().decode([T].self, from: data) {
                completionHandler(.success(models))
            } else {
                completionHandler(.failure(.adapter))
            }

        }.resume()
    }
}
