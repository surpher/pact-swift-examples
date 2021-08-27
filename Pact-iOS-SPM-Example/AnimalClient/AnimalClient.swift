import Foundation

class AnimalClient: NSObject {

    enum Endpoint: String {
        case animals
        case species
    }

    let baseURL: String

    private lazy var session = {
        return URLSession(configuration: .ephemeral, delegate: self, delegateQueue: .main)
    }()

    init(baseURL: String) {
        self.baseURL = baseURL
    }

    // MARK: - Animal Client

    func request<D>(method: HTTPMethod, endpoint: Endpoint, path: String? = nil, query: String? = nil, body: Data? = nil, completion: @escaping (D?, Error?) -> Void) where D: Decodable {
        session
            .decodable(
                for: .makeRequest(url: endpoint.url(baseURL: baseURL, path: path, query: query), method: method, body: body)
            ) { (result: Result<D, Error>) in
                switch result {
                case .success(let object): completion(object, nil)
                case .failure(let error): completion(nil, error)
                }
            }
    }

}

private extension AnimalClient.Endpoint {

    func url(baseURL: String, path: String? = nil, query: String? = nil) -> URL {
        if let path = path {
            return URL(string: "\(baseURL)/api/\(self.rawValue)/\(path)\(query ?? "")")!
        } else {
            return URL(string: "\(baseURL)/api/\(self.rawValue)\(query ?? "")")!
        }
    }

}
