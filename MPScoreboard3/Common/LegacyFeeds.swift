//
//  LegacyFeeds.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/10/21.
//

import UIKit

class LegacyFeeds: NSObject
{
    // MARK: - Web Login Feed
    
    class func webLogin(completionHandler: @escaping (_ post: String?, _ error: Error?) -> Void)
    {
        
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = kLoginUserWithIdHostDev
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = kLoginUserWithIdHostDev
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = kLoginUserWithIdHostProduction // The staging URL doesn't work
        }
        else
        {
            urlString = kLoginUserWithIdHostProduction
        }
        
        // Get the time from 1/1/2001 in integer form
        let sessionId = Date.timeIntervalSinceReferenceDate
        let intSessionId = Int(sessionId)
        
        let urlWithSessionId = urlString + "?sessionId=" + String(sessionId)

        var urlRequest = URLRequest(url: URL(string: urlWithSessionId)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let jsonDict = [kRequestKey : [kUserIdKey : userId as Any, kSessionIdKey : NSNumber(value: intSessionId)]]
        
        var postBodyData: Data? = nil
        do {
            postBodyData = try JSONSerialization.data(withJSONObject: jsonDict, options: [])
        }
        catch
        {
            let errorDictionary = [NSLocalizedDescriptionKey : "JSON error"]
            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
            completionHandler(nil, error)
            return
        }

        urlRequest.httpBody = postBodyData
        
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) { (data, response, connectionError) in
            
            print("Response: " + response!.description)
            
            DispatchQueue.main.async
            {
                if (connectionError == nil)
                {
                    if let httpResponse = response as? HTTPURLResponse
                    {
                        if (httpResponse.statusCode == 200)
                        {
                            if (data != nil)
                            {
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                                
                                completionHandler(logDataReceived, nil)
                                
                            }
                            else
                            {
                                print("Data was nil")
                                let errorDictionary = [NSLocalizedDescriptionKey : "Data was nil"]
                                let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                completionHandler(nil, error)
                            }
                        }
                        else
                        {
                            print("Status != 200")
                            let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                            completionHandler(nil, error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(nil, error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(nil, error)
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - Get User Info (old app login)
    
    class func getUserInfo(email: String, password: String, userId: String, completionHandler: @escaping (_ userInfo: Dictionary<String, Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = kSecureUserIdHostDev
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = kSecureUserIdHostDev
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = kSecureUserIdHostStaging
        }
        else
        {
            urlString = kSecureUserIdHostProduction
        }
        
        // Get the time from 1/1/2001 in integer form
        let sessionId = Date.timeIntervalSinceReferenceDate
        let intSessionId = Int(sessionId)
        
        let urlWithSessionId = urlString + "?sessionId=" + String(sessionId)
        
        var urlRequest = URLRequest(url: URL(string: urlWithSessionId)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let jsonDict = [kRequestKey : ["Email" : email, "Password" : password, "UserId" : userId, kSessionIdKey : NSNumber(value: intSessionId)]]
        
        var postBodyData: Data? = nil
        do {
            postBodyData = try JSONSerialization.data(withJSONObject: jsonDict, options: [])
        }
        catch
        {
            let errorDictionary = [NSLocalizedDescriptionKey : "JSON error"]
            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
            completionHandler(nil, error)
            return
        }

        //NSString *logOut = [[NSString alloc]initWithData:postBodyData encoding:NSUTF8StringEncoding];
        //NSLog(@"Body data: %@", logOut);

        urlRequest.httpBody = postBodyData
        
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) { (data, response, connectionError) in
            
            print("Response: " + response!.description)
            
            DispatchQueue.main.async
            {
                if (connectionError == nil)
                {
                    if let httpResponse = response as? HTTPURLResponse
                    {
                        if (httpResponse.statusCode == 200)
                        {
                            if (data != nil)
                            {
                                //let logDataReceived = String(decoding: data!, as: UTF8.self)
                                //print(logDataReceived)
                                
                                // Decompose the JSON data
                                var dictionary : Dictionary<String, Any> = [:]
                                  
                                do {
                                    dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                    
                                    // Check for Failure
                                    if let feedStatus = dictionary["Successful"] as? Bool
                                    {
                                        if (feedStatus == false)
                                        {
                                            print("Get User Info Failed")
                                            let errorDictionary = [NSLocalizedDescriptionKey : "Get User Info Failed"]
                                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                            completionHandler(nil, error)
                                        }
                                        else
                                        {
                                            let userInfo = dictionary["Data"] as! Dictionary<String, Any>
                                            completionHandler(userInfo, nil)
                                        }
                                    }
                                }
                                catch let error as NSError
                                {
                                    print(error)
                                    print("Json Error: " + error.localizedDescription)
                                    let errorDictionary = [NSLocalizedDescriptionKey : "Json Decode Error: " + error.localizedDescription]
                                    let compositeError = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                    completionHandler(nil, compositeError)
                                }
                                
                                /*
                                 // Returned Data
                                 
                                 
                                 */
                            }
                            else
                            {
                                print("Data was nil")
                                let errorDictionary = [NSLocalizedDescriptionKey : "Data was nil"]
                                let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                completionHandler(nil, error)
                            }
                        }
                        else
                        {
                            print("Status != 200")
                            let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                            completionHandler(nil, error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(nil, error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(nil, error)
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - Get UTC Time
    
    class func getUTCTime( completionHandler: @escaping (_ timeOffset: TimeInterval?, _ error: Error?) -> Void)
    {
        var urlRequest = URLRequest(url: URL(string: kUtcTimeHostProduction)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) { (data, response, connectionError) in
            
            print("Response: " + response!.description)
            
            DispatchQueue.main.async
            {
                if (connectionError == nil)
                {
                    if let httpResponse = response as? HTTPURLResponse
                    {
                        if (httpResponse.statusCode == 200)
                        {
                            if (data != nil)
                            {
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                                
                                // Decompose the JSON data
                                var dictionary : Dictionary<String, Any> = [:]
                                  
                                do {
                                    dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                    
                                    let timeString = dictionary["utctime"] as? String
                                    let serverTimeFormat = DateFormatter()
                                    serverTimeFormat.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
                                    serverTimeFormat.dateFormat = "MM.dd.yyyy.HH.mm"
                                    
                                    let serverTime = serverTimeFormat.date(from: timeString ?? "")
                                    
                                    // Get the delta time
                                    let deltaTime = serverTime?.timeIntervalSinceNow ?? 0.0
                                    
                                    completionHandler(deltaTime, nil)
                                    
                                }
                                catch let error as NSError
                                {
                                    print(error)
                                    print("Json Error: " + error.localizedDescription)
                                    let errorDictionary = [NSLocalizedDescriptionKey : "Json Decode Error: " + error.localizedDescription]
                                    let compositeError = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                    completionHandler(nil, compositeError)
                                }
                            }
                            else
                            {
                                print("Data was nil")
                                let errorDictionary = [NSLocalizedDescriptionKey : "Data was nil"]
                                let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                completionHandler(nil, error)
                            }
                        }
                        else
                        {
                            print("Status != 200")
                            let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                            completionHandler(nil, error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(nil, error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(nil, error)
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - User Image Feeds
    
    class func getUserImage(userId: String, completionHandler: @escaping (_ post: Data?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = kGetUserImageUrlDev
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = kGetUserImageUrlDev
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = kGetUserImageUrlStaging
        }
        else
        {
            urlString = kGetUserImageUrlProduction
        }
                
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("octet/stream", forHTTPHeaderField: "Content-Type")
        
        // Calculate the DT and HH values using the FeedsHelper
        let dt = FeedsHelper.getDateCode(SharedData.utcTimeOffset)
        let hh = FeedsHelper.getHashCode(withPassword: "-Score$Board#APPS-", andDate: dt)
        
        urlRequest.addValue(dt, forHTTPHeaderField:"DT")
        urlRequest.addValue(hh, forHTTPHeaderField:"HH")
        
        // Set the UserId
        urlRequest.addValue(userId, forHTTPHeaderField:"UserId")
        
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) { (data, response, connectionError) in
            
            print("Response: " + response!.description)
            
            DispatchQueue.main.async
            {
                if (connectionError == nil)
                {
                    if let httpResponse = response as? HTTPURLResponse
                    {
                        if (httpResponse.statusCode == 200)
                        {
                            if (data != nil)
                            {
                                //let logDataReceived = String(decoding: data!, as: UTF8.self)
                                //print(logDataReceived)
                                
                                completionHandler(data, nil)
                            }
                            else
                            {
                                print("Data was nil")
                                let errorDictionary = [NSLocalizedDescriptionKey : "Data was nil"]
                                let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                completionHandler(nil, error)
                            }
                        }
                        else
                        {
                            print("Status != 200")
                            let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                            completionHandler(nil, error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(nil, error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(nil, error)
                }
            }
        }
        
        task.resume()
    }
    
    class func saveUserImage(userId: String, imageData: Data, completionHandler: @escaping (_ post: Data?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = kSaveUserImageUrlDev
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = kSaveUserImageUrlDev
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = kSaveUserImageUrlStaging
        }
        else
        {
            urlString = kSaveUserImageUrlProduction
        }
                
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        
        // Calculate the DT and HH values using the FeedsHelper
        let dt = FeedsHelper.getDateCode(SharedData.utcTimeOffset)
        let hh = FeedsHelper.getHashCode(withPassword: "-Score$Board#APPS-", andDate: dt)
        
        urlRequest.addValue(dt, forHTTPHeaderField:"DT")
        urlRequest.addValue(hh, forHTTPHeaderField:"HH")
        
        // Set the UserId
        urlRequest.addValue(userId, forHTTPHeaderField:"UserId")
        
        // Build the ContentType
        let boundary = FeedsHelper.generateBoundaryString()
        let contentType = "multipart/form-data; boundary=" + boundary
        urlRequest.addValue(contentType, forHTTPHeaderField: "Content-Type")

        var body = Data()
        
        // Add the delimiting starting boundary
        let bodyPart1String = "\r\n--" + boundary + "\r\n"
        let bodyPart1Data: Data? = bodyPart1String.data(using: .utf8)
        body.append(bodyPart1Data!)
        
        let bodyPart2String = "Content-Disposition: form-data; name=\"profilepic.jpeg\"; filename=\"picture.jpeg\"\r\n"
        let bodyPart2Data: Data? = bodyPart2String.data(using: .utf8)
        body.append(bodyPart2Data!)
        
        let bodyPart3String = "Content-Type: image/jpeg\r\n\r\n"
        let bodyPart3Data: Data? = bodyPart3String.data(using: .utf8)
        body.append(bodyPart3Data!)
        
        // Now we append the actual image data
        body.append(imageData)
        
        // And the delimiting end boundary
        let bodyPart4String = "\r\n--" + boundary + "--\r\n"
        let bodyPart4Data: Data? = bodyPart4String.data(using: .utf8)
        body.append(bodyPart4Data!)
        
        urlRequest.httpBody = body
        
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) { (data, response, connectionError) in
            
            print("Response: " + response!.description)
            
            DispatchQueue.main.async
            {
                if (connectionError == nil)
                {
                    if let httpResponse = response as? HTTPURLResponse
                    {
                        if (httpResponse.statusCode == 200)
                        {
                            if (data != nil)
                            {
                                //let logDataReceived = String(decoding: data!, as: UTF8.self)
                                //print(logDataReceived)
                                
                                completionHandler(data, nil)
                            }
                            else
                            {
                                print("Data was nil")
                                let errorDictionary = [NSLocalizedDescriptionKey : "Data was nil"]
                                let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                completionHandler(nil, error)
                            }
                        }
                        else
                        {
                            print("Status != 200")
                            let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                            completionHandler(nil, error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(nil, error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(nil, error)
                }
            }
        }
        
        task.resume()
        
    }
    
    class func deleteUserImage(userId: String, completionHandler: @escaping (_ post: Data?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = kDeleteUserImageUrlDev
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = kDeleteUserImageUrlDev
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = kDeleteUserImageUrlStaging
        }
        else
        {
            urlString = kDeleteUserImageUrlProduction
        }
                
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("octet/stream", forHTTPHeaderField: "Content-Type")
        
        // Calculate the DT and HH values using the FeedsHelper
        let dt = FeedsHelper.getDateCode(SharedData.utcTimeOffset)
        let hh = FeedsHelper.getHashCode(withPassword: "-Score$Board#APPS-", andDate: dt)
        
        urlRequest.addValue(dt, forHTTPHeaderField:"DT")
        urlRequest.addValue(hh, forHTTPHeaderField:"HH")
        
        // Set the UserId
        urlRequest.addValue(userId, forHTTPHeaderField:"UserId")
        
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) { (data, response, connectionError) in
            
            print("Response: " + response!.description)
            
            DispatchQueue.main.async
            {
                if (connectionError == nil)
                {
                    if let httpResponse = response as? HTTPURLResponse
                    {
                        if (httpResponse.statusCode == 200)
                        {
                            if (data != nil)
                            {
                                //let logDataReceived = String(decoding: data!, as: UTF8.self)
                                //print(logDataReceived)
                                
                                completionHandler(data, nil)
                            }
                            else
                            {
                                print("Data was nil")
                                let errorDictionary = [NSLocalizedDescriptionKey : "Data was nil"]
                                let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                completionHandler(nil, error)
                            }
                        }
                        else
                        {
                            print("Status != 200")
                            let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                            completionHandler(nil, error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(nil, error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(nil, error)
                }
            }
        }
        
        task.resume()
    }
    
    
}

