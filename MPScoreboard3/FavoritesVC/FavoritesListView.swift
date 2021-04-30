//
//  FavoritesListView.swift
//  MPScoreboard3
//
//  Created by David Smith on 3/31/21.
//

import UIKit

protocol FavoritesListViewDelegate: AnyObject
{
    func closeFavoritesListView()
    func closeFavoritesListViewAfterChange()
}

class FavoritesListView: UIView, UITableViewDelegate, UITableViewDataSource
{
    weak var delegate: FavoritesListViewDelegate?
    
    var teamOrAthleteDeleted = false
    
    private var searchVC: SearchViewController?
    private var favoriteTeamsArray = [] as Array
    private var favoriteAthletesArray = [] as Array
    private var deleteItemIndex = 0
    private let kCellHeight = 60
    
    private var favoritesTableView: UITableView?
    private var blackBackgroundView : UIView?
    private var roundRectView : UIView?
    private var roundRectHeaderContainer : UIView?
    //private var headerTitleLabel : UILabel?
    //private var headerSubtitleLabel : UILabel?
    //private var headerMascotImageView : UIImageView?
    //private var headerFirstLetterLabel : UILabel?
    
    private var editButton : UIButton?
    
    var initialCenter = CGPoint()  // The initial center point of the roundRectView for the pan geture.
    
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
        return CGFloat(kCellHeight)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        /*
        if (section == 0)
        {
            return 50.0
        }
        else
        {
            return 0.1
        }
        */
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        return nil
        /*
        if (section == 0)
        {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
            view.backgroundColor = UIColor.mpWhiteColor()
            
            let label = UILabel(frame: CGRect(x: 20, y: 16, width: 200, height: 24))
            label.font = UIFont.mpExtraBoldFontWith(size: 20)
            label.backgroundColor = UIColor.clear
            label.textColor = UIColor.mpBlackColor()
            label.text = "Following"
            view.addSubview(label)
            
            // Add a close button
            let closeButton = UIButton(frame: CGRect(x: (tableView.frame.size.width - 60) / 2.0, y: 6, width: 60, height: 30))
            closeButton.backgroundColor = .clear
            closeButton.addTarget(self, action: #selector(closeButtonTouched), for: .touchUpInside)
            view.addSubview(closeButton)
            
            let closeButtonHorizLine = UIView(frame: CGRect(x: 0, y: 0, width: closeButton.frame.size.width, height: 6))
            closeButtonHorizLine.backgroundColor = UIColor.mpGrayColor()
            closeButtonHorizLine.layer.cornerRadius = 3
            closeButtonHorizLine.clipsToBounds = true
            closeButton.addSubview(closeButtonHorizLine)
            
            // Add an edit button
            editButton = UIButton(frame: CGRect(x: tableView.frame.size.width - 68, y: 13, width: 50, height: 30))
            editButton!.backgroundColor = .clear
            editButton!.contentHorizontalAlignment = .right
            editButton!.setTitle("EDIT", for: .normal)
            editButton!.setTitleColor(UIColor.mpGrayColor(), for: .normal)
            editButton!.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 14)
            editButton!.addTarget(self, action: #selector(editButtonTouched), for: .touchUpInside)
            view.addSubview(editButton!)
            
            return view
        }
        else
        {
            return nil
        }
        */
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: "ShortFavoriteTeamTableViewCell") as? ShortFavoriteTeamTableViewCell
        
        if (cell == nil)
        {
            let nib = Bundle.main.loadNibNamed("ShortFavoriteTeamTableViewCell", owner: self, options: nil)
            cell = nib![0] as? ShortFavoriteTeamTableViewCell
        }
        
        cell?.selectionStyle = .none
        cell?.adminContainerView.isHidden = true
        cell?.memberContainerView.isHidden = true
        
        // Remove the contentView subviews with tags >= 100
        // Remove the star image
        for view in cell!.contentView.subviews
        {
            if (view.tag >= 100)
            {
                view.removeFromSuperview()
            }
        }
                
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
            let allSeasonId = favoriteTeam[kNewAllSeasonIdKey] as!String
            //let season = favoriteTeam[kNewSeasonKey] as! String
            let genderSportLevel = MiscHelper.genderSportLevelFrom(gender: gender, sport: sport, level: level)
            
            // Show the season for soccer
            //if (sport == "Soccer")
            //{
                //cell?.subtitleLabel.text =  String(format: "%@ (%@)", genderSportLevel, season)
            //}
            //else
            //{
                cell?.subtitleLabel.text =  genderSportLevel
            //}
            
            cell?.titleLabel.text = name
            cell?.teamFirstLetterLabel.text = initial
            
            // Look at the roles dictionary for a match if a logged in user
            let userId = kUserDefaults.string(forKey: kUserIdKey)
            
            if (userId != kTestDriveUserId)
            {
                let adminRoles = kUserDefaults.dictionary(forKey: kUserAdminRolesDictionaryKey)
                let roleKey = schoolId + "_" + allSeasonId
                
                if (adminRoles![roleKey] != nil)
                {
                    let adminRole = adminRoles![roleKey] as! Dictionary<String,String>
                    let roleName = adminRole[kRoleNameKey]
                    
                    if ((roleName == "Head Coach") || (roleName == "Assistant Coach") || (roleName == "Statistician"))
                    {
                        cell?.adminContainerView.isHidden = false
                    }
                    else if (roleName == "Team Community")
                    {
                        cell?.memberContainerView.isHidden = false
                    }
                }
                
                // Add a join button if adminContainer and memberContainer are hidded
                if ((cell?.adminContainerView.isHidden == true) && (cell?.memberContainerView.isHidden == true))
                {
                    let joinButton = UIButton(type: .custom)
                    joinButton.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
                    joinButton.frame = CGRect(x: tableView.frame.size.width - 100.0, y: 18, width: 70, height: 30)
                    joinButton.setTitle("JOIN", for: .normal)
                    joinButton.setTitleColor(UIColor.mpGrayColor(), for: .normal)
                    joinButton.contentHorizontalAlignment = .right
                    joinButton.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 12)
                    joinButton.tag = indexPath.row + 100
                    joinButton.setImage(UIImage(named: "SmallRedStar"), for: .normal)
                    joinButton.imageEdgeInsets = UIEdgeInsets(top: -1, left: -3, bottom: 1, right: 3)
                    joinButton.addTarget(self, action: #selector(joinButtonTouched), for: .touchUpInside)
                    cell?.contentView.addSubview(joinButton)
                }
            }
            
            
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
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        /*
        // Set the new selectedIndex and selectedSection in prefs
        kUserDefaults.setValue(NSNumber(integerLiteral: indexPath.row), forKey: kSelectedFavoriteIndexKey)
        kUserDefaults.setValue(NSNumber(integerLiteral: indexPath.section), forKey: kSelectedFavoriteSectionKey)
        
        // Update the screen
        tableView.reloadData()
        //self.updateHeaderContainer()
        
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
         */
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
        if (indexPath.section == 0)
        {
            if (favoriteTeamsArray.count > 0)
            {
                return true
            }
            else
            {
                return false
            }
        }
        else
        {
            if (favoriteAthletesArray.count > 0)
            {
                return true
            }
            else
            {
                return false
            }
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
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        
        if (userId == kTestDriveUserId)
        {
            let window = UIApplication.shared.windows[0]
            
            MiscHelper.showAlert(in: window.rootViewController, withActionNames: ["Ok"], title: "Membership Required", message: "Membership is required to edit teams.", lastItemCancelType: false) { tag in
                
            }
            return
        }
        
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
    
    @objc private func closeButtonTouched()
    {
        // Animate the roundRectView and blackBackgroundView
        UIView.animate(withDuration: 0.24, animations:
                        {
                            self.roundRectView?.transform = CGAffineTransform(translationX: 0, y: (self.roundRectView?.frame.size.height)!)
                            self.blackBackgroundView?.alpha = 0.0
                        })
        { (finished) in
            
            self.delegate?.closeFavoritesListView()
        }
    }
    
    @objc private func joinButtonTouched(_ button : UIButton)
    {
        //let index = button.tag
        
        let window = UIApplication.shared.windows[0]
        
        MiscHelper.showAlert(in: window.rootViewController, withActionNames: ["Ok"], title: "Coming Soon...", message: "This will open the team onboarding flow.", lastItemCancelType: false) { (tag) in
            
        }
    }
    
    // MARK: - Gesture Methods
    
    @objc func handleTap(sender: UITapGestureRecognizer)
    {
        // Animate the roundRectView and blackBackgroundView
        UIView.animate(withDuration: 0.24, animations:
                        {
                            self.roundRectView?.transform = CGAffineTransform(translationX: 0, y: (self.roundRectView?.frame.size.height)!)
                            self.blackBackgroundView?.alpha = 0.0
                        })
        { (finished) in
            
            self.delegate?.closeFavoritesListView()
        }
    }
    
    @objc func handlePan(panGestureRecognizer: UIPanGestureRecognizer)
    {
        guard panGestureRecognizer.view != nil else {return}
        
        let piece = panGestureRecognizer.view!
        // Get the changes in the X and Y directions relative to
        // the superview's coordinate space.
        let translation = panGestureRecognizer.translation(in: piece.superview)
        
        if panGestureRecognizer.state == .began
        {
            // Save the view's original position.
            self.initialCenter = roundRectView!.center
        }
        // Update the position for the .began, .changed, and .ended states
        if (panGestureRecognizer.state == .began) || (panGestureRecognizer.state == .changed)
        {
            // Add the X and Y translation to the view's original position.
            let newCenter = CGPoint(x: initialCenter.x, y: initialCenter.y + translation.y)
            //print("InitialCenter: " +  String(Int(initialCenter.y)) + ", NewCenter: " + String(Int(newCenter.y)))
            
            if (newCenter.y > initialCenter.y)
            {
                roundRectView!.center = newCenter
            }
            else
            {
                roundRectView!.center = initialCenter
            }
        }
        else if (panGestureRecognizer.state == .ended)
        {
            let newCenter = CGPoint(x: initialCenter.x, y: initialCenter.y + translation.y)

            if ((newCenter.y - initialCenter.y) < ((roundRectView?.frame.size.height)! / 2))
            {
                //roundRectView!.center = initialCenter
                // Animate the roundRectView back to it's starting position
                UIView.animate(withDuration: 0.24, animations:
                                { [self] in
                                    self.roundRectView?.center = initialCenter
                                    
                                })
                { (finished) in
                    
                }
            }
            else
            {
                // Animate the roundRectView and blackBackgroundView
                UIView.animate(withDuration: 0.24, animations:
                                {
                                    self.roundRectView?.transform = CGAffineTransform(translationX: 0, y: (self.roundRectView?.frame.size.height)!)
                                    self.blackBackgroundView?.alpha = 0.0
                                })
                { (finished) in
                    
                    self.delegate?.closeFavoritesListView()
                }
            }
            
 
        }
        else
        {
            // On cancellation, return the piece to its original location.
            roundRectView!.center = initialCenter
        }
    }
    /*
    
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
    */
    // MARK: - Init Method
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        if let favTeams = kUserDefaults.array(forKey: kNewUserFavoriteTeamsArrayKey)
        {
            favoriteTeamsArray = favTeams
        }
        
        if let favAthletes = kUserDefaults.array(forKey: kUserFavoriteAthletesArrayKey)
        {
            favoriteAthletesArray = favAthletes
        }
        
        self.backgroundColor = .clear
        
        blackBackgroundView = UIView(frame: frame)
        blackBackgroundView?.backgroundColor = UIColor.mpBlackColor()
        blackBackgroundView?.alpha = 0.0
        self.addSubview(blackBackgroundView!)
        
        // Add a tap gesture recognizer to the blackBackgroundView
        let topTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        blackBackgroundView?.addGestureRecognizer(topTapGesture)
        
        // Calculate the height of the roundRectView to match the table content if it is less than the available height
        let headerViewHeight = 60
        let maxRoundRectViewHeight = Int(kDeviceHeight) - 56 - kStatusBarHeight - SharedData.topNotchHeight
        let totalCellCount = favoriteTeamsArray.count + favoriteAthletesArray.count
        let tableHeight = totalCellCount * kCellHeight
        var roundRectViewHeight = 0
        
        if (tableHeight + headerViewHeight + SharedData.bottomSafeAreaHeight) >= maxRoundRectViewHeight
        {
            roundRectViewHeight = maxRoundRectViewHeight
        }
        else
        {
            roundRectViewHeight = tableHeight + headerViewHeight + SharedData.bottomSafeAreaHeight
        }
        
        roundRectView = UIView(frame: CGRect(x: 0, y: Int(kDeviceHeight) - roundRectViewHeight, width: Int(kDeviceWidth), height: roundRectViewHeight))
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
        roundRectHeaderContainer = UIView(frame: CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: headerViewHeight))
        roundRectHeaderContainer!.backgroundColor = UIColor.mpWhiteColor()
        
        // Add a pan gesture recognizer to the two subviews
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(panGestureRecognizer:)))
        roundRectHeaderContainer!.addGestureRecognizer(panGesture)
        
        let titleLabel = UILabel(frame: CGRect(x: 20, y: 21, width: 200, height: 24))
        titleLabel.font = UIFont.mpExtraBoldFontWith(size: 24)
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = UIColor.mpBlackColor()
        titleLabel.text = "Following"
        roundRectHeaderContainer!.addSubview(titleLabel)
        
        // Add a close button
        //let closeButton = UIButton(frame: CGRect(x: (kDeviceWidth - 60) / 2.0, y: 6, width: 60, height: 30))
        //closeButton.backgroundColor = .clear
        //closeButton.addTarget(self, action: #selector(closeButtonTouched), for: .touchUpInside)
        //headerView.addSubview(closeButton)
        
        let closeButtonHorizLine = UIView(frame: CGRect(x: (kDeviceWidth - 60) / 2.0, y: 6, width: 60, height: 6))
        closeButtonHorizLine.backgroundColor = UIColor.mpGrayColor()
        closeButtonHorizLine.layer.cornerRadius = 3
        closeButtonHorizLine.clipsToBounds = true
        roundRectHeaderContainer!.addSubview(closeButtonHorizLine)
        
        // Add an edit button
        editButton = UIButton(frame: CGRect(x: kDeviceWidth - 68, y: 18, width: 50, height: 30))
        editButton!.backgroundColor = .clear
        editButton!.contentHorizontalAlignment = .right
        editButton!.setTitle("EDIT", for: .normal)
        editButton!.setTitleColor(UIColor.mpGrayColor(), for: .normal)
        editButton!.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 14)
        editButton!.addTarget(self, action: #selector(editButtonTouched), for: .touchUpInside)
        roundRectHeaderContainer!.addSubview(editButton!)
        
        roundRectView?.addSubview(roundRectHeaderContainer!)
        
        /*
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
        */
        
        // Add the tableView
        favoritesTableView = UITableView(frame: CGRect(x: 0, y: roundRectHeaderContainer!.frame.size.height, width: kDeviceWidth, height: (roundRectView?.frame.size.height)! - roundRectHeaderContainer!.frame.size.height - CGFloat(SharedData.bottomSafeAreaHeight)), style: .plain)
        favoritesTableView?.delegate = self
        favoritesTableView?.dataSource = self
        favoritesTableView?.separatorStyle = .none
        favoritesTableView?.backgroundColor = UIColor.mpWhiteColor()
        roundRectView?.addSubview(favoritesTableView!)
        
        // Animate the roundRectView and blackBackgroundView
        UIView.animate(withDuration: 0.24, animations:
                        {
                            self.roundRectView?.transform = CGAffineTransform(translationX: 0, y: 0)
                            self.blackBackgroundView?.alpha = 0.7
                        })
        { (finished) in
            
            
        }
        
        
        // Hide the tableView and header if no favorites
        if (favoriteTeamsArray.count == 0) && (favoriteAthletesArray.count == 0)
        {
            favoritesTableView?.isHidden = true
            roundRectHeaderContainer?.isHidden = true
        }
        
        //self.updateHeaderContainer()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }

}
