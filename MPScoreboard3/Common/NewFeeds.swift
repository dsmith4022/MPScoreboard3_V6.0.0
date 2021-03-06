//
//  NewFeeds.swift
//  MPScoreboard3
//
//  Created by David Smith on 3/18/21.
//

import UIKit

class NewFeeds: NSObject
{
    // MARK: - User Info Feeds
    
    class func getUserInfo(completionHandler: @escaping (_ userInfo: Array<Dictionary<String, Any>>?, _ error: Error?) -> Void)
    {
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kUserInfoHostDev, userId!)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kUserInfoHostDev, userId!)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kUserInfoHostStaging, userId!)
        }
        else
        {
            urlString = String(format: kUserInfoHostProduction, userId!)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
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
                                //let logDataReceived = String(decoding: data!, as: UTF8.self)
                                //print(logDataReceived)
                                
                                // Decompose the JSON data
                                var dictionary : Dictionary<String, Any> = [:]
                                  
                                do {
                                    dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                    
                                    let data = dictionary["data"] as! Array< Dictionary<String, Any>>
                                    
                                    // Finish the call
                                    completionHandler(data,nil)
                                    
                                }
                                catch let error as NSError
                                {
                                    print(error)
                                    print("Json Error: " + error.localizedDescription)
                                    let errorDictionary = [NSLocalizedDescriptionKey : "Json Decode Error: " + error.localizedDescription]
                                    let compositeError = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                    completionHandler(nil,compositeError)
                                }
                                
                            }
                            else
                            {
                                print("Data was nil")
                                let errorDictionary = [NSLocalizedDescriptionKey : "Data was nil"]
                                let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                completionHandler(nil,error)
                            }
                        }
                        else
                        {
                            print("Status != 200")
                            
                            if (data != nil)
                            {
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                            }
                            
                            let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                            completionHandler(nil,error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(nil,error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(nil,error)
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - User Favorite Teams Feeds
    
    class func getUserFavoriteTeams(completionHandler: @escaping (_ error: Error?) -> Void)
    {
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kNewGetUserFavoriteTeamsHostDev, userId!)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kNewGetUserFavoriteTeamsHostDev, userId!)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kNewGetUserFavoriteTeamsHostStaging, userId!)
        }
        else
        {
            urlString = String(format: kNewGetUserFavoriteTeamsHostProduction, userId!)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
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
                                //let logDataReceived = String(decoding: data!, as: UTF8.self)
                                //print(logDataReceived)
                                
                                // Decompose the JSON data
                                var dictionary : Dictionary<String, Any> = [:]
                                  
                                do {
                                    dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                    
                                    let data = dictionary["data"] as! Dictionary<String, Any>
                                    let favorites = data["teams"] as! Array<Dictionary<String, Any>>
                                    
                                    if (favorites.count > 0)
                                    {
                                        // Sort the teams as Admin first, Member second, and the rest last
                                        var admins = [] as! Array<Dictionary<String,Any>>
                                        var members = [] as! Array<Dictionary<String,Any>>
                                        var followers = [] as! Array<Dictionary<String,Any>>
                                        
                                        for favorite in favorites
                                        {
                                            let schoolId = favorite[kNewSchoolIdKey] as! String
                                            let allSeasonId = favorite[kNewAllSeasonIdKey] as! String
                                            
                                            // Look at the roles dictionary for a match
                                            let adminRoles = kUserDefaults.dictionary(forKey: kUserAdminRolesDictionaryKey)
                                            let roleKey = schoolId + "_" + allSeasonId
                                            
                                            if (adminRoles != nil) && (adminRoles![roleKey] != nil)
                                            {
                                                let adminRole = adminRoles![roleKey] as! Dictionary<String,String>
                                                let roleName = adminRole[kRoleNameKey]
                                                
                                                if ((roleName == "Head Coach") || (roleName == "Assistant Coach") || (roleName == "Statistician"))
                                                {
                                                    admins.append(favorite )
                                                }
                                                else if (roleName == "Team Community")
                                                {
                                                    members.append(favorite)
                                                }
                                            }
                                            else
                                            {
                                                followers.append(favorite)
                                            }
                                        }
                                        
                                        var sortedFavorites = [] as! Array<Dictionary<String,Any>>
                                        
                                        for item in admins
                                        {
                                            sortedFavorites.append(item)
                                        }
                                        
                                        for item in members
                                        {
                                            sortedFavorites.append(item)
                                        }
                                        
                                        for item in followers
                                        {
                                            sortedFavorites.append(item)
                                        }
                                        
                                        
                                        // Update the prefs
                                        kUserDefaults.setValue(sortedFavorites, forKey: kNewUserFavoriteTeamsArrayKey)
                                    }
                                    else
                                    {
                                        // Remove the favorites object from prefs
                                        kUserDefaults.removeObject(forKey: kNewUserFavoriteTeamsArrayKey)
                                    }
                                    
                                    // Finish the call
                                    completionHandler(nil)
                                    
                                }
                                catch let error as NSError
                                {
                                    print(error)
                                    print("Json Error: " + error.localizedDescription)
                                    let errorDictionary = [NSLocalizedDescriptionKey : "Json Decode Error: " + error.localizedDescription]
                                    let compositeError = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                    completionHandler(compositeError)
                                }
                                
                            }
                            else
                            {
                                print("Data was nil")
                                let errorDictionary = [NSLocalizedDescriptionKey : "Data was nil"]
                                let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                completionHandler(error)
                            }
                        }
                        else
                        {
                            print("Status != 200")
                            
                            if (data != nil)
                            {
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                            }
                            
                            let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                            completionHandler(error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(error)
                }
            }
        }
        
        task.resume()
    }
    
    class func deleteUserFavoriteTeam(favorite: Dictionary<String, Any>, completionHandler: @escaping (_ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        let teamIdNumber = favorite[kNewUserfavoriteTeamIdKey] as! Int
        let teamId = String(teamIdNumber)
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kNewDeleteUserFavoriteTeamHostDev, userId, teamId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kNewDeleteUserFavoriteTeamHostDev, userId, teamId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kNewDeleteUserFavoriteTeamHostStaging, userId, teamId)
        }
        else
        {
            urlString = String(format: kNewDeleteUserFavoriteTeamHostProduction, userId, teamId)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "DELETE"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        // Get the encrypted token
        let encryptedUserId = FeedsHelper.encryptString(userId)
        urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
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
                            completionHandler(nil)
                        }
                        else
                        {
                            print("Status != 200")
                            
                            if (data != nil)
                            {
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                            }
                            
                            let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                            completionHandler(error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(error)
                }
            }
        }
        
        task.resume()
    }
    
    class func saveUserFavoriteTeam(_ favorite: Dictionary<String,Any>, completionHandler: @escaping (_ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kNewSaveUserFavoriteTeamHostDev, userId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kNewSaveUserFavoriteTeamHostDev, userId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kNewSaveUserFavoriteTeamHostStaging, userId)
        }
        else
        {
            urlString = String(format: kNewSaveUserFavoriteTeamHostProduction, userId)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        // Get the encrypted token
        let encryptedUserId = FeedsHelper.encryptString(userId)
        urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
        // Build the header dictionary for Exact Target Emails
        urlRequest.addValue("MaxprepsApp_IOS", forHTTPHeaderField: "mp-sources-page-source")
        
        /*
         POST data:
         {
             "userId": "597a0efd-7622-4291-88a9-ef72bf99cdc2",
             "schoolId": "74c1621c-e0cf-4821-b5e1-3c8170c8125a",
             "allSeasonId": "A42C7EA4-0907-491E-B56F-A2D31A45BF19",
             "seasonName": "Winter",
             "source": "MaxprepsApp_IOS"
         }
         */
        
        let schoolId = favorite[kNewSchoolIdKey]
        let allSeasonId = favorite[kNewAllSeasonIdKey]
        let season = favorite[kNewSeasonKey]
        
        let jsonDict = [kNewSchoolIdKey: schoolId, kNewAllSeasonIdKey: allSeasonId, "userId": userId, "seasonName": season, "source": "MaxprepsApp_IOS"]
        
        var postBodyData: Data? = nil
        do {
            postBodyData = try JSONSerialization.data(withJSONObject: jsonDict, options: [])
        }
        catch
        {
            let errorDictionary = [NSLocalizedDescriptionKey : "JSON error"]
            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
            completionHandler(error)
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
                            completionHandler(nil)
                        }
                        else
                        {
                            print("Status != 200")
                            
                            if (data != nil)
                            {
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                            }
                            
                            let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                            completionHandler(error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(error)
                }
            }
        }
        
        task.resume()
    }
    
    class func updateTeamNotificationSetting(_ settingId: Int, switchValue value: Bool, completionHandler: @escaping (_ error: Error?) -> Void)
    {
        var urlString : String
        let settingId = String(settingId)
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kNewUpdateUserFavoriteTeamNotificationHostDev, settingId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kNewUpdateUserFavoriteTeamNotificationHostDev, settingId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kNewUpdateUserFavoriteTeamNotificationHostStaging, settingId)
        }
        else
        {
            urlString = String(format: kNewUpdateUserFavoriteTeamNotificationHostProduction, settingId)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "PATCH"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json-patch+json;charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        // Get the encrypted token
        let encryptedUserId = FeedsHelper.encryptString(userId)
        urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
        /*
         PATCH data:
         {
             "value": true,
             "path": "IsEnabledForApp",
             "op": "Replace",
         }
         */
        
        let jsonDict = ["value": value, "path": "IsEnabledForApp", "op": "replace"] as [String : Any]
        let jsonArray = [jsonDict]
        
        var postBodyData: Data? = nil
        do {
            postBodyData = try JSONSerialization.data(withJSONObject: jsonArray, options: [])
        }
        catch
        {
            let errorDictionary = [NSLocalizedDescriptionKey : "JSON error"]
            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
            completionHandler(error)
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
                            completionHandler(nil)
                        }
                        else
                        {
                            print("Status != 200")
                            
                            if (data != nil)
                            {
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                            }
                            
                            let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                            completionHandler(error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(error)
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - User Favorite Athletes Feeds
    
    class func getUserFavoriteAthletes(completionHandler: @escaping (_ error: Error?) -> Void)
    {
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetUserFavoriteAthletesHostDev, userId!)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetUserFavoriteAthletesHostDev, userId!)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetUserFavoriteAthletesHostStaging, userId!)
        }
        else
        {
            urlString = String(format: kGetUserFavoriteAthletesHostProduction, userId!)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        // Get the encrypted token
        let encryptedUserId = FeedsHelper.encryptString(userId!)
        urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
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
                                    
                                    let athletes = dictionary["data"] as! Array<Dictionary<String,Any>>
                                    
                                    if (athletes.count > 0)
                                    {
                                        // Extract the key items from the feed (some are NULL)
                                        /*
                                         let kUserFavoriteAthletesArrayKey = "UserFavoriteAthletesArray"         // Array
                                         let kAthleteCareerProfileFirstNameKey = "careerProfileFirstName"        // String
                                         let kAthleteCareerProfileLastNameKey = "careerProfileLastName"          // String
                                         let kAthleteCareerProfileSchoolIdKey = "schoolId"                       // String
                                         let kAthleteCareerProfileSchoolNameKey = "schoolName"                   // String
                                         let kAthleteCareerProfileSchoolColor1Key = "schoolColor1"               // String
                                         let kAthleteCareerProfileSchoolMascotUrlKey = "schoolMascotUrl"         // String
                                         let kAthleteCareerProfileSchoolCityKey = "schoolCity"                   // String
                                         let kAthleteCareerProfileSchoolStateKey = "schoolState"                 // String
                                         let kAthleteCareerProfileIdKey = "careerProfileId"                      // String
                                         let kAthleteCareerProfilePhotoUrlKey = "photoUrl"                       // String
                                         */
                                        
                                        var fixedAthletes : Array<Dictionary<String,Any>> = []
                                        
                                        for athlete in athletes
                                        {
                                            // Clean up the NULL values before saving to prefs
                                            let allKeys = athlete.keys
                                            var replacementAthlete = [:] as Dictionary<String,Any>
                                            
                                            for key in allKeys
                                            {
                                                if let value = athlete[key] as? String
                                                {
                                                    replacementAthlete[key] = value
                                                }
                                                else
                                                {
                                                    replacementAthlete[key] = ""
                                                }
                                            }
                                            
                                            fixedAthletes.append(replacementAthlete)
                                        }
                                        
                                        // Update the prefs
                                        kUserDefaults.setValue(fixedAthletes, forKey: kUserFavoriteAthletesArrayKey)
                                    }
                                    else
                                    {
                                        // Remove the favorites object from prefs
                                        kUserDefaults.removeObject(forKey: kUserFavoriteAthletesArrayKey)
                                    }
                                    
                                    // Finish the call
                                    completionHandler(nil)
                                    
                                }
                                catch let error as NSError
                                {
                                    print(error)
                                    print("Json Error: " + error.localizedDescription)
                                    let errorDictionary = [NSLocalizedDescriptionKey : "Json Decode Error: " + error.localizedDescription]
                                    let compositeError = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                    completionHandler(compositeError)
                                }
                                
                            }
                            else
                            {
                                print("Data was nil")
                                let errorDictionary = [NSLocalizedDescriptionKey : "Data was nil"]
                                let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                completionHandler(error)
                            }
                        }
                        else
                        {
                            print("Status != 200")
                            
                            if (data != nil)
                            {
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                            }
                            
                            let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                            completionHandler(error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(error)
                }
            }
        }
        
        task.resume()
    }
    
    class func saveUserFavoriteAthlete(_ careerProfileId: String, completionHandler: @escaping (_ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kAddUserFavoriteAthleteHostDev, userId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kAddUserFavoriteAthleteHostDev, userId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kAddUserFavoriteAthleteHostStaging, userId)
        }
        else
        {
            urlString = String(format: kAddUserFavoriteAthleteHostProduction, userId)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        // Get the encrypted token
        let encryptedUserId = FeedsHelper.encryptString(userId)
        urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
        // Build the header dictionary for Exact Target Emails
        urlRequest.addValue("MaxprepsApp_IOS", forHTTPHeaderField: "mp-sources-page-source")
        
        /*
         POST data:
         {
             "careerProfileId": "597a0efd-7622-4291-88a9-ef72bf99cdc2",
             "userId": "74c1621c-e0cf-4821-b5e1-3c8170c8125a",
         }
         */
        
        let jsonDict = ["careerProfileId": careerProfileId, "userId": userId]
        
        var postBodyData: Data? = nil
        do {
            postBodyData = try JSONSerialization.data(withJSONObject: jsonDict, options: [])
        }
        catch
        {
            let errorDictionary = [NSLocalizedDescriptionKey : "JSON error"]
            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
            completionHandler(error)
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
                            completionHandler(nil)
                        }
                        else
                        {
                            print("Status != 200")
                            
                            if (data != nil)
                            {
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                            }
                            
                            let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                            completionHandler(error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(error)
                }
            }
        }
        
        task.resume()
    }
    
    class func deleteUserFavoriteAthlete(_ careerProfileId: String, completionHandler: @escaping (_ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kDeleteUserFavoriteAthleteHostDev, userId, careerProfileId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kDeleteUserFavoriteAthleteHostDev, userId, careerProfileId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kDeleteUserFavoriteAthleteHostStaging, userId, careerProfileId)
        }
        else
        {
            urlString = String(format: kDeleteUserFavoriteAthleteHostProduction, userId, careerProfileId)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "DELETE"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        // Get the encrypted token
        let encryptedUserId = FeedsHelper.encryptString(userId)
        urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
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
                            completionHandler(nil)
                        }
                        else
                        {
                            print("Status != 200")
                            
                            if (data != nil)
                            {
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                            }
                            
                            let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                            completionHandler(error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(error)
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - Get School Info for School Ids
    
    class func getSchoolInfoForSchoolIds(_ schoolIdArray: Array<String>, completionHandler: @escaping (_ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = kNewGetInfoForSchoolsHostDev
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = kNewGetInfoForSchoolsHostDev
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = kNewGetInfoForSchoolsHostStaging
        }
        else
        {
            urlString = kNewGetInfoForSchoolsHostProduction
        }

        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        var postBodyData: Data? = nil
        do {
            postBodyData = try JSONSerialization.data(withJSONObject: schoolIdArray, options: [])
        }
        catch
        {
            let errorDictionary = [NSLocalizedDescriptionKey : "JSON error"]
            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
            completionHandler(error)
            return
        }

        let logDataReceived = String(decoding: postBodyData!, as: UTF8.self)
        print(logDataReceived)

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
                                    
                                    let schoolInfos = dictionary["data"] as! Array<Any>
                                            
                                    if (schoolInfos.count > 0)
                                    {
                                        var schoolInfo : Dictionary<String, Any> = [:]
                                                
                                        for info in schoolInfos
                                        {
                                            let item = info as! Dictionary<String, Any>
                                            let schoolId = item[kNewSchoolInfoSchoolIdKey] as! String
                                            let mascotUrl = item[kNewSchoolInfoMascotUrlKey] as! String
                                            let schoolColor = item[kNewSchoolInfoColor1Key] as! String
                                            let schoolName = item[kNewSchoolInfoNameKey] as! String
                                            let schoolFullName = item[kNewSchoolInfoFullNameKey] as! String
                                            
                                            let schoolData = [kNewSchoolInfoSchoolIdKey:schoolId, kNewSchoolInfoMascotUrlKey:mascotUrl, kNewSchoolInfoColor1Key:schoolColor, kNewSchoolInfoNameKey:schoolName, kNewSchoolInfoFullNameKey:schoolFullName]
                                                    
                                            schoolInfo.updateValue(schoolData, forKey: schoolId)
                                        }
                                                
                                        // Update prefs with the data
                                        kUserDefaults.setValue(schoolInfo, forKey: kNewSchoolInfoDictionaryKey)
                                    }
                                    else
                                    {
                                        kUserDefaults.removeObject(forKey: kNewSchoolInfoDictionaryKey)
                                    }
                                            
                                    completionHandler(nil)
                                }
                                catch let error as NSError
                                {
                                    print(error)
                                    print("Json Error: " + error.localizedDescription)
                                    let errorDictionary = [NSLocalizedDescriptionKey : "Json Decode Error: " + error.localizedDescription]
                                    let compositeError = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                    completionHandler(compositeError)
                                }
                            }
                            else
                            {
                                print("Data was nil")
                                let errorDictionary = [NSLocalizedDescriptionKey : "Data was nil"]
                                let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                completionHandler(error)
                            }
                        }
                        else
                        {
                            print("Status != 200")
                            
                            if (data != nil)
                            {
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                            }

                            let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                            completionHandler(error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(error)
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - Get Available Teams
    
    class func getAvailableTeamsForSchool(schoolId: String, completionHandler: @escaping (_ availableTeams: Dictionary<String, Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kNewGetTeamsForSchoolHostDev, schoolId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kNewGetTeamsForSchoolHostDev, schoolId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kNewGetTeamsForSchoolHostStaging, schoolId)
        }
        else
        {
            urlString = String(format: kNewGetTeamsForSchoolHostProduction, schoolId)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
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
                                //let logDataReceived = String(decoding: data!, as: UTF8.self)
                                //print(logDataReceived)
                                
                                // Decompose the JSON data
                                var dictionary : Dictionary<String, Any> = [:]
                                  
                                do {
                                    dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                    
                                    let availableTeams = dictionary["data"] as! Dictionary<String, Any>
                                    completionHandler(availableTeams, nil)
                                    
                                    /*
                                      {
                                      "teamId": "cbd85b5c-91e4-46cf-9849-b1cd0b78972c",
                                      "sportSeasonId": "b2e164af-cc17-44b1-a3f3-c4798695f001",
                                      "hasTeamRoster": false,
                                      "hasContests": true,
                                      "hasLeagueStandings": false,
                                      "hasStats": false,
                                      "hasRankings": false,
                                      "hasVideos": false,
                                      "hasProPhotos": true,
                                      "hasArticles": false,
                                      "isPrepsSportsEnabled": false,
                                      "updatedOn": "2020-12-10T22:16:38.1823174Z"
                                      }
                                     */
                                
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
                            
                            if (data != nil)
                            {
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                            }
                            
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
    
    // MARK: - Get SSID's for Team
    
    class func getSSIDsForTeam(_ allSeasonId: String, schoolId: String, completionHandler: @escaping (_ availableItems: Array<Dictionary<String, Any>>?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetSSIDsForTeamHostDev, schoolId, allSeasonId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetSSIDsForTeamHostDev, schoolId, allSeasonId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetSSIDsForTeamHostStaging, schoolId, allSeasonId)
        }
        else
        {
            urlString = String(format: kGetSSIDsForTeamHostProduction, schoolId, allSeasonId)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
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
                                //let logDataReceived = String(decoding: data!, as: UTF8.self)
                                //print(logDataReceived)
                                
                                // Decompose the JSON data
                                var dictionary : Dictionary<String, Any> = [:]
                                  
                                do {
                                    dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                    
                                    let items = dictionary["data"] as! Array<Dictionary<String, Any>>
                                    completionHandler(items, nil)
                                
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
                            
                            if (data != nil)
                            {
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                            }
                            
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
    
    // MARK: - Get Team Record
    
    class func getTeamRecord(_ teamId: String, schoolId: String, completionHandler: @escaping (_ result: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetTeamRecordHostDev, schoolId, teamId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetTeamRecordHostDev, schoolId, teamId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetTeamRecordHostStaging, schoolId, teamId)
        }
        else
        {
            urlString = String(format: kGetTeamRecordHostProduction, schoolId, teamId)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
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
                                //let logDataReceived = String(decoding: data!, as: UTF8.self)
                                //print(logDataReceived)
                                
                                // Decompose the JSON data
                                var dictionary : Dictionary<String, Any> = [:]
                                  
                                do {
                                    dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                    
                                    let items = dictionary["data"] as! Dictionary<String, Any>
                                    completionHandler(items, nil)
                                
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
                            
                            if (data != nil)
                            {
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                            }
                            
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
    
    // MARK: - Get Available Item for Team
    
    class func getAvailableItemsForTeam(_ teamId: String, schoolId: String, completionHandler: @escaping (_ availableItems: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetTeamAvailabilityHostDev, schoolId, teamId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetTeamAvailabilityHostDev, schoolId, teamId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetTeamAvailabilityHostStaging, schoolId, teamId)
        }
        else
        {
            urlString = String(format: kGetTeamAvailabilityHostProduction, schoolId, teamId)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
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
                                //let logDataReceived = String(decoding: data!, as: UTF8.self)
                                //print(logDataReceived)
                                
                                // Decompose the JSON data
                                var dictionary : Dictionary<String, Any> = [:]
                                  
                                do {
                                    dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                    
                                    let items = dictionary["data"] as! Dictionary<String, Any>
                                    completionHandler(items, nil)
                                
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
                            
                            if (data != nil)
                            {
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                            }
                            
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
    
    // MARK: - Get Bitly URL Feed
    
    class func getBitlyUrl(_ urlString: String, completionHandler: @escaping (_ dictionary: Dictionary<String, Any>?, _ error: Error?) -> Void)
    {
        
        var bitlyUrlString : String
        
        // Replace any & with %26
        let set = NSCharacterSet.urlHostAllowed
        let fixedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: set)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            bitlyUrlString = String(format: kBitlyUrlConverterHostDev, fixedUrlString)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            bitlyUrlString = String(format: kBitlyUrlConverterHostDev, fixedUrlString)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            bitlyUrlString = String(format: kBitlyUrlConverterHostStaging, fixedUrlString)
        }
        else
        {
            bitlyUrlString = String(format: kBitlyUrlConverterHostProduction, fixedUrlString)
        }
        
        // Replace any & with %26
        //let set = NSCharacterSet.urlHostAllowed
        //let fixedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: set)!
        //let bitlyUrlString = bitlyHostString + "?url=" + fixedUrlString

        var urlRequest = URLRequest(url: URL(string: bitlyUrlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "POST"
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
                                    
                                    completionHandler(dictionary, nil)
                                    
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
                            
                            if (data != nil)
                            {
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                            }
                            
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
    
    // MARK: - Get Team Detail Card Feed
    
    class func getDetailCardDataForTeams(_ teams: Array<Dictionary<String,Any>>, completionHandler: @escaping (_ results: Array<Dictionary<String, Any>>?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = kGetTeamDetailCardHostDev
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = kGetTeamDetailCardHostDev
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = kGetTeamDetailCardHostStaging
        }
        else
        {
            urlString = kGetTeamDetailCardHostProduction
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        var postBodyData: Data? = nil
        do {
            postBodyData = try JSONSerialization.data(withJSONObject: teams, options: [])
        }
        catch
        {
            let errorDictionary = [NSLocalizedDescriptionKey : "JSON error"]
            let jsonError = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
            completionHandler(nil,jsonError)
            return
        }

        let logDataReceived = String(decoding: postBodyData!, as: UTF8.self)
        print(logDataReceived)

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
                                    
                                    let results = dictionary["data"] as! Array<Dictionary<String,Any>>
                                            
                                    completionHandler(results, nil)
                                    
                                    /*
                                     {
                                         "status": 200,
                                         "message": "Success",
                                         "cacheResult": "Unknown",
                                         "data": [
                                             {
                                                 "teamId": "d9622df1-9a90-49e7-b219-d6c380c566fe",
                                                 "allSeasonId": "22e2b335-334e-4d4d-9f67-a0f716bb1ccd",
                                                 "cardItems": [
                                                     {
                                                         "record": {
                                                             "overallStanding": {
                                                                 "winningPercentage": 0.000,
                                                                 "overallWinLossTies": "0-0",
                                                                 "homeWinLossTies": "0-0",
                                                                 "awayWinLossTies": "0-0",
                                                                 "neutralWinLossTies": "0-0",
                                                                 "points": 0,
                                                                 "pointsAgainst": 0,
                                                                 "streak": 0,
                                                                 "streakResult": "0"
                                                             },
                                                             "leagueStanding": {
                                                                 "leagueName": "Foothill Valley",
                                                                 "canonicalUrl": "https://z.maxpreps.com/league/vIKP_ANcBEeRvG9E5Ztn4Q/standings-foothill-valley.htm",
                                                                 "conferenceWinningPercentage": 0.000,
                                                                 "conferenceWinLossTies": "0-0",
                                                                 "conferenceStandingPlacement": "1st"
                                                             }
                                                         }
                                                     },
                                                     {
                                                         "schedules": [
                                                             {
                                                                 "hasResult": false,
                                                                 "resultString": "",
                                                                 "dateString": "3/19",
                                                                 "timeString": "7:00 PM",
                                                                 "opponentMascotUrl": "https://d1yf833igi2o06.cloudfront.net/fit-in/1024x1024/school-mascot/6/1/5/61563c75-3efb-427f-8329-767978b469df.gif?version=636520747200000000",
                                                                 "opponentName": "Rio Linda",
                                                                 "opponentNameAcronym": "RLHS",
                                                                 "opponentUrl": "https://dev.maxpreps.com/high-schools/rio-linda-knights-(rio-linda,ca)/football/home.htm",
                                                    "opponentColor1": "000080",
                                                                 "homeAwayType": "Home",
                                                                 "contestIsLive": false,
                                                                 "canonicalUrl": "https://dev.maxpreps.com/games/3-19-21/football-fall-20/ponderosa-vs-rio-linda.htm?c=OIRYlXxgWEaHfK7OipEITQ"
                                                             },
                                                             {
                                                                 "hasResult": false,
                                                                 "resultString": "",
                                                                 "dateString": "3/25",
                                                                 "timeString": "12:00 PM",
                                                                 "opponentMascotUrl": "https://d1yf833igi2o06.cloudfront.net/fit-in/1024x1024/school-mascot/6/1/5/61563c75-3efb-427f-8329-767978b469df.gif?version=636520747200000000",
                                                                 "opponentName": "Rio Linda",
                                                                 "opponentNameAcronym": "RLHS",
                                                                 "opponentUrl": "https://dev.maxpreps.com/high-schools/rio-linda-knights-(rio-linda,ca)/football/home.htm",
                                                    "opponentColor1": "000080",
                                                                 "homeAwayType": "Neutral",
                                                                 "contestIsLive": false,
                                                                 "canonicalUrl": "https://dev.maxpreps.com/games/3-25-21/football-fall-20/ponderosa-vs-rio-linda.htm?c=ZLpSnJTDFUSEscaGO3BsYQ"
                                                             }
                                                         ]
                                                     },
                                                     {
                                                         "latestItems": [
                                                             {
                                                                 "type": "Article",
                                                                 "title": "State officials, CIF, coaches meet",
                                                                 "text": "Dr. Mark Ghaly enters discussion; California coaches group calls meeting 'cooperative,  positive, and open,' but student-athletes are running out of time. ",
                                                                 "thumbnailUrl": "https://images.maxpreps.com/editorial/article/c/b/8/cb8ee48f-fe58-44dc-baec-f00d7ccf7692/3a4ed84d-c366-eb11-80ce-a444a33a3a97_original.jpg?version=637481180400000000",
                                                                 "thumbnailWidth": null,
                                                                 "thumbnailHeight": null,
                                                                 "canonicalUrl": "https://dev.maxpreps.com/news/j-SOy1j-3ES67PANfM92kg/california-high-school-sports--state-officials,-cif,-coaches-find-common-ground,-talks-to-resume-next-week.htm"
                                                             },
                                                             {
                                                                 "type": "Article",
                                                                 "title": "New hope for California sports",
                                                                 "text": "Teams slotted in purple tier now allowed to compete; four Sac-Joaquin Section cross country teams ran in Monday meet.",
                                                                 "thumbnailUrl": "https://images.maxpreps.com/editorial/article/5/0/7/507b80b1-d75a-4909-b52c-474eef259269/e618f53f-745f-eb11-80ce-a444a33a3a97_original.jpg?version=637471932600000000",
                                                                 "thumbnailWidth": null,
                                                                 "thumbnailHeight": null,
                                                                 "canonicalUrl": "https://dev.maxpreps.com/news/sYB7UFrXCUm1LEdO7yWSaQ/new-hope-for-california-high-school-sports-after-stay-home-orders-lifted.htm"
                                                             },
                                                             {
                                                                 "type": "Article",
                                                                 "title": "SJS releases new play for Season 1 in 2021",
                                                                 "text": "State's second-largest section will forego traditional postseason to allow schools chance to participate in more games. ",
                                                                 "thumbnailUrl": "https://images.maxpreps.com/editorial/article/d/2/9/d298908e-0c1c-46aa-861c-96e4fa76ffad/07b358d0-8941-eb11-80ce-a444a33a3a97_original.jpg?version=637439061000000000",
                                                                 "thumbnailWidth": null,
                                                                 "thumbnailHeight": null,
                                                                 "canonicalUrl": "https://dev.maxpreps.com/news/jpCY0hwMqkaGHJbk-nb_rQ/sac-joaquin-section-releases-new-plan-for-season-1-in-2021.htm"
                                                             },
                                                             {
                                                                 "type": "Article",
                                                                 "title": "Video: When will California sports return?",
                                                                 "text": "Health and Human Services agency provides an update as state grapples with COVID-19 guidelines, tiers.",
                                                                 "thumbnailUrl": "https://images.maxpreps.com/editorial/article/a/9/a/a9a554a4-6e1b-4835-828a-4b989d7a79a9/2cf9a134-d723-eb11-80ce-a444a33a3a97_original.jpg?version=637409524200000000",
                                                                 "thumbnailWidth": null,
                                                                 "thumbnailHeight": null,
                                                                 "canonicalUrl": "https://dev.maxpreps.com/news/pFSlqRtuNUiCikuYnXp5qQ/video--when-will-california-high-school-and-youth-sports-return.htm"
                                                             },
                                                             {
                                                                 "type": "Article",
                                                                 "title": "Map: Where NFL QBs went to high school",
                                                                 "text": "Patrick Mahomes, Kyler Murray join 18 other quarterbacks who played high school football in Texas.",
                                                                 "thumbnailUrl": "https://images.maxpreps.com/editorial/article/a/e/0/ae0a7fa5-86bc-4082-91e3-4cf67d094940/29d89c6e-d17d-ea11-80ce-a444a33a3a97_original.jpg?version=637223926200000000",
                                                                 "thumbnailWidth": null,
                                                                 "thumbnailHeight": null,
                                                                 "canonicalUrl": "https://dev.maxpreps.com/news/pX8KrryGgkCR40z2fQlJQA/map--where-every-nfl-quarterback-drafted-in-the-past-10-years-played-high-school-football.htm"
                                                             }
                                                         ]
                                                     }
                                                 ]
                                             }
                                         ],
                                         "warnings": [],
                                         "errors": []
                                     }
                                     */
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
                            
                            if (data != nil)
                            {
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                            }

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
    
    // MARK: - Search for Athlete Feed
    
    class func searchForAthlete(_ name: String, _ gender: String, _ sport: String, completionHandler: @escaping (_ athletes: Array<Dictionary<String, Any>>?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        // Clean up the name
        let escapedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)?.lowercased()
        
        // Replace the ampersands in the sport with %26
        let escapedSport = sport.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)?.lowercased()
        let fixedSport = escapedSport!.replacingOccurrences(of: "&", with: "%26")
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kAthleteSearchHostDev, escapedName!, gender.lowercased(), fixedSport)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kAthleteSearchHostDev, escapedName!, gender.lowercased(), fixedSport)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kAthleteSearchHostStaging, escapedName!, gender.lowercased(), fixedSport)
        }
        else
        {
            urlString = String(format: kAthleteSearchHostProduction, escapedName!, gender.lowercased(), fixedSport)
        }
        
        // optional "&maxresults=%@&state=%@&year=%@"
        
        // Clean up the URL with escape characters
        //let escapedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
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
                                //let logDataReceived = String(decoding: data!, as: UTF8.self)
                                //print(logDataReceived)
                                
                                // Decompose the JSON data
                                var dictionary : Dictionary<String, Any> = [:]
                                  
                                do {
                                    dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                    
                                    let data = dictionary["data"] as! Array< Dictionary<String, Any>>
                                    
                                    // Finish the call
                                    completionHandler(data,nil)
                                    
                                }
                                catch let error as NSError
                                {
                                    print(error)
                                    print("Json Error: " + error.localizedDescription)
                                    let errorDictionary = [NSLocalizedDescriptionKey : "Json Decode Error: " + error.localizedDescription]
                                    let compositeError = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                    completionHandler(nil,compositeError)
                                }
                                
                            }
                            else
                            {
                                print("Data was nil")
                                let errorDictionary = [NSLocalizedDescriptionKey : "Data was nil"]
                                let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                completionHandler(nil,error)
                            }
                        }
                        else
                        {
                            print("Status != 200")
                            
                            if (data != nil)
                            {
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                            }
                            
                            let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                            completionHandler(nil,error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(nil,error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(nil,error)
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - User Image Feeds
    
    class func saveUserImage(imageData: Data, completionHandler: @escaping (_ post: Data?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kSaveUserImageHostDev, userId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kSaveUserImageHostDev, userId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kSaveUserImageHostStaging, userId)
        }
        else
        {
            urlString = String(format: kSaveUserImageHostProduction, userId)
        }
                
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        
        // Get the encrypted token
        let encryptedUserId = FeedsHelper.encryptString(userId)
        urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
        // Build the header dictionary for Exact Target Emails
        urlRequest.addValue("MaxprepsApp_IOS", forHTTPHeaderField: "mp-sources-page-source")
        
        // Build the ContentType
        let boundary = FeedsHelper.generateBoundaryString()
        let contentType = "multipart/form-data; boundary=" + boundary
        urlRequest.addValue(contentType, forHTTPHeaderField: "Content-Type")

        var body = Data()
        
        // Add the delimiting starting boundary
        let bodyPart1String = "\r\n--" + boundary + "\r\n"
        let bodyPart1Data: Data? = bodyPart1String.data(using: .utf8)
        body.append(bodyPart1Data!)
        
        //let bodyPart2String = "Content-Disposition: form-data; name=\"profilepic.jpeg\"; filename=\"picture.jpeg\"\r\n"
        let bodyPart2String = "Content-Disposition: form-data; name=\"file\"; filename=\"picture.jpeg\"\r\n"
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
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                                
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
                            
                            if (data != nil)
                            {
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                            }
                            
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
    
    class func deleteUserImage(completionHandler: @escaping (_ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kDeleteUserImageHostDev, userId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kDeleteUserImageHostDev, userId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kDeleteUserImageHostStaging, userId)
        }
        else
        {
            urlString = String(format: kDeleteUserImageHostProduction, userId)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "DELETE"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        // Get the encrypted token
        let encryptedUserId = FeedsHelper.encryptString(userId)
        urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
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
                            completionHandler(nil)
                        }
                        else
                        {
                            print("Status != 200")
                            
                            if (data != nil)
                            {
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                            }
                            
                            let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                            completionHandler(error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(error)
                }
            }
        }
        
        task.resume()
    }

    // MARK: - Test Feed
    
    class func loadCookie(_ favorite: Dictionary<String,Any>, completionHandler: @escaping (_ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kNewSaveUserFavoriteTeamHostDev, userId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kNewSaveUserFavoriteTeamHostDev, userId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kNewSaveUserFavoriteTeamHostStaging, userId)
        }
        else
        {
            urlString = String(format: kNewSaveUserFavoriteTeamHostProduction, userId)
        }
        
        urlString = "https://dev.api.maxpreps.com/utilities/testing/cookie/v1"
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        // Get the encrypted token
        let encryptedUserId = FeedsHelper.encryptString(userId)
        urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
        // Build the header dictionary for Exact Target Emails
        urlRequest.addValue("MaxprepsApp_IOS", forHTTPHeaderField: "mp-sources-page-source")
        
        /*
         POST data:
         {
             "userId": "597a0efd-7622-4291-88a9-ef72bf99cdc2",
             "schoolId": "74c1621c-e0cf-4821-b5e1-3c8170c8125a",
             "allSeasonId": "A42C7EA4-0907-491E-B56F-A2D31A45BF19",
             "seasonName": "Winter",
             "source": "MaxprepsApp_IOS"
         }
         */
        
        //let schoolId = favorite[kNewSchoolIdKey]
        //let allSeasonId = favorite[kNewAllSeasonIdKey]
        //let season = favorite[kNewSeasonKey]
        
        //let jsonDict = [kNewSchoolIdKey: schoolId, kNewAllSeasonIdKey: allSeasonId, "userId": userId, "seasonName": season, "source": "MaxprepsApp_IOS"]
        let jsonDict = ["email": kDaveEmail, "password": kDavePassword]
        
        var postBodyData: Data? = nil
        do {
            postBodyData = try JSONSerialization.data(withJSONObject: jsonDict, options: [])
        }
        catch
        {
            let errorDictionary = [NSLocalizedDescriptionKey : "JSON error"]
            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
            completionHandler(error)
            return
        }

        let logData = String(decoding: postBodyData!, as: UTF8.self)
        print(logData)

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
                            completionHandler(nil)
                        }
                        else
                        {
                            print("Status != 200")
                            
                            if (data != nil)
                            {
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                            }
                            
                            let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                            completionHandler(error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(error)
                }
            }
        }
        
        task.resume()
    }
    
}
