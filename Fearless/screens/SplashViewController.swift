//
//  SplashViewController.swift
//  Fearless
//
//  Created by Water Flower on 2019/4/22.
//  Copyright © 2019 Water Flower. All rights reserved.
//

import UIKit
import FSPagerView

class SplashViewController: UIViewController, FSPagerViewDataSource, FSPagerViewDelegate {
    
    // MARK:- FSPagerView DataSource
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return self.message_array.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        cell.textLabel!.text = self.message_array[index]["value"] as? String

        return cell
    }
    
    // MARK:- FSPagerView Delegate
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        pagerView.scrollToItem(at: index, animated: true)
    }
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        self.pageControl.currentPage = targetIndex
    }
    
    func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) {
        self.pageControl.currentPage = pagerView.currentIndex
    }
    
    
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    ///////   for activity indicator  //////////
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView();
    var overlayView:UIView = UIView();
    
    var message_array  = [Dictionary<String, Any>]()
    
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
            self.pagerView.itemSize = FSPagerView.automaticSize
        }
    }
    
    @IBOutlet weak var pageControl: FSPageControl! {
        didSet {
            self.pageControl.numberOfPages = self.message_array.count
            self.pageControl.contentHorizontalAlignment = .center
            self.pageControl.contentInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.signinButton.layer.cornerRadius = 5
        
        self.signupButton.layer.cornerRadius = 5
        self.signupButton.layer.borderWidth = 1
        self.signupButton.layer.borderColor = UIColor.white.cgColor
        
        if UserDefaults.standard.bool(forKey: "signin") {
            self.signinButton.setTitle("GO TO CATEGORIES", for: .normal)
            self.signupButton.isHidden = true
        } else {
            self.signinButton.setTitle("LOGIN", for: .normal)
            self.signupButton.isHidden = false
        }
        
        self.pagerView.isInfinite = true
        self.pagerView.automaticSlidingInterval = 3.0 - self.pagerView.automaticSlidingInterval
        
        var apiString = Global.base_url + "master.php?api=welcome_message"
        
        apiString = apiString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        var api_url = URLRequest(url: URL(string: apiString)!)
        api_url.httpMethod = "GET"
        let task_aboutus = URLSession.shared.dataTask(with: api_url) {
            (data, response, error) in
            if error == nil {
                let jsonData = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers);
                if let responseDic = jsonData as? Dictionary<String, AnyObject> {
                    if let result_status = responseDic["status"] as? String {
                        if result_status == "success" {
                            self.message_array = responseDic["data"] as! [Dictionary<String, Any>]
                        } else {
                            
                        }
                    } else {
                        
                    }
                }
            } else {
                
            }
            DispatchQueue.main.async {
                self.pageControl.itemSpacing = 15
                self.pageControl.interitemSpacing = 15
                self.pageControl.currentPage = 0
                self.pageControl.numberOfPages = self.message_array.count
                self.pagerView.reloadData()
            }
        }
        task_aboutus.resume();
        
    }

    
    @IBAction func signinButtonAction(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: "signin") {
            let email = UserDefaults.standard.string(forKey: "email")
            let password = UserDefaults.standard.string(forKey: "password")
            startActivityIndicator();
            
            var apiString = Global.base_url + "userlogin.php"
            apiString += "?username=" + email! + "&pass=" + password! + "&api_token=" + Global.fcm_token
            apiString = apiString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            var api_url = URLRequest(url: URL(string: apiString)!)
            api_url.httpMethod = "GET"
            
            var succ_bool: Bool = false
            
            let task_login = URLSession.shared.dataTask(with: api_url) {
                (data, response, error) in
                if error == nil {
                    let jsonData = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers);
                    if let responseDic = jsonData as? Dictionary<String, AnyObject> {
                        if let result_status = responseDic["status"] as? String {
                            if result_status == "success" {
                                print(responseDic)
                                Global.email = email!
                                Global.password = password!
                                if let data = responseDic["data"] as? Dictionary<String, Any> {
                                    Global.firstname = data["first_name"] as! String
                                    Global.lastname = data["surname"] as! String
                                    if let profile_pic = data["profile_pic"] as? String {
                                        Global.avatar_url = profile_pic
                                    } else {
                                        Global.avatar_url = ""
                                    }
                                    Global.user_id = data["num"] as! String
                                    Global.is_purchased = data["is_purchase"] as! String
                                }
                                succ_bool = true
                            } else {
                                
                            }
                        } else {
                            
                        }
                    }
                } else {
                    self.createAlert(title: "Warning!", message: "Network error.")
                }
                DispatchQueue.main.async {
                    self.stopActivityIndicator()
                    if succ_bool {
                        var mainStoryboard = UIStoryboard()
                        if UIDevice.current.userInterfaceIdiom == .pad {
                            mainStoryboard = UIStoryboard(name: "MainiPad", bundle: nil)
                            let categoryVC = mainStoryboard.instantiateViewController(withIdentifier: "CategoryiPadViewController") as! CategoryiPadViewController
                            self.navigationController?.pushViewController(categoryVC, animated: true)
                        } else {
                            mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let categoryVC = mainStoryboard.instantiateViewController(withIdentifier: "CategoryViewController") as! CategoryViewController
                            self.navigationController?.pushViewController(categoryVC, animated: true)
                        }
                        
                    } else {
                        self.createAlert(title: "Warning!", message: "Network error.")
                    }
                }
            }
            task_login.resume();
        } else {
            var mainStoryboard = UIStoryboard()
            if UIDevice.current.userInterfaceIdiom == .pad {
                mainStoryboard = UIStoryboard(name: "MainiPad", bundle: nil)
            } else {
                mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            }
            let signinVC = mainStoryboard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
            self.navigationController?.pushViewController(signinVC, animated: true)
        }
        
    }
    
    @IBAction func signupButtonAction(_ sender: Any) {
        var mainStoryboard = UIStoryboard()
        if UIDevice.current.userInterfaceIdiom == .pad {
            mainStoryboard = UIStoryboard(name: "MainiPad", bundle: nil)
        } else {
            mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        }
        let signupVC = mainStoryboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        self.navigationController?.pushViewController(signupVC, animated: true)
    }
    
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message:message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
        self.present(alert, animated: true, completion: nil)
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
