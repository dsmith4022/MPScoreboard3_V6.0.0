//
//  UpdateSchoolsViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/9/21.
//

import UIKit

class UpdateSchoolsViewController: UIViewController
{
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var textLabel: UILabel!
    
    // MARK: - File Cleanup
    
    private func cleanUpSchoolsFile()
    {
        let documentDirectory = MiscHelper.documentDirectory()
        let filePath = documentDirectory + "/ALL.txt"
        
        // Read the file
        var wordstring = ""
        do {
                wordstring = try String(contentsOfFile: filePath, encoding: .utf8)
            }
            catch
            {
                print("Couldn't read file")
            }
            
        // Split the string into an array
        let lineArray = wordstring.components(separatedBy: "\n")
        
        // Iterate backwards to remove items
        var fixedArray = [""]
        for line in lineArray
        {
            let components = line.components(separatedBy: "|")
            
            if (components.count > 10)
            {
                let state = components[6]
                
                // Remove schools with no state (international)
                if (state.count == 0)
                {
                   //NSLog(@"Missing State Found at index: %ld", (long)i);
                    continue
                }
            }
            else
            {
                // Empty line
                //NSLog(@"Empty Line Found at index: %ld", (long)i);
                continue
            }
            
            fixedArray.append(line)
        }
        
        print("Final School Count: " + String(fixedArray.count));
        
        // Update the file with the cleaned up data
        var fileString = ""
        
        for (index, line) in fixedArray.enumerated()
        {
            if ((lineArray.count - 1) == index)
            {
                // Last line
                fileString = fileString + line
            }
            else
            {
                fileString = fileString + line + "\n"
            }
        }

        // Hide the HUD
        MBProgressHUD.hide(for: self.view, animated: true)
            
        MiscHelper.showAlert(in: self, withActionNames: ["Ok"], title: "MaxPreps App", message: "The school database was successfully updated.", lastItemCancelType: false) { (tag) in }

        
        // Write the file
        MiscHelper.saveFile(text: fileString, toDirectory: documentDirectory, withFileName: "ALL.txt")
    
    }
    
    // MARK: - Button Methods
    
    @IBAction func updateButtonTouched(_ sender: UIButton)
    {
        DispatchQueue.main.async
        {
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        /*
        DispatchQueue.main.asyncAfter(deadline: .now() + 3)
        {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
        */
        
        var urlRequest = URLRequest(url: URL(string: kDownloadSchoolListHostProduction)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("no-cache, no-store, must-revalidate", forHTTPHeaderField: "Cache-Control")
        urlRequest.addValue("no-cache", forHTTPHeaderField: "Pragma")
        
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
                                // School Full Name | SchoolID | School URL | School Name | Address | City | State | Zip | Phone | Longitude | Latitude
                                
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                //print(logDataReceived)
                                
                                //MiscHelper.showAlert(in: self, withActionNames: ["Ok"], title: "MaxPreps App", message: "Successful download.", lastItemCancelType: false) { (tag) in }
                                                                
                                // Write the downloaded file to the Documents Directory
                                let documentDirectory = MiscHelper.documentDirectory()
                                MiscHelper.saveFile(text: logDataReceived, toDirectory: documentDirectory, withFileName: "ALL.txt")
                                
                                // Clean up the file
                                self.cleanUpSchoolsFile()
                            }
                            else
                            {
                                MBProgressHUD.hide(for: self.view, animated: true)
                                print("Data was nil")
                                MiscHelper.showAlert(in: self, withActionNames: ["Ok"], title: "MaxPreps App", message: "Failed. Data was nil.", lastItemCancelType: false) { (tag) in
                                    
                                }
                            }
                        }
                        else
                        {
                            MBProgressHUD.hide(for: self.view, animated: true)
                            print("Status != 200")
                            MiscHelper.showAlert(in: self, withActionNames: ["Ok"], title: "MaxPreps App", message: "Failed. Status was not 200.", lastItemCancelType: false) { (tag) in
                                
                            }
                        }
                    }
                    else
                    {
                        MBProgressHUD.hide(for: self.view, animated: true)
                        print("Response was nil")
                        MiscHelper.showAlert(in: self, withActionNames: ["Ok"], title: "MaxPreps App", message: "Failed. Response was nil.", lastItemCancelType: false) { (tag) in
                            
                        }
                    }
                }
                else
                {
                    MBProgressHUD.hide(for: self.view, animated: true)
                    print("Connection Error")
                    MiscHelper.showAlert(in: self, withActionNames: ["Ok"], title: "MaxPreps App", message: "Failed. Connection error.", lastItemCancelType: false) { (tag) in
                        
                    }
                }
            }
        }
        
        task.resume()

    }

    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        updateButton.layer.cornerRadius = 8
        updateButton.clipsToBounds = true
        
        self.navigationItem.title = "Update Schools"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
                
    }

    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return UIStatusBarStyle.default
    }
    
    override open var shouldAutorotate: Bool
    {
        return false
    }
    
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation
    {
        return UIInterfaceOrientation.portrait
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask
    {
        return .portrait
    }
    

}
