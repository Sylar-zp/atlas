//
//  ServerManeger.swift
//  Kiddzy
//
//  Created by Andrey Trotsko on 11/2/18.
//  Copyright © 2018 InTouch mena. All rights reserved.
//

import ObjectMapper
import Alamofire
import AlamofireObjectMapper
import SwiftyJSON

class ServerManager: NSObject {

    static let shared = ServerManager()

    var accessToken = ""

    let manager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        return SessionManager(configuration: configuration)
    }()

    private override init() { }


    /**
     * TODO: Comments
     */
    public func uploadDataWithEndPoint<T:Mappable>(
        endPoint: APIEndPoints,
        urlParams:      [String]? = nil,
        headerParams:   [String: String]? = nil,
        bodyParams:     [String: Data]? = nil,
        uploadData:     [APIUploadFileType: Data]? = nil,
        uploadKey:      [String]? = nil,
        type: T,
        withCompletionClosure completionClosure: @escaping (_ resulObject: Any?, _ error: NSError? ) ->()){

        // DEBUG: Check Current thread
        // let currentThread = Thread.current;
        // let currentThreadIsMain:Bool = Thread.isMainThread;

        // Fix to guarantee execution of the completion block on the background Thread
        // Without cretning other background thred
        let executionBlock:() -> Void = {

            // DEBUG: Check Current thread
            // let currentThread = Thread.current;
            // let currentThreadIsMain:Bool = Thread.isMainThread;

            let url = kBaseAPIUrl + endPoint.urlSufix + self.urlStringWithParameter(params: urlParams)

            // TODO: Avoid Retain cicle
            print(self.accessToken)

            var header = [String: String]()

            if endPoint.accessTokenRequared == true {
                //            header["ACCESS-TOKEN"] =  self.accessToken
            }

            if headerParams != nil {
                for key in headerParams!.keys {
                    header[key] = headerParams![key]
                }
            }

            // TODO: Avoid Retain cicle
            self.manager.upload(multipartFormData: { (multipartFormData) in

                if uploadData != nil {
                    for (index, attachments) in (uploadData?.enumerated())! {

                        multipartFormData.append(attachments.value,
                                                 withName: (uploadKey?[index])!,
                                                 fileName: attachments.key.fileName,
                                                 mimeType: attachments.key.mimeName)

                    }
                }
                if bodyParams != nil {
                    for (_, body) in (bodyParams?.enumerated())!{
                        multipartFormData.append(body.value, withName: body.key)
                    }
                }

            }, to: url, method: endPoint.requestMethod, headers: header){ (result) in
                switch result {
                case .success(let upload, _, _):


                    upload.responseJSON { response in
                        print ( response.result)
                        print ( url + " : \n" + String(data: response.data!, encoding: String.Encoding.utf8)!)
                    }

                    upload.responseObject(keyPath: "") { (response: DataResponse <T>) in
                        switch response.result {
                        case .success:
                            completionClosure(response.result.value!, nil)
                        case .failure:
                            
                            completionClosure(nil, nil)
                        }
                    }

                case .failure(let encodingError):
                    print (encodingError.localizedDescription)
                }
            }
        }
        if(Thread.isMainThread){
            // Execute in the Main Thread
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            DispatchQueue.global(qos: .background).async {
                executionBlock();
            }
        }else{
            DispatchQueue.main.async{
                // Execute in the Main Thread
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            }
            executionBlock();
        }
    }


    /**
     * TODO: Comments
     */
    public func fetchDataWithEndPoint<T:Mappable>(
        type: T,
        endPoint: APIEndPoints,
        urlParams: [String]? = nil,
        urlStringParams: String = "",
        headerParams: [String: String]? = nil,
        bodyParams: [AnyObject]? = nil,
        bodyParamsInt: [NSNumber]? = nil,
        withCompletionClosure completionClosure: @escaping (_ data: Any?, _ error: NSError?) ->()) {

        // DEBUG: Check Current thread
        // let currentThread = Thread.current;
        //  let currentThreadIsMain:Bool = Thread.isMainThread;

        // Fix to guarantee execution of the completion block on the background Thread
        // Without cretning other background thred
        let executionBlock:() -> Void = {

            // DEBUG: Check Current thread
            // let currentThread = Thread.current;
            // let currentThreadIsMain:Bool = Thread.isMainThread;

            let url = kBaseAPIUrl + endPoint.urlSufix + self.urlStringWithParameter(params: urlParams) + urlStringParams

            // Set Headers
            var header = [String: String]()
            if headerParams != nil {
                for key in headerParams!.keys {
                    header[key] = headerParams![key]
                }
            }
            else{
                if let params = endPoint.headerParams{
                    for (key, value) in params{
                        header[key] = value
                    }
                }
            }


            // Set Body
            var body: [String: AnyObject]? = nil
            if bodyParams != nil {
                body = bodyParams!.count > 0 ? Dictionary.init(keys: endPoint.bodyParams, values: (bodyParams!)) : [String: AnyObject]()
            }

            if endPoint.objectType {
                self.getObject(success: { (object: T) in
                    // Remove Network Activity
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    completionClosure(object, nil)
                }, methods: endPoint.requestMethod, url: url, parameters: body as [String : AnyObject]?, headers: header, keyPath: endPoint.keyPath) { (error: NSError) in
                    // Remove Network Activity
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    completionClosure(nil, error)
                }

            } else {
                self.getArray(success: { (objects: [T]) in
                    // Remove Network Activity
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    completionClosure(objects, nil)
                }, methods: endPoint.requestMethod, url: url, parameters: body as [String : AnyObject]?, headers: header, keyPath: endPoint.keyPath) { (error: NSError) in
                    // Remove Network Activity
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    completionClosure(nil, error)
                }

            }
        }

        if(Thread.isMainThread){
            // Execute in the Main Thread
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            DispatchQueue.global(qos: .background).async {
                executionBlock();
            }
        }else{
            DispatchQueue.main.async{
                // Execute in the Main Thread
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            }
            executionBlock();
        }
    }

    /**
     * TODO: Comments
     */
    private func urlStringWithParameter(params: [String]?) -> String {
        if params == nil { return "" }
        var url: String = ""
        for param in params! { url += "" + param }
        return url + ""
    }

    /**
     * TODO: Comments
     */
    private func getObject <T:Mappable> (success:@escaping (T) -> Void, methods: Alamofire.HTTPMethod, url: String?, parameters: [String: AnyObject]?, headers: [String: String]?, keyPath: String, fail:@escaping (_ error:NSError)->Void)->Void {

        // DEBUG: Check Current thread
        // let currentThread = Thread.current;
        // let currentThreadIsMain:Bool = Thread.isMainThread;

        // Fix to guarantee execution of the completion block on the background Thread
        // Without cretning other background thred
        // TODO: Remove is we guaraty to call it in background thread
        let executionBlock:() -> Void = {

            // DEBUG: Check Current thread
            // let currentThread = Thread.current;
            // let currentThreadIsMain:Bool = Thread.isMainThread;

            self.manager.request(url!, method: methods, parameters: parameters, encoding:  JSONEncoding.default, headers: headers).responseObject(keyPath: keyPath) { (response: DataResponse <T>) in

                print("Request: \(String(describing: response.request!))")   // original url request
                print("Result: \(response.result)")                         // response serialization result

                if let js = String(data: response.data!, encoding: String.Encoding.utf8) {
                    let dic = JSON.init(parseJSON: js)
                        //JSON.parse(js)
                    
                    if dic.isEmpty {
                        
                    }

                    if dic["code"].int == 401  || dic["code"].int == 429 || dic["code"].int == 503 {
                        let serverError = self.formError(from: dic)
                        fail(serverError)
                        return

                    } else if dic["code"].int == 404{
                        fail(self.formError(from: dic))

                        return
                    }
                }

                if let token = response.response?.allHeaderFields["ACCESS-TOKEN"] as? String{
                    self.accessToken = token
                }
                switch response.result {
                case .success:
                    success(response.result.value!)
                case .failure:
                    fail(response.result.error! as NSError)
                }
            }
        }
        if (Thread.isMainThread) {
            DispatchQueue.global(qos: .background).async {
                executionBlock();
            }
        } else {
            executionBlock();
        }
    }

    /**
     * TODO: Comments
     */
    private func getArray <T:Mappable> (success:@escaping ([T]) -> Void, methods: Alamofire.HTTPMethod, url: String?, parameters: [String: AnyObject]?, headers: [String: String]?, keyPath: String, fail:@escaping (_ error:NSError)->Void)->Void {

        // DEBUG: Check Current thread
        // let currentThread = Thread.current;
        // let currentThreadIsMain:Bool = Thread.isMainThread;

        // Fix to guarantee execution of the completion block on the background Thread
        // Without cretning other background thred
        // TODO: Remove is we guaraty to call it in background thread
        let executionBlock:() -> Void = {

            // DEBUG: Check Current thread
            // let currentThread = Thread.current;
            // let currentThreadIsMain:Bool = Thread.isMainThread;

            self.manager.request(url!, method: methods, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseArray(keyPath: keyPath) { (response: DataResponse <[T]>) in

                print("Request: \(response.request!)")   // original url request
                print("Result: \(response.result)")      // response serialization result

                if let js = String(data: response.data!, encoding: String.Encoding.utf8) {
                    let dic = JSON.init(parseJSON: js)
                    //JSON.parse(js)
                    if dic["code"].int == 401 || dic["code"].int == 422 || dic["code"].int == 429 || dic["code"].int == 503 {
                        let serverError = self.formError(from: dic)
                        fail(serverError)
                        return
                    }
                }

                switch response.result {
                case .success(let value):
                    success(value)
                case .failure(let error):
                    fail(error as NSError)
                }
            }
        }

        if(Thread.isMainThread){
            DispatchQueue.global(qos: .background).async {
                executionBlock();
            }
        }else{
            executionBlock();
        }
    }
}

extension ServerManager {
    /**
     * TODO: Comments
     */
    func formError(from dictionary: SwiftyJSON.JSON) -> NSError {
        let currentError = NSError(domain: "somedomain",
                                   code: dictionary["code"].int!,
                                   userInfo: ["message": dictionary["message"].stringValue])
        return currentError
    }
}


extension CodingKey {
    var value: String {
        return self.stringValue
    }
}

extension Dictionary{
    public init(keys: [Key], values: [Value]) {
        precondition(keys.count == values.count)

        self.init()

        for (index, key) in keys.enumerated(){
            self[key] = values[index]
        }
    }
}
