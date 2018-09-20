
import Foundation

// MARK: Structs for grouping related stuff
 enum RESTMethod: String {
    case GET = "GET"
    case POST = "POST"
    case DELETE = "DELETE"
}

 struct APIResource {
    let path: String
    let method : RESTMethod
    let headers : [String : String]
    let requestParameters: [String : Any?]?
    let requestBody: Data?
}

 enum Reason {
    case parsingFailed
    case badRequest
    case noSuccessStatusCode
    case other(Error?)
}

enum ServiceError {
    case internalError
    case dataParsingError
    case unknownError
}

enum ServiceResponse<T> {
    case success(T)
    case failure(ServiceError)
}

// MARK: Method to call API
@discardableResult  func apiRequest<T: Codable>(_ modifyRequest: ((inout URLRequest) -> ())?,
                                          baseURLString: String,
                                          resource: APIResource,
                                          responseHandler: @escaping ((ServiceResponse<T>) -> ())) -> URLSessionTask? {
    var component = URLComponents.init(string: baseURLString)
    
    if let _ = component {
        // Append sub domain path
        component!.path = resource.path
        
        // Append get parameters
        if let params = resource.requestParameters {
            var items = [URLQueryItem]()
            for (key, value) in params {
                if let _value = value {
                    items.append(URLQueryItem(name: key, value: "\(_value)"))
                }
            }
            component!.queryItems = items
        }
        
        if let url = component!.url {
            // Create URLRequest
            var request = URLRequest.init(url: url)
            request.httpMethod = resource.method.rawValue
            request.httpBody = resource.requestBody
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Closure to modify the request in case some changes
            modifyRequest?(&request)
            
            for (key, value) in resource.headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
            
            #if !ENV_PRODUCTION
            print("\n##*****************************************************")
            if let strURL = request.url?.absoluteString {
                print("URL STRING :\n \(strURL)")
            }
            if let getParams = request.url?.queryParams,
                !getParams.isEmpty {
                print("GET PARAMS :\n \(getParams)")
            }
            if let body = request.httpBody?.getString() {
                print("POST BODY :\n \(body)")
            }
            print("******************************************************##\n")
            #endif
            
            let session = URLSession.shared
            let task = session.dataTask(with: request) { (data, response, error) -> Void in
                
                do {
                    let temp =  try JSONSerialization.jsonObject(with: data!,
                                                                 options: JSONSerialization.ReadingOptions.allowFragments)
                } catch {
                    print(error)
                }
                
                if let httpResponse = response as? HTTPURLResponse,
                    httpResponse.statusCode == 200,
                    let responseData = data {
                    do {
                        let parsedResponse = try JSONDecoder().decode(T.self,
                                                                      from: responseData)
                        responseHandler(ServiceResponse.success(parsedResponse))
                    } catch {
                        responseHandler(ServiceResponse.failure(ServiceError.dataParsingError))
                    }
                } else {
                    responseHandler(ServiceResponse.failure(ServiceError.unknownError))
                }
            }
            
            task.resume()
            return task
        }
    }
    
    responseHandler(ServiceResponse.failure(ServiceError.unknownError))
    return nil
}

func decodeJSON(_ data: Data) -> JSONDictionary? {
    return (try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())) as? JSONDictionary
}

func encodeJSON(_ dict: [String: Any?]) -> Data? {
    var dictWithoutOptionals = [String: Any]()
    dict.forEach { (paramKey, paramValue) in
        if let paramValue = paramValue {
            dictWithoutOptionals.updateValue(paramValue, forKey: paramKey)
        }
    }
    
    return dictWithoutOptionals.count > 0 ? try? JSONSerialization.data(withJSONObject: dictWithoutOptionals, options: .prettyPrinted) : nil
}

extension Dictionary {    
    func getQueryString() -> String {
        var outputString = "?"
        
        self.forEach{ (key, value) in
            outputString += "\(key)=\(value)"
        }
        
        return outputString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }
}
