//
//  OldFavoritesListView.swift
//  MPScoreboard3
//
//  Created by David Smith on 3/31/21.
//

import UIKit

protocol OldFavoritesListViewDelegate: AnyObject
{
    func closeFavoritesListView()
    func closeFavoritesListViewAfterChange()
}

class OldFavoritesListView: UIView, UITableViewDelegate, UITableViewDataSource
{
    weak var delegate: FavoritesListViewDelegate?
    
    var teamOrAthleteDeleted = false
    
    private var searchVC: SearchViewController?
    private var favoriteTeamsArray = [] as Array
    private var favoriteAthletesArray = [] as Array
    private var deleteItemIndex = 0
    
    private var favoritesTableView: UITableView?
    private var blackBackgroundView : UIView?
    private var roundRectView : UIView?
    private var roundRectHeaderContainer : UIView?
    private var headerTitleLabel : UILabel?
    private var headerSubtitleLabel : UILabel?
    private var headerMascotImageView : UIImageView?
    private var headerFirstLetterLabel : UILabel?
    
    private var editButton : UIButton?
    
    // MARK: - Get and Delete Favorite Athlete
    
    private func deleteFavoriteAthlete()
    {
        let favoriteToDelete = favoriteAthletesArray[deleteItemIndex] as! Dictionary<String, Any>
        let careerProfileIdToDelete = favoriteToDelete[kAthleteCareerProfileIdKey] as! String
            
        favoriteAthletesArray.remove(at: deleteItemIndex)
        
        kUserDefaults.set(favoriteAthletesArray, forKey: kUserFavoriteAthletesArrayKey)
        favoritesTableView?.reloadData()
        
        if ((favoriteAthletesArray.count == 0) && (favoriteTeamsArray.count == 0))
        {
            favoritesTableView?.isHidden = true
            roundRectHeaderContainer?.isHidden = true
        }
        
        if (kUserDefaults .string(forKey: kUserIdKey) != kTestDriveUserId)
        {
            self.deleteUserFavoriteAthleteFromDatabase(careerProfileId: careerProfileIdToDelete)
        }
    }
    
    private func deleteUserFavoriteAthleteFromDatabase(careerProfileId : String)
    {
        // Show the busy indicator
        DispatchQueue.main.async
        {
            MBProgressHUD.showAdded(to: self, animated: true)
        }
        
        NewFeeds.deleteUserFavoriteAthlete(careerProfileId) { (error) in
            
            if error == nil
            {
                self.teamOrAthleteDeleted = true
                
                // Get the favoriteAthletes from the database agsin
                self.getUserFavoriteAthletesFromDatabase()
                
                // Update the notifications database in Airship
                self.updateNotificationsDatabase()
            }
            else
            {
                // Hide the busy indicator
                DispatchQueue.main.async
                {
                    MBProgressHUD.hide(for: self, animated: true)
                }
                
                let window = UIApplication.shared.windows[0]
                
                MiscHelper.showAlert(in: window.rootViewController, withActionNames: ["Ok"], title: "MaxPreps App", message: "There was a problem deleting this favorite athlete.", lastItemCancelType: false) { (tag) in
                    
                }
            }
        }
    }
    
    private func getUserFavoriteAthletesFromDatabase()
    {
        NewFeeds.getUserFavoriteAthletes(completionHandler: { error in
            
            // Hide the busy indicator
            DispatchQueue.main.async
            {
                MBProgressHUD.hide(for: self, animated: true)
            }
            
            if error == nil
            {
                if let favAthletes = kUserDefaults.array(forKey: kUserFavoriteAthletesArrayKey)
                {
                    self.favoriteAthletesArray = favAthletes
                }
                self.favoritesTableView?.reloadData()
            }
            else
            {
                print("Download user favorite athletes error")
            }
        })
    }
    
    // MARK: - Get and Delete Favorite Team
    
