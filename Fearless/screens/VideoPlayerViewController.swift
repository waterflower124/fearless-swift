//
//  VideoPlayerViewController.swift
//  Fearless
//
//  Created by Water Flower on 2019/4/24.
//  Copyright © 2019 Water Flower. All rights reserved.
//

import UIKit
import MediaPlayer
import AVKit
import AVFoundation
import AudioToolbox
import Kingfisher

class VideoPlayerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AVPlayerViewControllerDelegate, UITextViewDelegate {
    
    @IBOutlet weak var myavatarimageview: UIImageView!
    @IBOutlet weak var commentTableView: UITableView!
    @IBOutlet weak var favorButton: UIButton!
    @IBOutlet weak var videoView: UIView!
    
    var selected_video: Dictionary<String, Any>?
    var passVC: String?
    
    ///////   for activity indicator  //////////
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView();
    var overlayView:UIView = UIView();
    
    var comment_array = [Dictionary<String, Any>]()
    
    ////  video player
    var player = AVPlayer()
    var playervc = AVPlayerViewController()
    
    /// for comment view
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var commentTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = self.selected_video!["video_title"] as? String
        self.commentTableView.separatorStyle = .none
        self.myavatarimageview.layer.cornerRadius = 35
        
        /// favorite button background image
        if(passVC == "videolistVC") {
            let isFav = self.selected_video!["isFav"] as! Int
            if isFav == 0 {
                self.favorButton.setImage(UIImage(named: "favor_empty"), for: .normal)
            } else {
                self.favorButton.setImage(UIImage(named: "favor_full"), for: .normal)
            }
        } else if(passVC == "favorVC") {
            self.favorButton.setImage(UIImage(named: "favor_full"), for: .normal)
        }
        
        ////  video player
        let videoURL:NSURL = NSURL(string: self.selected_video!["url"] as! String)!
        self.player = AVPlayer(url: videoURL as URL)
//        let playervc = AVPlayerViewController()
        self.playervc.delegate = self
        self.playervc.player = player
        self.playervc.view.frame.size.width = self.videoView.frame.size.width
        self.playervc.view.frame.size.height = self.videoView.frame.size.height
        self.videoView.addSubview(self.playervc.view)
//        self.present(playervc, animated: true) {
//            playervc.player!.play()
//        }
        self.addChild(self.playervc)
        self.player.play()
        
        ////  dismiss keyboard   ///////
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
        
        ///  for keyboardavoiding  ////
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        startActivityIndicator();
        
        var apiString = Global.base_url + "comment_list.php"
        let video_id = self.selected_video!["num"] as? String
        apiString += "?videoId=" + video_id!
        apiString = apiString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        var api_url = URLRequest(url: URL(string: apiString)!)
        api_url.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: api_url) {
            (data, response, error) in
            if error == nil {
                let jsonData = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers);
                if let responseDic = jsonData as? Dictionary<String, AnyObject> {
                    if let result_status = responseDic["status"] as? String {
                        if result_status == "success" {
                            var dic_array = (responseDic["data"] as? [Dictionary<String, AnyObject>])!
                            for i in 0 ..< dic_array.count {
                                dic_array[i]["status"] = "parent" as AnyObject
                                self.comment_array.append(dic_array[i])
                                if var answer = dic_array[i]["answer"] as? [Dictionary<String, Any>] {
                                    for j in 0 ..< answer.count {
                                        answer[j]["status"] = "child"
                                        self.comment_array.append(answer[j])
                                    }
                                } 
                            }
                        } else {
                            
                        }
                    } else {
                        
                    }
                }
            } else {
                print("netowrk error")
            }
            DispatchQueue.main.async {
                self.stopActivityIndicator()
                self.commentTableView.reloadData()
            }
        }
        task.resume();
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Global.avatar_url == "" {
            self.myavatarimageview.image = UIImage(named: "empty_avatar")
        } else {
            let url = URL(string: Global.avatar_url)!
            self.myavatarimageview.kf.setImage(with: url)
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
            DispatchQueue.main.async {
                self.playervc.player = self.player
                self.addChild(self.playervc)
                self.view.addSubview(self.playervc.view)
                self.playervc.view.frame = self.view.frame
                self.view.bringSubviewToFront(self.favorButton)
            }
        } else {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            self.videoView.addSubview(playervc.view)
            self.playervc.view.frame = self.videoView.bounds
            self.videoView.frame = self.videoView.bounds
        }
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Comment" {
            textView.text = nil
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Comment"
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comment_array.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commenttableviewcell") as? CommentTableViewCell
        cell!.selectionStyle = UITableViewCell.SelectionStyle.none
        cell?.commentTextView.text = self.comment_array[indexPath.row]["comment"] as? String
        if let avatar_url = self.comment_array[indexPath.row]["profile_pic"] as? String {
            let url = URL(string: avatar_url)!
            cell?.comment_avatarimageview.kf.setImage(with: url)
        } else {
            cell?.comment_avatarimageview.image = UIImage(named: "empty_avatar")
        }
        
        if self.comment_array[indexPath.row]["status"] as? String == "parent" {
            cell?.imageLeadingConstraint.constant = 20
        } else {
            cell?.imageLeadingConstraint.constant = 40
        }
        
        return cell!
    }
    
    @IBAction func favorButtonAction(_ sender: Any) {
        
        let video_id = self.selected_video!["num"] as? String
        let dict_param:[String:String] = ["userId": Global.user_id, "videoId": video_id!, "isFav": "1"]
        var data = [String]()
        for(key, value) in dict_param {
            data.append(key + "=\(value)")
        }
        let postString = data.map{String($0)}.joined(separator: "&")
        let url_string = Global.base_url + "isFav.php"
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
                if succ_bool {
                    if self.favorButton.currentImage == UIImage(named: "favor_empty") {
                        self.favorButton.setImage(UIImage(named: "favor_full"), for: .normal)
                    } else {
                        self.favorButton.setImage(UIImage(named: "favor_empty"), for: .normal)
                    }
                }
            }
        }
        task.resume()
    }
    
    @IBAction func addcommentButtonAction(_ sender: Any) {
        self.scrollview.isHidden = false
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        self.scrollview.isHidden = true
    }
    
    @IBAction func saveButtonAction(_ sender: Any) {
        self.commentTableView.resignFirstResponder()
        let comment = self.commentTextView.text
        startActivityIndicator();
        
        let dict_param:[String:String] = ["user_id": Global.user_id, "video_id": self.selected_video!["num"] as! String, "comment": comment!]
        var data = [String]()
        for(key, value) in dict_param {
            data.append(key + "=\(value)")
        }
        let postString = data.map{String($0)}.joined(separator: "&")
        let url_string = Global.base_url + "comment.php"
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
    
    func createAlert(title: String, message: String, type: Bool) {
        let alert = UIAlertController(title: title, message:message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)
            if type {
                self.commentTextView.text = "Add Comment"
                self.scrollview.isHidden = true
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
