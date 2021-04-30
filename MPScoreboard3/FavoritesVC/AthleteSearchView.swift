//
//  AthleteSearchView.swift
//  MPScoreboard3
//
//  Created by David Smith on 4/29/21.
//

import UIKit

class AthleteSearchView: UIView, IQActionSheetPickerViewDelegate, UITextFieldDelegate
{
    private var sportContainerView: UIView?
    private var sportPlaceholderLabel: UILabel?
    private var downArrowImageView: UIImageView?
    private var sportLabel: UILabel?
    private var sportIconImageView: UIImageView?
    private var selectSportButton: UIButton?
    
    private var searchContainerView: UIView?
    private var searchTextField: UITextField?
    private var searchIconImageView: UIImageView?
    
    private var searchTableView: UITableView!
    private var filterButton: UIButton!
    
    private var allAthletesArray = Array<Dictionary<String,Any>>()
    private var filteredAthletesArray = Array<Dictionary<String,Any>>()
    private var favoriteAthletesIdentifierArray = [] as Array
    
    // MARK: - Filter Athletes
    
    private func filterAthletes()
    {
        filteredAthletesArray.removeAll()
        
        /*
        // All States case
        if (filterButton.titleLabel?.text == String(format: kDefaultFilterButtonTitle, kDefaultFilterState))
        {
            filteredAthletesArray = allAthletesArray
            searchTableView.reloadData()
        }
        else
        {
            //
            for athlete in allAthletesArray
            {
                let state = athlete["schoolState"] as! String
                let stateWithFormattedName = String(format: kDefaultFilterButtonTitle, state)
                
                if (filterButton.titleLabel?.text == stateWithFormattedName)
                {
                    filteredAthletesArray.append(athlete)
                }
            }
            
            searchTableView.reloadData()
        }
        */
    }
    
    // MARK: - Search for Athlete
    
    private func searchForAthlete()
    {
        self.allAthletesArray = []
        self.searchTableView.reloadData()
        
        // Show the busy indicator
        MBProgressHUD.showAdded(to: self, animated: true)
        
        let sportArray = sportLabel!.text!.split(separator: " ", maxSplits: 1)
        
        if (sportArray.count == 2)
        {
            let gender = String(sportArray.first!)
            let sport = String(sportArray.last!)
            
            NewFeeds.searchForAthlete(searchTextField!.text!, gender, sport) { (athletes, error) in
                
                // Hide the busy indicator
                DispatchQueue.main.async
                {
                    MBProgressHUD.hide(for: self, animated: true)
                }
                
                if (error == nil)
                {
                    print("Search Done")
                    
                    if (athletes!.count == 0)
                    {
                        // Show an Alert
                        let window = UIApplication.shared.windows[0]
                        
                        MiscHelper.showAlert(in: window.rootViewController, withActionNames: ["Ok"], title: "Search Result", message: "No matches were found for that sport.", lastItemCancelType: false) { (tag) in
                            
                        }
                    }
                    else
                    {
                        self.allAthletesArray = athletes!
                        
                        // Filter the athletes
                        self.filterAthletes()
                    }
                }
                else
                {
                    let window = UIApplication.shared.windows[0]
                    
                    MiscHelper.showAlert(in: window.rootViewController, withActionNames: ["Ok"], title: "Error", message: "The search returned a server error", lastItemCancelType: false) { (tag) in
                        
                    }
                }
            }
        }
        
    }
    
    // MARK: TextField Delegates
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()

        if (searchTextField!.text!.count == 0)
        {
            let window = UIApplication.shared.windows[0]
            
            MiscHelper.showAlert(in: window.rootViewController, withActionNames: ["Ok"], title: "Missing Info", message: "You must enter the name of the athlete.", lastItemCancelType: false) { (tag) in
                
            }
        }
        else
        {
            self.searchForAthlete()
        }

        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool
    {
        return true
    }

    // MARK: - IQActionPickerView Delegate
    
    func actionSheetPickerView(_ pickerView: IQActionSheetPickerView, didSelectTitles titles: [String])
    {
        
        let title = titles.first
        
        if (pickerView.tag == 100)
        {
            // Skip if the sport didn't change
            if (sportLabel?.text == title)
            {
                return
            }
            
            sportPlaceholderLabel?.isHidden = true
            downArrowImageView?.isHidden = true
            sportLabel?.isHidden = false
            sportIconImageView?.isHidden = false
            sportContainerView?.isHidden = false
            
            sportLabel?.text = title
            
            // Extract the sport from the title
            let sportArray = title!.split(separator: " ", maxSplits: 1)
            
            if (sportArray.count == 2)
            {
                let sport = String(sportArray.last!)
                
                sportIconImageView!.image = MiscHelper.getImageForSport(sport)
            }
            
            allAthletesArray.removeAll()
            filteredAthletesArray.removeAll()
            searchTableView.reloadData()
        }
        else
        {
            filterButton.setTitle(title, for: .normal)
            
            // Filter the athletes
            self.filterAthletes()
        }
        
    }
    
