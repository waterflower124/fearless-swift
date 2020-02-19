//
//  AboutUsViewController.swift
//  Fearless
//
//  Created by Water Flower on 2019/4/23.
//  Copyright © 2019 Water Flower. All rights reserved.
//

import UIKit

class AboutUsViewController: BaseViewController {
    
    ///////   for activity indicator  //////////
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView();
    var overlayView:UIView = UIView();

    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "About Us"
        self.navigationItem.hidesBackButton = true
        
        addSlideMenuButton()
        
        startActivityIndicator();
        
        var apiString = Global.base_url + "master.php?api=about_us"
        apiString = apiString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        var api_url = URLRequest(url: URL(string: apiString)!)
        api_url.httpMethod = "GET"
        var about_text = ""
        let task_aboutus = URLSession.shared.dataTask(with: api_url) {
            (data, response, error) in
            if error == nil {
                let jsonData = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers);
                if let responseDic = jsonData as? Dictionary<String, AnyObject> {
                    if let result_status = responseDic["status"] as? String {
                        if result_status == "success" {
                            about_text = (responseDic["data"] as? String)!
                        } else {
                            
                        }
                    } else {
                        
                    }
                }
            } else {
                
            }
            DispatchQueue.main.async {
                self.stopActivityIndicator()
                about_text = about_text.replacingOccurrences(of: "<p>", with: "")
                about_text = about_text.replacingOccurrences(of: "</p>", with: "")
                self.textView.text = about_text
            }
        }
        task_aboutus.resume();
    }
    
    
    func startActivityIndicator() {
        activityIndicator.center = self.view.center;
        activityIndicator.hidesWhenStopped = true;
        activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge;
        view.addSubview(activityIndicator);
        activityIndicator.startAnimating();
        overlayView = UIView(frame:view.frame);
        view.addSubview(overlayView);
        UIApplication.shared.beginIgnoringInteractionEvents();
    }
    
    func stopActivityIndicator() {
        self.activityIndicator.stopAnimating();
        self.overlayView.removeFromSuperview();
        if UIApplication.shared.isIgnoringInteractionEvents {
            UIApplication.shared.endIgnoringInteractionEvents();
        }
    }
    

}
