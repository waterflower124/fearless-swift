//
//  MenuViewController.swift
//  Fearless
//
//  Created by Water Flower on 2019/4/23.
//  Copyright © 2019 Water Flower. All rights reserved.
//

import UIKit
import Kingfisher

protocol SlideMenuDelegate {
    func slideMenuItemSelectedAtIndex(_ index: Int32)
}

class MenuViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var btnMenu: UIButton!
    var delegate: SlideMenuDelegate?
    
    @IBOutlet weak var avatar_imageview: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var closeMenuButton: UIButton!
    
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var purchaseButton: UIButton!
    @IBOutlet weak var aboutusButton: UIButton!
    @IBOutlet weak var contactusButton: UIButton!
    @IBOutlet weak var signoutButton: UIButton!
    
    ///////   for activity indicator  //////////
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView();
    var overlayView:UIView = UIView();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nameLabel.text = Global.firstname + " " + Global.lastname
        
        let pictureTap = UITapGestureRecognizer(target: self, action: #selector(MenuViewController.imageTapped))
        self.avatar_imageview.addGestureRecognizer(pictureTap)
        self.avatar_imageview.isUserInteractionEnabled = true
        
        IAPService.shared.getProducts()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if Global.avatar_url == "" {
            self.avatar_imageview.image = UIImage(named: "empty_avatar")
        } else {
            let url = URL(string: Global.avatar_url)!
            self.avatar_imageview.kf.setImage(with: url)
        }
    }
    
    @objc func imageTapped() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action: UIAlertAction) in
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Gallery", style: .default, handler: {(action: UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.popoverPresentationController?.sourceView = self.view;
        actionSheet.popoverPresentationController?.barButtonItem = self.navigationItem.leftBarButtonItem
        actionSheet.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
//        self.avatar_imageview.image = image
        picker.dismiss(animated: true, completion: nil)
        
        startActivityIndicator();
        
        let dict_param:[String:String] = ["userId": Global.user_id]
        let url_string = Global.base_url + "pic_upload.php"
        var request_url = URLRequest(url: URL(string: url_string)!)
        request_url.httpMethod = "POST"
        let boundary = "Boundary-\(NSUUID().uuidString)"
        request_url.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let imageData = image.pngData()
        if(imageData == nil)  { return; }
        request_url.httpBody = createBodyWithParameters(parameters: dict_param, filePathKey: "profile_pic", imageDataKey: imageData! as NSData, boundary: boundary) as Data
        
        var succ_bool: Bool = false
        
        let task = URLSession.shared.dataTask(with: request_url) { (data, response, error) in
            if error != nil {
                print(error!)
            } else {
                let jsonData = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers);
                if let responseDic = jsonData as? Dictionary<String, AnyObject> {
                    print(responseDic)
                    if let result_status = responseDic["status"] as? String {
                        if result_status == "success" {
                            succ_bool = true
                            let response_data = responseDic["data"] as! [Dictionary<String, Any>]
                            Global.avatar_url = response_data[0]["profile_pic"] as! String
                            
                        }
                    }
                } else {
                    print("response error")
                }
            }
            DispatchQueue.main.async {
                self.stopActivityIndicator()
                if !succ_bool {
                    self.createAlert(title: "Warning!", message: "Error occured. Please try again.", type: false)
                } else {
                    let url = URL(string: Global.avatar_url)!
                    self.avatar_imageview.kf.setImage(with: url)
                }
            }
        }
        task.resume()
    }
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
        let body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString(string: "--\(boundary)\r\n")
                body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString(string: "\(value)\r\n")
            }
        }
        
        let filename = Global.fcm_token + ".png"
        
        let mimetype = "image/png"
        
        body.appendString(string: "--\(boundary)\r\n")
        body.appendString(string: "Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey as Data)
        body.appendString(string: "\r\n")
        
        body.appendString(string: "--\(boundary)--\r\n")
        
        return body
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func closeMenuButtonAction(_ sender: UIButton) {
        btnMenu.tag = 0
        btnMenu.isHidden = false
        if self.delegate != nil {
            var index = Int32(sender.tag)
            if sender == self.closeMenuButton {
                index = -1
            }
            delegate?.slideMenuItemSelectedAtIndex(index)
        }
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.view.frame = CGRect(x: self.view.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
            self.view.layoutIfNeeded()
            self.view.backgroundColor = UIColor.clear
        }, completion: { (finished) -> Void in
            self.view.removeFromSuperview()
            self.removeFromParent()
        })
    }
    
    @IBAction func MenuButtonsAction(_ sender: UIButton) {
        
        var mainStoryboard = UIStoryboard()
        if UIDevice.current.userInterfaceIdiom == .pad {
            mainStoryboard = UIStoryboard(name: "MainiPad", bundle: nil)
        } else {
            mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        }
        if sender == self.signoutButton {
            UserDefaults.standard.set(false, forKey: "signin")
            let destVC = mainStoryboard.instantiateViewController(withIdentifier: "SplashViewController") as! SplashViewController
            self.navigationController?.pushViewController(destVC, animated: true)
        } else if sender == self.categoryButton {
            if UIDevice.current.userInterfaceIdiom == .pad {
                let destVC = mainStoryboard.instantiateViewController(withIdentifier: "CategoryiPadViewController") as! CategoryiPadViewController
                self.navigationController?.pushViewController(destVC, animated: true)
            } else {
                let destVC = mainStoryboard.instantiateViewController(withIdentifier: "CategoryViewController") as! CategoryViewController
                self.navigationController?.pushViewController(destVC, animated: true)
            }
        } else if sender == self.favoriteButton {
            let destVC = mainStoryboard.instantiateViewController(withIdentifier: "FavoritesViewController") as! FavoritesViewController
            self.navigationController?.pushViewController(destVC, animated: true)
        } else if sender == self.purchaseButton {
           
            let alert = UIAlertController(title: "Notice!", message: "Do you want purchase or restore previous purchase?", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Purchase", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)
                IAPService.shared.purchase(product: .nonconsumable)
            }))
            alert.addAction(UIAlertAction(title: "Restore", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)
                IAPService.shared.restorePurchase()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else if sender == self.aboutusButton {
            let destVC = mainStoryboard.instantiateViewController(withIdentifier: "AboutUsViewController") as! AboutUsViewController
            self.navigationController?.pushViewController(destVC, animated: true)
        } else if sender == self.contactusButton {
            let destVC = mainStoryboard.instantiateViewController(withIdentifier: "ContactUsViewController") as! ContactUsViewController
            self.navigationController?.pushViewController(destVC, animated: true)
        }
    }
    
    func createAlert(title: String, message: String, type: Bool) {
        let alert = UIAlertController(title: title, message:message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)
            
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

extension NSMutableData {
    
    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}
