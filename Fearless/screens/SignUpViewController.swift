//
//  SignUpViewController.swift
//  Fearless
//
//  Created by Water Flower on 2019/4/22.
//  Copyright © 2019 Water Flower. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmTextField: UITextField!
    @IBOutlet weak var scrollview: UIScrollView!
    
    ///////   for activity indicator  //////////
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView();
    var overlayView:UIView = UIView();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        ////  dismiss keyboard   ///////
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationItem.title = "Register"
        self.navigationItem.leftBarButtonItem?.title = ""
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification:NSNotification){
        
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollview.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollview.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollview.contentInset = contentInset
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func singupButtonAction(_ sender: Any) {
        let firstname = self.firstnameTextField.text!
        let lastname = self.lastnameTextField.text!
        let email = self.emailTextField.text!
        let password = self.passwordTextField.text!
        let confirm = self.confirmTextField.text!
        
        if firstname == "" {
            createAlert(title: "Warning!", message: "Please input First Name.", type: false)
            return
        }
        if lastname == "" {
            createAlert(title: "Warning!", message: "Please input Last Name.", type: false)
            return
        }
        if email == "" {
            createAlert(title: "Warning!", message: "Please input Email.", type: false)
            return
        }
        if !isValidEmail(email_str: email) {
            createAlert(title: "Warning!", message: "Please input valid email address.", type: false)
            return
        }
        if password == "" {
            createAlert(title: "Warning!", message: "Please input Password.", type: false)
            return
        }
        if password != confirm {
            createAlert(title: "Warning!", message: "Password doesn't match.", type: false)
            return
        }
        
        startActivityIndicator();
        
        let dict_param:[String:Any] = ["firstname": firstname, "lastname": lastname, "email": email, "password": password, "isfbuser": "false", "token": Global.fcm_token]
        var data = [String]()
        for(key, value) in dict_param {
            data.append(key + "=\(value)")
        }
        let postString = data.map{String($0)}.joined(separator: "&")
        let url_string = Global.base_url + "signup.php"
        var request_url = URLRequest(url: URL(string: url_string)!)
        request_url.httpMethod = "POST"
        request_url.httpBody = postString.data(using: .utf8)
        
        var succ_bool: Bool = false
        
        let task = URLSession.shared.dataTask(with: request_url) { (data, response, error) in
            if error != nil {
                
            } else {
                let jsonData = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers);
                if let responseDic = jsonData as? Dictionary<String, AnyObject> {
                    print(responseDic)
                    if let result_status = responseDic["status"] as? String {
                        if result_status == "success" {
                            succ_bool = true
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                self.stopActivityIndicator()
                if succ_bool {
                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let signinVC = mainStoryboard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
                    self.navigationController?.pushViewController(signinVC, animated: true)
                } else {
                    self.createAlert(title: "Warning!", message: "User aleardy exist.", type: false)
                }
            }
        }
        task.resume()
    }
    
    func isValidEmail(email_str: String) -> Bool {
        let regExp = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", regExp)
        return emailTest.evaluate(with: email_str)
    }
    
    func createAlert(title: String, message: String, type: Bool) {
        let alert = UIAlertController(title: title, message:message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)
            if type {
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let signinVC = mainStoryboard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
                self.navigationController?.pushViewController(signinVC, animated: true)
            }
        }))
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