    func actionSheetPickerViewDidCancel(_ pickerView: IQActionSheetPickerView)
    {
        
    }
    
    // MARK: - Button Methods
    
    @objc func sportSelectorButtonTouched()
    {
        let picker = IQActionSheetPickerView(title: "", delegate: self)
        picker.tag = 100
        picker.toolbarButtonColor = UIColor.mpWhiteColor()
        picker.toolbarTintColor = UIColor.mpLightGrayColor()
        picker.titlesForComponents = [kSearchGenderSportsArray]
        picker.show()
    }
    
    @objc func keyboardCancelButtonTouched(_ sender: UIButton)
    {
        searchTextField!.resignFirstResponder()
    }
    
    // MARK: - Init Method
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        // Build the sportContainerView
        sportContainerView = UIView(frame: CGRect(x: 20, y: 20, width: CGFloat(kDeviceWidth - 40), height: 40))
        sportContainerView?.backgroundColor = UIColor.mpOffWhiteNavColor()
        self.addSubview(sportContainerView!)
        
        sportPlaceholderLabel = UILabel(frame: CGRect(x: 16, y: 11, width: (sportContainerView?.frame.size.width)! / 2.0, height: 18))
        sportPlaceholderLabel?.font = UIFont.mpRegularFontWith(size: 15)
        sportPlaceholderLabel?.textColor = UIColor.mpLightGrayColor()
        sportPlaceholderLabel?.text = "Select a sport"
        sportContainerView?.addSubview(sportPlaceholderLabel!)
        
        downArrowImageView = UIImageView(frame: CGRect(x: (sportContainerView?.frame.size.width)! - 28, y: 17, width: 12, height: 6))
        downArrowImageView?.image = UIImage(named: "SmallDownArrowGray")
        sportContainerView?.addSubview(downArrowImageView!)
        
        sportIconImageView = UIImageView(frame: CGRect(x: 16, y: 10, width: 20, height: 20))
        sportContainerView?.addSubview(sportIconImageView!)
        sportIconImageView?.isHidden = true
        
        sportLabel = UILabel(frame: CGRect(x: 44, y: 11, width: (sportContainerView?.frame.size.width)! / 2.0, height: 18))
        sportLabel?.font = UIFont.mpRegularFontWith(size: 15)
        sportLabel?.textColor = UIColor.mpBlackColor()
        sportContainerView?.addSubview(sportLabel!)
        sportLabel?.isHidden = true
        
        selectSportButton = UIButton(type: .custom)
        selectSportButton?.frame = CGRect(x: 0, y: 0, width: (sportContainerView?.frame.size.width)!, height: (sportContainerView?.frame.size.height)!)
        selectSportButton?.addTarget(self, action: #selector(sportSelectorButtonTouched), for: .touchUpInside)
        sportContainerView?.addSubview(selectSportButton!)
        
        
        // Build the searchContainerView
        sportContainerView = UIView(frame: CGRect(x: 20, y: 68, width: CGFloat(kDeviceWidth - 40), height: 40))
        sportContainerView?.backgroundColor = UIColor.mpOffWhiteNavColor()
        self.addSubview(sportContainerView!)
        sportContainerView?.isHidden = true
        
        searchIconImageView = UIImageView(frame: CGRect(x: 16, y: 12, width: 16, height: 16))
        searchIconImageView?.image = UIImage(named: "SmallSearchIconGray")
        sportContainerView?.addSubview(searchIconImageView!)
        
        searchTextField = UITextField(frame: CGRect(x: 40, y: 3, width: (sportContainerView?.frame.size.width)! - 56, height: 34))
        searchTextField?.delegate = self
        searchTextField?.textColor = UIColor.mpBlackColor()
        searchTextField?.font = UIFont.mpRegularFontWith(size: 15)
        searchTextField?.placeholder = "Search for an athlete"
        searchTextField?.returnKeyType = .search
        searchTextField?.keyboardType = .asciiCapable
        searchTextField?.autocorrectionType = .no
        searchTextField?.autocapitalizationType = .none
        searchTextField?.clearButtonMode = .whileEditing
        searchTextField?.smartQuotesType = .no
        searchTextField?.smartDashesType = .no
        searchTextField?.smartInsertDeleteType = .no
        searchTextField?.spellCheckingType = .no
        sportContainerView?.addSubview(searchTextField!)
        
        let accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 40))
        accessoryView.backgroundColor = UIColor.mpLightGrayColor()
        
        let cancelButton = UIButton(type: .custom)
        cancelButton.frame = CGRect(x: 5, y: 5, width: 80, height: 30)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 19)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(UIColor.mpWhiteColor(), for: .normal)
        cancelButton.addTarget(self, action: #selector(keyboardCancelButtonTouched), for: .touchUpInside)
        accessoryView.addSubview(cancelButton)
        
        searchTextField!.inputAccessoryView = accessoryView
        
        // Add the tableView
        
        filterButton = UIButton()
        
        searchTableView = UITableView()
        
    }

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
}
