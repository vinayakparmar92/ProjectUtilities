
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
    let parse: (Data?) -> Any?
}

 enum Reason {
    case parsingFailed
    case badRequest
    case noSuccessStatusCode
    case other(Error?)
}

// MARK: Method to call API
@discardableResult  func apiRequest(_ modifyRequest: ((inout URLRequest) -> ())?,
                                          baseURLString: String,
                                          resource: APIResource,
                                          failure: ((Reason, Any?) -> ())?,
                                          success: ((Any) -> ())?) -> URLSessionTask? {
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
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        
                        if let result = resource.parse(data) {
                            success?(result)
                            
                        } else {
                            failure?(Reason.parsingFailed, data)
                        }
                    } else {
                        // TODO: Add crashlytics crash here
                        failure?(Reason.noSuccessStatusCode, resource.parse(data))
                    }
                } else {                    
                    failure?(Reason.other(error), data)
                }
            }
            
            task.resume()
            return task
        }
    }
    
    failure?(Reason.badRequest, nil)
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


