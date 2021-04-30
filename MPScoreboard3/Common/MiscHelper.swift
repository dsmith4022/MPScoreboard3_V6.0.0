//
//  MiscHelper.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/9/21.
//

import UIKit

class MiscHelper: NSObject
{
    // MARK: - Alert Methods
    
    //  Converted to Swift 5.3 by Swiftify v5.3.25403 - https://swiftify.com/
    class func showAlert(in viewController: UIViewController?, withActionNames arrActionName: [AnyHashable]?, title: String?, message: String?, lastItemCancelType cancelType: Bool, block: @escaping (_ tag: Int) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        for i in 0..<(arrActionName?.count ?? 0) {
            var style: Int = UIAlertAction.Style.default.rawValue

            if i == (arrActionName?.count ?? 0) - 1 {
                if (cancelType)
                {
                    style = UIAlertAction.Style.destructive.rawValue
                }
            }

            var action: UIAlertAction? = nil
            if let style = UIAlertAction.Style(rawValue: style) {
                action = UIAlertAction(title: arrActionName?[i] as? String, style: style, handler: { action in
                    //if block != nil {
                        block(i)
                    //}
                    alert.dismiss(animated: true) {

                    }
                })
            }

            if let action = action {
                alert.addAction(action)
            }
        }

        alert.modalPresentationStyle = .fullScreen
        viewController?.present(alert, animated: true)
    }
    
    //  Converted to Swift 5.3 by Swiftify v5.3.25403 - https://swiftify.com/
    class func showActionSheet(in viewController: UIViewController?, withActionNames arrActionName: [AnyHashable]?, title: String?, message: String?, block: @escaping (_ tag: Int) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)


        for i in 0..<(arrActionName?.count ?? 0) {
            let action = UIAlertAction(title: arrActionName?[i] as? String, style: .default, handler: { action in
                //if block != nil {
                    block(i)
                //}
                alert.dismiss(animated: true) {

                }
            })

            alert.addAction(action)
        }

