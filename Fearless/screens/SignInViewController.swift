//
//  SignInViewController.swift
//  Fearless
//
//  Created by Water Flower on 2019/4/22.
//  Copyright © 2019 Water Flower. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {

    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    ///////   for activity indicator  //////////
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView();
    var overlayView:UIView = UIView();
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.signinButton.layer.cornerRadius = 5
        self.signupButton.layer.cornerRadius = 5
        self.signupButton.layer.borderWidth = 1
        self.signupButton.layer.borderColor = UIColor.white.cgColor
        
        ////  dismiss keyboard   ///////
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func signinButtonAction(_ sender: Any) {
        var email = self.emailTextField.text!
        var password = self.passwordTextField.text!
//        email = "hezhejin1227@gmail.com"
//        password = "123"
        
        if email == "" {
            createAlert(title: "Warning!", message: "Please input Email.")
            return
        }
        if !isValidEmail(email_str: email) {
            createAlert(title: "Warning!", message: "Please input valid email address.")
            return
        }
        if password == "" {
            createAlert(title: "Warning!", message: "Please input Password.")
            return
        }
        
        startActivityIndicator();
        var apiString = Global.base_url + "userlogin.php"
        apiString += "?username=" + email + "&pass=" + password + "&api_token=" + Global.fcm_token
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
                            Global.email = email
                            Global.password = password
                            UserDefaults.standard.set(email, forKey: "email")
                            UserDefaults.standard.set(password, forKey: "password")
                            UserDefaults.standard.set(true, forKey: "signin")
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
                            self.createAlert(title: "Warning!", message: "Your Email/Password is incorrect. Please try again.")
                        }
                    } else {
                       self.createAlert(title: "Warning!", message: "unknown error.")
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
                }
            }
        }
        task_login.resume();
        
    }
    
    @IBAction func forgotButtonAction(_ sender: Any) {
        var mainStoryboard = UIStoryboard()
        if UIDevice.current.userInterfaceIdiom == .pad {
            mainStoryboard = UIStoryboard(name: "MainiPad", bundle: nil)
        } else {
            mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        }
        let forgotVC = mainStoryboard.instantiateViewController(withIdentifier: "ForgotPasswordViewController") as! ForgotPasswordViewController
        self.navigationController?.pushViewController(forgotVC, animated: true)
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
    
    func isValidEmail(email_str: String) -> Bool {
        let regExp = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", regExp)
        return emailTest.evaluate(with: email_str)
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