    private func deleteFavoriteTeam()
    {
        let favoriteToDelete = favoriteTeamsArray[deleteItemIndex] as! Dictionary<String, Any>
        
        favoriteTeamsArray.remove(at: deleteItemIndex)
        
        kUserDefaults.set(favoriteTeamsArray, forKey: kNewUserFavoriteTeamsArrayKey)
        favoritesTableView?.reloadData()
        
        if ((favoriteAthletesArray.count == 0) && (favoriteTeamsArray.count == 0))
        {
            favoritesTableView?.isHidden = true
            roundRectHeaderContainer?.isHidden = true
        }
        
        if (kUserDefaults .string(forKey: kUserIdKey) != kTestDriveUserId)
        {
            self.deleteUserFavoriteTeamFromDatabase(team:favoriteToDelete)
        }
    }
    
    private func deleteUserFavoriteTeamFromDatabase(team : Dictionary<String, Any>)
    {
        // Show the busy indicator
        DispatchQueue.main.async
        {
            MBProgressHUD.showAdded(to: self, animated: true)
        }
        
        NewFeeds.deleteUserFavoriteTeam(favorite: team) { (error) in
            
            if error == nil
            {
                self.teamOrAthleteDeleted = true
                
                // Get the favoriteTeams from the database agsin
                self.getUserFavoriteTeamsFromDatabase()
                
                // Update the notifications database in Airship
                self.updateNotificationsDatabase()
            }
            else
            {
                // Hide the busy indicator
                DispatchQueue.main.async
                {
                    MBProgressHUD.hide(for: self, animated: true)
                }
                
                let window = UIApplication.shared.windows[0]
                
                MiscHelper.showAlert(in: window.rootViewController, withActionNames: ["Ok"], title: "MaxPreps App", message: "There was a problem deleting this favorite team.", lastItemCancelType: false) { (tag) in
                    
                }
            }
        }
    }
    
    private func getUserFavoriteTeamsFromDatabase()
    {
        NewFeeds.getUserFavoriteTeams(completionHandler: { error in
            
            // Hide the busy indicator
            DispatchQueue.main.async
            {
                MBProgressHUD.hide(for: self, animated: true)
            }
            
            if error == nil
            {
                if let favTeams = kUserDefaults.array(forKey: kNewUserFavoriteTeamsArrayKey)
                {
                    self.favoriteTeamsArray = favTeams
                }
                self.favoritesTableView?.reloadData()
            }
            else
            {
                print("Download user favorite teams error")
            }
        })
        
        // Update the locationTracking regions in the app delegate
        //[appDelegate addRegionsForTracking];
    }
    
    // MARK: - Update Notifications Database
    
