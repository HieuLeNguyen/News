//
//  APICaller.swift
//  News
//
//  Created by Nguyễn Văn Hiếu on 12/12/24.
//

import Foundation

final class APICaller {
    static let shared = APICaller()
    
    private init() {}
    
    // MARK: - Build URL (Endpoint, Query Param)
    private func buildURL(endpoint: String, queryParams: [String: String]?) -> URL? {
        var components = URLComponents(string: Constants.baseURL + endpoint)
        
        if let queryParams = queryParams {
            let queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
            components?.queryItems = queryItems
        }
        
        return components?.url
    }
    
    // MARK: - Get Top Stories
    public func getTopStories(completion: @escaping (Result<[Article], Error>) -> Void) {
        guard let url = buildURL(endpoint: "top-headlines", queryParams: ["country": "us"]) else {
            return
        }
        
        // Add Authorization: Bearer
        var request = URLRequest(url: url)
        request.addValue("Bearer \(Config.apiKey)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
            }
            else if let data = data {
                
                do {
                    let result = try JSONDecoder().decode(APIResponse.self, from: data)
                    print("Articles: ", result.articles.count)
                    completion(.success(result.articles))
                }
                catch {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - Search for Articles
    public func searchArticles(with query: String, completion: @escaping (Result<[Article], Error>) -> Void) {
        // Kiểm tra và xử lý khoảng trống trong từ khóa tìm kiếm
        let query = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        guard let url = buildURL(endpoint: "everything", queryParams: ["q": query]) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        // Add Authorization: Bearer
        var request = URLRequest(url: url)
        request.addValue("Bearer \(Config.apiKey)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                do {
                    let result = try JSONDecoder().decode(APIResponse.self, from: data)
                    print("Found Articles: ", result.articles.count)
                    completion(.success(result.articles))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    
}

// MARK: - Configure access key and baseURL
extension APICaller {
    
    private struct Config {
        static let apiKey: String = {
            guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
                  let dictionary = NSDictionary(contentsOfFile: path) as? [String: Any],
                  let apiKey = dictionary["API_KEY"] as? String
            else {
                fatalError("API_KEY not found in Config.plist")
            }
            return apiKey
        }()
    }
    
    private struct Constants {
        static let baseURL = "https://newsapi.org/v2/"
    }
}

