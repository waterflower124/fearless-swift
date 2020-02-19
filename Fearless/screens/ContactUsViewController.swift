//
//  ContactUsViewController.swift
//  Fearless
//
//  Created by Water Flower on 2019/4/23.
//  Copyright © 2019 Water Flower. All rights reserved.
//

import UIKit

class ContactUsViewController: BaseViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var fullnameTextField: UITextField!
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var commentTextView: UITextView!
    
    ///////   for activity indicator  //////////
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView();
    var overlayView:UIView = UIView();
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Contact Us"
        self.navigationItem.hidesBackButton = true
        
        addSlideMenuButton()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        commentTextView.text = "Say something..."
        
        ////  dismiss keyboard   ///////
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Say something..." {
            textView.text = nil
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Say something..."
        }
    }
    
    @IBAction func sendButtonAction(_ sender: Any) {
        
        commentTextView.resignFirstResponder()
        
        let fullname = self.fullnameTextField.text!
        let mobile = self.mobileTextField.text!
        let email = self.emailTextField.text!
        let comment = self.commentTextView.text!
        
        if fullname == "" {
            self.createAlert(title: "Warning!", message: "Please input your full name.", type: false)
            return
        }
        if mobile == "" {
            self.createAlert(title: "Warning!", message: "Please input your mobile number.", type: false)
            return
        }
        if email == "" {
            self.createAlert(title: "Warning!", message: "Please input your email.", type: false)
            return
        }
        if !isValidEmail(email_str: email) {
            self.createAlert(title: "Warning!", message: "Please input valid email address.", type: false)
            return
        }
        if comment == "Say something..." {
            self.createAlert(title: "Warning!", message: "Please input comment.", type: false)
            return
        }
        
        startActivityIndicator();
        
        let dict_param:[String:String] = ["full_name": fullname, "mobile": mobile, "email": email, "comments": comment, "user_id": Global.user_id]
        var data = [String]()
        for(key, value) in dict_param {
            data.append(key + "=\(value)")
        }
        let postString = data.map{String($0)}.joined(separator: "&")
        let url_string = Global.base_url + "contact.php"
        var request_url = URLRequest(url: URL(string: url_string)!)
        request_url.httpMethod = "POST"
        request_url.httpBody = postString.data(using: .utf8)
        
        var succ_bool: Bool = false
        
        let task = URLSession.shared.dataTask(with: request_url) { (data, response, error) in
            if error != nil {
                
            } else {
                let jsonData = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers);
                if let responseDic = jsonData as? Dictionary<String, AnyObject> {
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
                    self.createAlert(title: "Success!", message: "Your comments has been submitted.", type: true)
                } else {
                    self.createAlert(title: "Warning!", message: "Error occured. Please try again.", type: false)
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
                self.fullnameTextField.text = ""
                self.mobileTextField.text = ""
                self.emailTextField.text = ""
                self.commentTextView.text = "Say something..."
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