    private func updateNotificationsDatabase()
    {
        // [notificationsManager updateNotificationChannelsFromFavorites:favoriteTeamsArray];
        
        /*
         BOOL successful = [[statusDictionary objectForKey:kRequestSuccessfulKey] boolValue];
         
         if (!successful)
             NSLog(@"%@",[statusDictionary objectForKey:kRequestUserMessageKey]);
         else
             [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshFavoritesEverywhere" object:nil userInfo:nil];
         
         notificationsManager = nil;
         */
    }
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (section == 0)
        {
            return favoriteTeamsArray.count
        }
        else
        {
            return favoriteAthletesArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let index = kUserDefaults.value(forKey: kSelectedFavoriteIndexKey) as! Int
        let section = kUserDefaults.value(forKey: kSelectedFavoriteSectionKey) as! Int
        
        // Hide the row of the selected team or athlete
        if (section == indexPath.section)
        {
            if (index == indexPath.row)
            {
                return 0
            }
            else
            {
                return 72.0
            }
        }
        else
        {
            return 72.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if (section == 0)
        {
            return 40.0
        }
        else
        {
            return 0.1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if (section == 0)
        {
            let label = UILabel(frame: CGRect(x: 20, y: 16, width: 200, height: 24))
            label.font = UIFont.mpBoldFontWith(size: 20)
            label.backgroundColor = UIColor.clear
            label.textColor = UIColor.mpBlackColor()
            label.text = "Following"
            
            /*
             // Add an edit button
             editButton = UIButton(frame: CGRect(x: tableView.frame.size.width - 68, y: 13, width: 50, height: 30))
             editButton!.backgroundColor = .clear
             editButton!.contentHorizontalAlignment = .right
             editButton!.setTitle("EDIT", for: .normal)
             editButton!.setTitleColor(.gray, for: .normal)
             editButton!.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 14)
             editButton!.addTarget(self, action: #selector(editButtonTouched), for: .touchUpInside)
             */
            let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
            view.backgroundColor = UIColor.mpWhiteColor()
            
            view.addSubview(label)
            //view.addSubview(editButton!)
            
            return view
        }
        else
        {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "TeamSelectorTableViewCell") as? TeamSelectorTableViewCell
        
        if (cell == nil)
        {
            let nib = Bundle.main.loadNibNamed("TeamSelectorTableViewCell", owner: self, options: nil)
            cell = nib![0] as? TeamSelectorTableViewCell
        }
        /*
        cell?.selectionStyle = .none
                
        if (indexPath.section == 0)
        {
            cell?.teamFirstLetterLabel.isHidden = false
            
            // Favorite teams section
            let favoriteTeam = favoriteTeamsArray[indexPath.row] as! Dictionary<String, Any>
            
            let name = favoriteTeam[kNewSchoolNameKey] as! String
            let initial = String(name.prefix(1))
            let gender = favoriteTeam[kNewGenderKey] as! String
            let sport = favoriteTeam[kNewSportKey] as! String
            let level = favoriteTeam[kNewLevelKey] as!String
            let schoolId = favoriteTeam[kNewSchoolIdKey] as!String
            let season = favoriteTeam[kNewSeasonKey] as! String
            let genderSportLevel = MiscHelper.genderSportLevelFrom(gender: gender, sport: sport, level: level)
            
            // Show the season for soccer
            if (sport == "Soccer")
            {
                cell?.subtitleLabel.text =  String(format: "%@ (%@)", genderSportLevel, season)
            }
            else
            {
                cell?.subtitleLabel.text =  genderSportLevel
            }
            
            cell?.titleLabel.text = name
            cell?.teamFirstLetterLabel.text = initial
            
            // Look for a mascot
            if let schoolsInfo = kUserDefaults.dictionary(forKey: kNewSchoolInfoDictionaryKey)
            {
                if let schoolInfo = schoolsInfo[schoolId] as? Dictionary<String, String>
                {
                    let mascotUrl = schoolInfo[kNewSchoolInfoMascotUrlKey]
                    let url = URL(string: mascotUrl!)

                    if (mascotUrl!.count > 0)
                    {
                        // Get the data and make an image
                        MiscHelper.getData(from: url!) { data, response, error in
                            guard let data = data, error == nil else { return }
                            //print("Download Finished")
                            DispatchQueue.main.async()
                            {
                                let image = UIImage(data: data)
                                
                                if (image != nil)
                                {
                                    let scaledWidth = cell?.teamMascotImageView.frame.size.height
                                    let scaledImage = ImageHelper.image(with: image, scaledTo: CGSize(width: scaledWidth!, height: scaledWidth!))
                                    
                                    cell?.teamFirstLetterLabel.isHidden = true
                                    
                                    // Clip the image to a round circle if the corners are not white or clear
                                    let cornerColor = image!.getColorIfCornersMatch()
                                    
                                    if (cornerColor != nil)
                                    {
                                        //print ("Corner Color match")

                                        var red: CGFloat = 0
                                        var green: CGFloat = 0
                                        var blue: CGFloat = 0
                                        var alpha: CGFloat = 0

                                        // Use the scaled image if the color is white or the alpha is zero
                                        cornerColor!.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                                        
                                        if (((red == 1) && (green == 1) && (blue == 1)) || (alpha == 0))
                                        {
                                            cell?.teamMascotImageView.image = scaledImage
                                        }
                                        else
                                        {
                                            let roundedImage = UIImage.maskRoundedImage(image: scaledImage!, radius: scaledWidth! / 2.0)
                                            cell?.teamMascotImageView.image = roundedImage
                                        }
                                    }
                                    else
                                    {
                                        print("Corner Color Mismatch")
                                        cell?.teamMascotImageView.image = scaledImage
                                    }
                                }
                                else
                                {
                                    // Set the first letter color
                                    let hexColorString = schoolInfo[kNewSchoolInfoColor1Key]!
                                    //let color = UIColor.init(hexString: hexColorString, alpha: 1)
                                    let color = ColorHelper.color(fromHexString: hexColorString)
                                    cell?.teamFirstLetterLabel.textColor = color
                                }
                            }
                        }
                    }
                    else
                    {
                        // Set the first letter color
                        let hexColorString = schoolInfo[kNewSchoolInfoColor1Key]!
                        //let color = UIColor.init(hexString: hexColorString, alpha: 1)
                        let color = ColorHelper.color(fromHexString: hexColorString)
                        cell?.teamFirstLetterLabel.textColor = color
                    }
                }
            }
        }
        else
        {
            // Favorite athletes section
            let favoriteAthlete = favoriteAthletesArray[indexPath.row] as! Dictionary<String, Any>

            let firstName = favoriteAthlete[kAthleteCareerProfileFirstNameKey] as! String
            let lastName = favoriteAthlete[kAthleteCareerProfileLastNameKey] as! String
            let schoolName = favoriteAthlete[kAthleteCareerProfileSchoolNameKey] as! String
            let initial = String(schoolName.prefix(1))
            let mascotUrlString = favoriteAthlete[kAthleteCareerProfileSchoolMascotUrlKey] as! String
            let colorString = favoriteAthlete[kAthleteCareerProfileSchoolColor1Key] as! String
            
            cell?.titleLabel.text = firstName + " " + lastName
            cell?.subtitleLabel.text = schoolName
            
            if (mascotUrlString.count > 0)
            {
                let url = URL(string: mascotUrlString)
                
                // Get the data and make an image
                MiscHelper.getData(from: url!) { data, response, error in
                    guard let data = data, error == nil else { return }
                    DispatchQueue.main.async()
                    {
                        let image = UIImage(data: data)
                        let scaledWidth = cell?.teamMascotImageView.frame.size.height
                        let scaledImage = ImageHelper.image(with: image, scaledTo: CGSize(width: scaledWidth!, height: scaledWidth!))
                        
                        cell?.teamFirstLetterLabel.isHidden = true
                        
                        // Clip the image to a round circle if the corners are not white or clear
                        let cornerColor = image!.getColorIfCornersMatch()
                        
                        if (cornerColor != nil)
                        {
                            //print ("Corner Color match")

                            var red: CGFloat = 0
                            var green: CGFloat = 0
                            var blue: CGFloat = 0
                            var alpha: CGFloat = 0

                            // Use the scaled image if the color is white or the alpha is zero
                            cornerColor!.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                            
                            if (((red == 1) && (green == 1) && (blue == 1)) || (alpha == 0))
                            {
                                cell?.teamMascotImageView.image = scaledImage
                            }
                            else
                            {
                                let roundedImage = UIImage.maskRoundedImage(image: scaledImage!, radius: scaledWidth! / 2.0)
                                cell?.teamMascotImageView.image = roundedImage
                            }
                        }
                        else
                        {
                            print("Corner Color Mismatch")
                            cell?.teamMascotImageView.image = scaledImage
                        }
                    }
                }
            }
            else
            {
                cell?.teamMascotImageView!.image = nil
                cell?.teamFirstLetterLabel.isHidden = false
                cell?.teamFirstLetterLabel.text = initial

                let color = ColorHelper.color(fromHexString: colorString)
                cell?.teamFirstLetterLabel.textColor = color
            }
        }
        */
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Set the new selectedIndex and selectedSection in prefs
        kUserDefaults.setValue(NSNumber(integerLiteral: indexPath.row), forKey: kSelectedFavoriteIndexKey)
        kUserDefaults.setValue(NSNumber(integerLiteral: indexPath.section), forKey: kSelectedFavoriteSectionKey)
        
        // Update the screen
        tableView.reloadData()
        self.updateHeaderContainer()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
        {
            // Animate the roundRectView and blackBackgroundView
            UIView.animate(withDuration: 0.16, animations:
                            {
                                self.roundRectView?.transform = CGAffineTransform(translationX: 0, y: (self.roundRectView?.frame.size.height)!)
                                self.blackBackgroundView?.alpha = 0.0
                            })
            { (finished) in
                
                self.delegate?.closeFavoritesListViewAfterChange()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle
    {
        let userId = kUserDefaults.value(forKey: kUserIdKey) as! String
        
        if (userId != kTestDriveUserId)
        {
            return .delete
        }
        else
        {
            return .none
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        if (favoriteTeamsArray.count > 0)
        {
            let index = kUserDefaults.value(forKey: kSelectedFavoriteIndexKey) as! Int
            
            if (indexPath.row == index)
            {
                return false
                
            }
            else
            {
                return true
            }
        }
        else
        {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if (editingStyle == .delete)
        {
            deleteItemIndex = indexPath.row
            
            var title = ""
            
            if (indexPath.section == 0)
            {
                let favoriteTeam = favoriteTeamsArray[indexPath.row] as! Dictionary<String, Any>
                let schoolName = favoriteTeam[kNewSchoolNameKey] as! String
                
                if (schoolName.count < 12)
                {
                    title = "Remove " + schoolName + "?"
                }
                else
                {
                    title = "Remove the selected team?"
                }
                
                let window = UIApplication.shared.windows[0]
                
                MiscHelper.showAlert(in: window.rootViewController, withActionNames: ["Remove", "Cancel"], title: title, message: "You will no longer receive news and scores for this team.", lastItemCancelType: true) { (tag) in
                    if (tag == 0)
                    {
                        self.deleteFavoriteTeam()
                    }
                    else
                    {
                        tableView.setEditing(false, animated: true)
                    }
                }
            }
            else
            {
                let favoriteAthlete = favoriteAthletesArray[indexPath.row] as! Dictionary<String, Any>

                let firstName = favoriteAthlete[kAthleteCareerProfileFirstNameKey] as! String
                let lastName = favoriteAthlete[kAthleteCareerProfileLastNameKey] as! String
                let initial = String(lastName.prefix(1))
                
                if (firstName.count < 12)
                {
                    title = "Remove " + firstName + " " + initial + "?"
                }
                else
                {
                    title = "Remove the selected athlete?"
                }
                
                let window = UIApplication.shared.windows[0]
                
                MiscHelper.showAlert(in: window.rootViewController, withActionNames: ["Remove", "Cancel"], title: title, message: "You will no longer receive updates for this athlete.", lastItemCancelType: true) { (tag) in
                    if (tag == 0)
                    {
                        self.deleteFavoriteAthlete()
                    }
                    else
                    {
                        tableView.setEditing(false, animated: true)
                    }
                }
            }
        }
    }
    
    // MARK: - Button Method
    
    @objc private func editButtonTouched()
    {
        if (favoritesTableView?.isEditing == true)
        {
            favoritesTableView?.setEditing(false, animated: true)
            editButton!.setTitle("EDIT", for: .normal)
        }
        else
        {
            favoritesTableView?.setEditing(true, animated: true)
            editButton!.setTitle("DONE", for: .normal)
        }
        
    }
    
    // MARK: - Gesture Method
    
    @objc func handleTap(sender: UITapGestureRecognizer)
    {
        // Animate the roundRectView and blackBackgroundView
        UIView.animate(withDuration: 0.16, animations:
                        {
                            self.roundRectView?.transform = CGAffineTransform(translationX: 0, y: (self.roundRectView?.frame.size.height)!)
                            self.blackBackgroundView?.alpha = 0.0
                        })
        { (finished) in
            
            self.delegate?.closeFavoritesListView()
        }
    }
    
    // MARK: - Update Header Container
    
    private func updateHeaderContainer()
    {
        let index = kUserDefaults.value(forKey: kSelectedFavoriteIndexKey) as! Int
        let section = kUserDefaults.value(forKey: kSelectedFavoriteSectionKey) as! Int
        
        if (section == 0)
        {
            // Favorite team is selected
            let favoriteTeam = favoriteTeamsArray[index] as! Dictionary<String, Any>
            
            let name = favoriteTeam[kNewSchoolNameKey] as! String
            let initial = String(name.prefix(1))
            let gender = favoriteTeam[kNewGenderKey] as! String
            let sport = favoriteTeam[kNewSportKey] as! String
            let level = favoriteTeam[kNewLevelKey] as!String
            let schoolId = favoriteTeam[kNewSchoolIdKey] as!String
            let season = favoriteTeam[kNewSeasonKey] as! String
            let genderSportLevel = MiscHelper.genderSportLevelFrom(gender: gender, sport: sport, level: level)
            
            // Show the season for soccer
            if (sport == "Soccer")
            {
                headerSubtitleLabel!.text =  String(format: "%@ (%@)", genderSportLevel, season)
            }
            else
            {
                headerSubtitleLabel!.text =  genderSportLevel
            }
            
            headerTitleLabel!.text = name
            headerFirstLetterLabel!.text = initial
            
            // Look for a mascot
            if let schoolsInfo = kUserDefaults.dictionary(forKey: kNewSchoolInfoDictionaryKey)
            {
                if let schoolInfo = schoolsInfo[schoolId] as? Dictionary<String, String>
                {
                    let mascotUrl = schoolInfo[kNewSchoolInfoMascotUrlKey]
                    let url = URL(string: mascotUrl!)

                    if (mascotUrl!.count > 0)
                    {
                        // Get the data and make an image
                        MiscHelper.getData(from: url!) { data, response, error in
                            guard let data = data, error == nil else { return }
                            //print("Download Finished")
                            DispatchQueue.main.async()
                            {
                                let image = UIImage(data: data)
                                let scaledWidth = self.headerMascotImageView!.frame.size.height
                                let scaledImage = ImageHelper.image(with: image, scaledTo: CGSize(width: scaledWidth, height: scaledWidth))
                                
                                self.headerFirstLetterLabel!.isHidden = true
                                
                                // Clip the image to a round circle if the corners are not white or clear
                                let cornerColor = image!.getColorIfCornersMatch()
                                
                                if (cornerColor != nil)
                                {
                                    //print ("Corner Color match")

                                    var red: CGFloat = 0
                                    var green: CGFloat = 0
                                    var blue: CGFloat = 0
                                    var alpha: CGFloat = 0

                                    // Use the scaled image if the color is white or the alpha is zero
                                    cornerColor!.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                                    
                                    if (((red == 1) && (green == 1) && (blue == 1)) || (alpha == 0))
                                    {
                                        self.headerMascotImageView!.image = scaledImage
                                    }
                                    else
                                    {
                                        let roundedImage = UIImage.maskRoundedImage(image: scaledImage!, radius: scaledWidth / 2.0)
                                        self.headerMascotImageView!.image = roundedImage
                                    }
                                }
                                else
                                {
                                    print("Corner Color Mismatch")
                                    self.headerMascotImageView!.image = scaledImage
                                }
                            }
                        }
                    }
                    else
                    {
                        // Set the first letter color
                        let hexColorString = schoolInfo[kNewSchoolInfoColor1Key]!
                        let color = ColorHelper.color(fromHexString: hexColorString)
                        headerFirstLetterLabel!.textColor = color
                    }
                }
            }
        }
        else
        {
            // Favorite Athlete is selected
            let favoriteAthlete = favoriteAthletesArray[index] as! Dictionary<String, Any>

            let firstName = favoriteAthlete[kAthleteCareerProfileFirstNameKey] as! String
            let lastName = favoriteAthlete[kAthleteCareerProfileLastNameKey] as! String
            let schoolName = favoriteAthlete[kAthleteCareerProfileSchoolNameKey] as! String
            let initial = String(schoolName.prefix(1))
            let mascotUrlString = favoriteAthlete[kAthleteCareerProfileSchoolMascotUrlKey] as! String
            let colorString = favoriteAthlete[kAthleteCareerProfileSchoolColor1Key] as! String
                        
            headerTitleLabel!.text = firstName + " " + lastName
            headerFirstLetterLabel!.text = ""
            headerSubtitleLabel!.text = schoolName
            
            if (mascotUrlString.count > 0)
            {
                let url = URL(string: mascotUrlString)
                
                // Get the data and make an image
                MiscHelper.getData(from: url!) { data, response, error in
                    guard let data = data, error == nil else { return }
                    DispatchQueue.main.async()
                    {
                        let image = UIImage(data: data)
                        let scaledWidth = self.headerMascotImageView!.frame.size.height
                        let scaledImage = ImageHelper.image(with: image, scaledTo: CGSize(width: scaledWidth, height: scaledWidth))
                        
                        self.headerFirstLetterLabel!.isHidden = true
                        
                        // Clip the image to a round circle if the corners are not white or clear
                        let cornerColor = image!.getColorIfCornersMatch()
                        
                        if (cornerColor != nil)
                        {
                            //print ("Corner Color match")

                            var red: CGFloat = 0
                            var green: CGFloat = 0
                            var blue: CGFloat = 0
                            var alpha: CGFloat = 0

                            // Use the scaled image if the color is white or the alpha is zero
                            cornerColor!.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                            
                            if (((red == 1) && (green == 1) && (blue == 1)) || (alpha == 0))
                            {
                                self.headerMascotImageView!.image = scaledImage
                            }
                            else
                            {
                                let roundedImage = UIImage.maskRoundedImage(image: scaledImage!, radius: scaledWidth / 2.0)
                                self.headerMascotImageView!.image = roundedImage
                            }
                        }
                        else
                        {
                            print("Corner Color Mismatch")
                            self.headerMascotImageView!.image = scaledImage
                        }
                    }
                }
            }
            else
            {
                headerMascotImageView!.image = nil
                headerFirstLetterLabel!.isHidden = false
                headerFirstLetterLabel!.text = initial

                let color = ColorHelper.color(fromHexString: colorString)
                headerFirstLetterLabel!.textColor = color
            }
        }
    }
    
    // MARK: - Init Method
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        
        blackBackgroundView = UIView(frame: frame)
        blackBackgroundView?.backgroundColor = UIColor.mpBlackColor()
        blackBackgroundView?.alpha = 0.0
        self.addSubview(blackBackgroundView!)
        
        // Add a tap gesture recognizer to the two subviews
        let topTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        blackBackgroundView?.addGestureRecognizer(topTapGesture)
        
        roundRectView = UIView(frame: CGRect(x: 0, y: 200, width: kDeviceWidth, height: kDeviceHeight - 200))
        roundRectView?.backgroundColor = UIColor.mpWhiteColor()
        roundRectView?.layer.cornerRadius = 12
        roundRectView?.clipsToBounds = true
        
        roundRectView?.transform = CGAffineTransform(translationX: 0, y: (roundRectView?.frame.size.height)!)
        self.addSubview(roundRectView!)
        
        // Add a no favorites label
        let noFavoritesLabel = UILabel(frame: CGRect(x: 16, y: 16, width: kDeviceWidth - 32, height: 20))
        noFavoritesLabel.textColor = UIColor.mpGrayColor()
        noFavoritesLabel.font = UIFont.mpRegularFontWith(size: 17)
        noFavoritesLabel.text = "No Favorites"
        roundRectView?.addSubview(noFavoritesLabel)
        
        
        // Add a header container
        roundRectHeaderContainer = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 80))
        roundRectHeaderContainer?.backgroundColor = UIColor.mpWhiteColor()
        roundRectView?.addSubview(roundRectHeaderContainer!)
        
        let headerTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        roundRectHeaderContainer?.addGestureRecognizer(headerTapGesture)
        
        // Add the header contents
        headerTitleLabel = UILabel(frame: CGRect(x: 76, y: 19, width: (roundRectHeaderContainer?.frame.size.width)! - 96 - 22, height: 21))
        headerTitleLabel?.font = UIFont.mpSemiBoldFontWith(size: 17)
        headerTitleLabel?.textColor = UIColor.mpBlackColor()
        roundRectHeaderContainer?.addSubview(headerTitleLabel!)
        
        headerSubtitleLabel = UILabel(frame: CGRect(x: 76, y: 44, width: (roundRectHeaderContainer?.frame.size.width)! - 96 - 22, height: 17))
        headerSubtitleLabel?.font = UIFont.mpRegularFontWith(size: 14)
        headerSubtitleLabel?.textColor = UIColor.mpGrayColor()
        roundRectHeaderContainer?.addSubview(headerSubtitleLabel!)
        
        headerFirstLetterLabel = UILabel(frame: CGRect(x: 20, y: 18, width: 44, height: 44))
        headerFirstLetterLabel?.font = .mpSemiBoldFontWith(size: 34)
        headerFirstLetterLabel?.textAlignment = .center
        roundRectHeaderContainer?.addSubview(headerFirstLetterLabel!)
        
        headerMascotImageView = UIImageView(frame: CGRect(x: 20, y: 18, width: 44, height: 44))
        roundRectHeaderContainer?.addSubview(headerMascotImageView!)
        
        let greenCheckmark = UILabel(frame: CGRect(x: (roundRectHeaderContainer?.frame.size.width)! - 42, y: 29, width: 22, height: 22))
        greenCheckmark.backgroundColor = UIColor.mpGreenColor()
        greenCheckmark.textColor = UIColor.mpWhiteColor()
        greenCheckmark.textAlignment = .center
        greenCheckmark.text = "✓"
        greenCheckmark.font = .boldSystemFont(ofSize: 15)
        greenCheckmark.layer.cornerRadius = 11
        greenCheckmark.clipsToBounds = true
        roundRectHeaderContainer?.addSubview(greenCheckmark)
        
        // Add the tableView
        favoritesTableView = UITableView(frame: CGRect(x: 0, y: 80, width: kDeviceWidth, height: (roundRectView?.frame.size.height)! - 80 - CGFloat(SharedData.bottomSafeAreaHeight)), style: .grouped)
        favoritesTableView?.delegate = self
        favoritesTableView?.dataSource = self
        favoritesTableView?.separatorStyle = .none
        favoritesTableView?.backgroundColor = UIColor.mpWhiteColor()
        roundRectView?.addSubview(favoritesTableView!)
        
        // Animate the roundRectView and blackBackgroundView
        UIView.animate(withDuration: 0.25, animations:
                        {
                            self.roundRectView?.transform = CGAffineTransform(translationX: 0, y: 0)
                            self.blackBackgroundView?.alpha = 0.7
                        })
        { (finished) in
            
            
        }
        
        if let favTeams = kUserDefaults.array(forKey: kNewUserFavoriteTeamsArrayKey)
        {
            favoriteTeamsArray = favTeams
        }
        
        if let favAthletes = kUserDefaults.array(forKey: kUserFavoriteAthletesArrayKey)
        {
            favoriteAthletesArray = favAthletes
        }
        
        // Hide the tableView and header if no favorites
        if (favoriteTeamsArray.count == 0) && (favoriteAthletesArray.count == 0)
        {
            favoritesTableView?.isHidden = true
            roundRectHeaderContainer?.isHidden = true
        }
        
        self.updateHeaderContainer()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }

}