        // Adjust the default fonts
        if let title = title {
            let aTitle = NSMutableAttributedString(string: title, attributes: [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24)
            ])
            alert.setValue(aTitle, forKey: "attributedTitle")
        }

        if let message = message {
            let aMessage = NSMutableAttributedString(string: message, attributes: [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)
            ])
            alert.setValue(aMessage, forKey: "attributedMessage")
        }

        alert.modalPresentationStyle = .fullScreen
        viewController?.present(alert, animated: true)
    }
    
    
    // MARK: - File Methods
    
    class func documentDirectory() -> String {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                    .userDomainMask,
                                                                    true)
        return documentDirectory[0]
    }
    
    class func append(toPath path: String,
                        withPathComponent pathComponent: String) -> String? {
        if var pathURL = URL(string: path) {
            pathURL.appendPathComponent(pathComponent)
            
            return pathURL.absoluteString
        }
        
        return nil
    }
    
    class func readFile(fromDocumentsWithFileName fileName: String)
    {
        guard let filePath = self.append(toPath: self.documentDirectory(),
                                         withPathComponent: fileName) else {
                                            return
        }
        
        do {
            let savedString = try String(contentsOfFile: filePath)
            
            print(savedString)
        }
        catch
        {
            print("Error reading saved file")
        }
    }
    
    class func saveFile(text: String,
                      toDirectory directory: String,
                      withFileName fileName: String) {
        guard let filePath = self.append(toPath: directory,
                                         withPathComponent: fileName) else {
            return
        }
        
        do {
            try text.write(toFile: filePath,
                           atomically: true,
                           encoding: .utf8)
        } catch {
            print("Error", error)
            return
        }
        
        print("Save successful")
    }
    
    // MARK: - Download Data Async
    
    class func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ())
    {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    // MARK: - GenderSport Helpers
    
    class func genderSportLevelFrom(gender: String, sport: String, level: String) -> (String)
    {
        if ((sport.lowercased() == "football") || (sport.lowercased() == "softball") || (sport.lowercased() == "baseball") || (sport.lowercased() == "field hockey"))
        {
            return level + " " + sport
        }
        else
        {
            return gender + " " + level + " " + sport
        }
    }
    
    class func genderSportShortLevelFrom(gender: String, sport: String, level: String) -> (String)
    {
        var shortLevel = ""
        
        if (level == "Varsity")
        {
            shortLevel = "Var."
        }
        else if (level == "JV")
        {
            shortLevel = "JV"
        }
        else if (level == "Freshman")
        {
            shortLevel = "Fr."
        }
        
        if ((sport.lowercased() == "football") || (sport.lowercased() == "softball") || (sport.lowercased() == "baseball") || (sport.lowercased() == "field hockey"))
        {
            return shortLevel + " " + sport
        }
        else
        {
            return gender + " " + shortLevel + " " + sport
        }
    }
    
    // MARK: - Sport Images
    
    class func getImageForSport(_ sport: String) -> (UIImage)
    {
        var image : UIImage
        
        if (sport == "Bass Fishing")
        {
            image = UIImage(named: "BassFishing")!
        }
        else if (sport == "Cheer")
        {
            image = UIImage(named: "Cheer")!
        }
        else if (sport == "Dance Team")
        {
            image = UIImage(named: "Dance")!
        }
        else if (sport == "Drill")
        {
            image = UIImage(named: "Drill")!
        }
        else if (sport == "Poms")
        {
            image = UIImage(named: "Cheer")!
        }
        else if (sport == "Weight Lifting")
        {
            image = UIImage(named: "WeightLifting")!
        }
        else if (sport == "Wheelchair Sports")
        {
            image = UIImage(named: "Wheelchair")!
        }
        else if (sport == "Cross Country")
        {
            image = UIImage(named: "CrossCountry")!
        }
        else if (sport == "Gymnastics")
        {
            image = UIImage(named: "Gymnastics")!
        }
        else if (sport == "Indoor Track & Field")
        {
            image = UIImage(named: "IndoorTrackAndField")!
        }
        else if (sport == "Judo")
        {
            image = UIImage(named: "Judo")!
        }
        else if (sport == "Ski & Snowboard")
        {
            image = UIImage(named: "SkiAndSnowboarding")!
        }
        else if (sport == "Swimming")
        {
            image = UIImage(named: "Swimming")!
        }
        else if (sport == "Track & Field")
        {
            image = UIImage(named: "TrackAndField")!
        }
        else if (sport == "Wrestling")
        {
            image = UIImage(named: "Wrestling")!
        }
        else if (sport == "Archery")
        {
            image = UIImage(named: "Archery")!
        }
        else if (sport == "Badminton")
        {
            image = UIImage(named: "Badminton")!
        }
        else if (sport == "Baseball")
        {
            image = UIImage(named: "Baseball")!
        }
        else if (sport == "Basketball")
        {
            image = UIImage(named: "Basketball")!
        }
        else if (sport == "Bowling")
        {
            image = UIImage(named: "Bowling")!
        }
        else if (sport == "Canoe Paddling")
        {
            image = UIImage(named: "CanoePaddling")!
        }
        else if (sport == "Fencing")
        {
            image = UIImage(named: "Fencing")!
        }
        else if (sport == "Field Hockey")
        {
            image = UIImage(named: "FieldHockey")!
        }
        else if (sport == "Flag Football")
        {
            image = UIImage(named: "Football")!
        }
        else if (sport == "Football")
        {
            image = UIImage(named: "Football")!
        }
        else if (sport == "Ice Hockey")
        {
            image = UIImage(named: "IceHockey")!
        }
        else if (sport == "Lacrosse")
        {
            image = UIImage(named: "Lacrosse")!
        }
        else if (sport == "Riflery")
        {
            image = UIImage(named: "Riflery")!
        }
        else if (sport == "Rugby")
        {
            image = UIImage(named: "Rugby")!
        }
        else if (sport == "Slow Pitch Softball")
        {
            image = UIImage(named: "Softball")!
        }
        else if (sport == "Soccer")
        {
            image = UIImage(named: "Soccer")!
        }
        else if (sport == "Softball")
        {
            image = UIImage(named: "Softball")!
        }
        else if (sport == "Water Polo")
        {
            image = UIImage(named: "WaterPolo")!
        }
        else if (sport == "Golf")
        {
            image = UIImage(named: "Golf")!
        }
        else if (sport == "Sand Volleyball")
        {
            image = UIImage(named: "Volleyball")!
        }
        else if (sport == "Tennis")
        {
            image = UIImage(named: "Tennis")!
        }
        else if (sport == "Volleyball")
        {
            image = UIImage(named: "Volleyball")!
        }
        else if (sport == "Speech")
        {
            image = UIImage(named: "Speech")!
        }
        else
        {
            image = UIImage()
        }
        
        return image
    }
    
}
