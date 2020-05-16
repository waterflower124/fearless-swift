//
//  VideoPlayeriPadViewController.swift
//  Fearless
//
//  Created by Water Flower Mac on 2019/5/23.
//  Copyright © 2019 Water Flower. All rights reserved.
//

import UIKit
import MediaPlayer
import AVKit
import AVFoundation
import AudioToolbox
import Kingfisher
import Toast_Swift

class VideoPlayeriPadViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AVPlayerViewControllerDelegate, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate  {
   
    
    @IBOutlet weak var myavatarimageview: UIImageView!
    @IBOutlet weak var commentTableView: UITableView!
    @IBOutlet weak var favorButton: UIButton!
    @IBOutlet weak var videoView: UIView!
    
    @IBOutlet weak var videolistTableView: UITableView!
    
    @IBOutlet weak var publiccommentButton: UIButton!
    @IBOutlet weak var privatecommentButton: UIButton!
    var displying_commnetsType = "public"///"private"
    
    var selected_video: Dictionary<String, Any>?
    var passVC: String?
    var video_array = [Dictionary<String, Any>]()
    var selectedIndexPath: IndexPath!
    
    ///////   for activity indicator  //////////
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView();
    var overlayView:UIView = UIView();
    
    var comment_array = [Dictionary<String, Any>]()
    var public_comment_array = [Dictionary<String, Any>]()
    var private_comment_array = [Dictionary<String, Any>]()
    
    ////  video player
    var player = AVPlayer()
    var playervc = AVPlayerViewController()
    var fullscreen_mode_global = false
    
    /// for comment view
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var timePickerView: UIPickerView!
    
    var timepicker_array = [[String]]()
    var hour_array = [String]()
    var minute_array = [String]()
    var second_array = [String]()
    var hour_label = ["hour"]
    var minutes_label = ["min"]
    var second_label = ["sec"]
    var selected_hour_string = "00"
    var selected_min_string = "00"
    var selected_sec_string = "00"
    
    var toastViewX = 0
    var toastViewY = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let customBackButton = UIBarButtonItem(image: UIImage(named: "backArrow") , style: .plain, target: self, action: #selector(backAction(sender:)))
        customBackButton.imageInsets = UIEdgeInsets(top: 2, left: -8, bottom: 0, right: 0)
        navigationItem.leftBarButtonItem = customBackButton
        
        self.navigationItem.title = self.selected_video!["video_title"] as? String
        self.myavatarimageview.layer.cornerRadius = 35
        
        commentTableView.separatorStyle = .none
        videolistTableView.separatorStyle = .none
        
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
        
        
        /////  play video
        self.video_play(start_time: self.selected_video!["last_seen"] as! Int)
        
//        playervc.addObserver(self, forKeyPath: #keyPath(AVPlayerViewController.videoBounds), options: [.old, .new], context: nil)
        
        ////  dismiss keyboard   ///////
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
        
        ///  for keyboardavoiding  ////
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        /// reload comment table view
        self.reload_commentTableView()
        
        for i in 0 ... 12 {
            if i < 10 {
                self.hour_array.append("0\(i)")
            } else {
                self.hour_array.append("\(i)");
            }
        }
        for j in 0 ..< 60 {
            if j < 10 {
                self.minute_array.append("0\(j)")
                self.second_array.append("0\(j)")
            } else {
                self.minute_array.append("\(j)")
                self.second_array.append("\(j)")
            }
        }
        self.timepicker_array = [self.hour_array, self.hour_label, self.minute_array, self.minutes_label, self.second_array, self.second_label]
        
        self.playervc.showsPlaybackControls = false
        
        let onetapPlayer = UITapGestureRecognizer(target: self, action: #selector(oneTappedVideoPlayer))
        onetapPlayer.numberOfTapsRequired = 1
        self.playervc.view.addGestureRecognizer(onetapPlayer)
        
        let doubletapPlayer = UITapGestureRecognizer(target: self, action: #selector(doubleTappedVideoPlayer))
        doubletapPlayer.numberOfTapsRequired = 2
        self.playervc.view.addGestureRecognizer(doubletapPlayer)
        
        onetapPlayer.require(toFail: doubletapPlayer)
    }
    
    @objc func oneTappedVideoPlayer(touch: UITapGestureRecognizer) {
            
        self.playervc.showsPlaybackControls = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            self.playervc.showsPlaybackControls = false
        })
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {

        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContextWithOptions(CGSize(width: newWidth, height: newHeight), false, 0.0)
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: newWidth, height: newHeight)))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
    
    @objc func doubleTappedVideoPlayer(touch: UITapGestureRecognizer) {
        let touchPoint = touch.location(in: self.playervc.view)
        print("\(touchPoint.x)    \(touchPoint.y)")

        let offset : Float64 = 10

//        if self.player.timeControlStatus != .paused && self.player.timeControlStatus != .playing {
//            print("errorororororro")
//            return
//        }
        if let duration  = self.player.currentItem?.duration {
            var style = ToastStyle()
            style.backgroundColor = .clear
            style.messageFont = UIFont.systemFont(ofSize: 12)
            style.imageSize = CGSize(width: 30, height: 30)
            style.fadeDuration = 0.5
            style.messageAlignment = .natural
            
            let playerCurrentTime = CMTimeGetSeconds(self.player.currentTime())
            var newTime = CMTimeGetSeconds(self.player.currentTime())
                        
            if touchPoint.x < self.playervc.view.bounds.width / 2 {
                newTime = playerCurrentTime - offset
                self.playervc.view.makeToast("\(Int(offset)) seconds backward", duration: 1.0, point: CGPoint(x: self.toastViewX / 4, y: self.toastViewY / 2), title: "", image: nil, style: style, completion: nil)
            } else {
                newTime = playerCurrentTime + offset
                self.playervc.view.makeToast("\(Int(offset)) seconds forward", duration: 1.0, point: CGPoint(x: self.toastViewX * 3 / 4, y: self.toastViewY / 2), title: "", image: nil, style: style, completion: nil)
            }
            
            if newTime < CMTimeGetSeconds(duration)
            {
                let selectedTime: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
                self.player.seek(to: selectedTime)
            }
            self.player.pause()
            self.player.play()
        }
    }
    
    @objc func backAction(sender: UIBarButtonItem) {
        
        startActivityIndicator()
        let currentTime_double = self.player.currentItem?.currentTime().seconds
        var currentTime_int = 0
        if (currentTime_double?.isNaN)! {
            currentTime_int = 0
        } else {
            currentTime_int = Int(currentTime_double!)
        }
        let dict_param:[String:String] = ["videoId": self.selected_video!["num"] as! String, "userId": Global.user_id, "last_time": "\(currentTime_int)"]
        var data = [String]()
        for(key, value) in dict_param {
            data.append(key + "=\(value)")
        }
        let postString = data.map{String($0)}.joined(separator: "&")
        let url_string = Global.base_url + "last_seen.php"
        var request_url = URLRequest(url: URL(string: url_string)!)
        request_url.httpMethod = "POST"
        request_url.httpBody = postString.data(using: .utf8)
        
        self.player.pause()
        self.player.replaceCurrentItem(with: nil)
        
        let task = URLSession.shared.dataTask(with: request_url) { (data, response, error) in
            if error != nil {

            } else {
                let jsonData = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers);
                if let responseDic = jsonData as? Dictionary<String, AnyObject> {
                    if let result_status = responseDic["status"] as? String {
                        if result_status == "success" {
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                self.stopActivityIndicator()
                self.navigationController?.popViewController(animated: true)
            }
        }
        task.resume()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Global.avatar_url == "" {
            self.myavatarimageview.image = UIImage(named: "empty_avatar")
        } else {
            let url = URL(string: Global.avatar_url)!
            self.myavatarimageview.kf.setImage(with: url)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return self.timepicker_array.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.timepicker_array[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.timepicker_array[component][row]
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let strTitle = self.timepicker_array[component][row]
        let attString = NSAttributedString(string: strTitle, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        return attString
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
            case 0:
                self.selected_hour_string = self.timepicker_array[component][row]
            case 2:
                self.selected_min_string = self.timepicker_array[component][row]
            case 4:
                self.selected_sec_string = self.timepicker_array[component][row]
            default:
                break
        }
    }
    
    public func disconnectAVPlayer() {
        self.playervc.player = nil
    }

    public func reconnectAVPlayer() {
        self.playervc.player = player
    }
    
    func video_play(start_time: Int) {
        ////  video player
        let videoURL:NSURL = NSURL(string: self.selected_video!["url"] as! String)!
        self.player = AVPlayer(url: videoURL as URL)
        self.playervc.delegate = self
        self.playervc.player = player
        self.playervc.view.frame.size.width = self.videoView.frame.size.width
        self.playervc.view.frame.size.height = self.videoView.frame.size.height
        self.videoView.addSubview(self.playervc.view)
        self.addChild(self.playervc)
        let targetTime = CMTimeMake(value: Int64(start_time), timescale: 1)
        self.player.seek(to: targetTime)
        self.player.play()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.toastViewX = Int(self.playervc.view.bounds.width)
            self.toastViewY = Int(self.playervc.view.bounds.height)
        })
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        DispatchQueue.main.async() {
            self.toastViewX = Int(self.playervc.view.bounds.width)
            self.toastViewY = Int(self.playervc.view.bounds.height)
        }
    }
    
    func reload_commentTableView() {
        self.comment_array.removeAll()
        self.public_comment_array.removeAll()
        self.private_comment_array.removeAll()
        
        startActivityIndicator();
        
        var apiString = Global.base_url + "comment_list.php"
        let video_id = self.selected_video!["num"] as? String
        apiString += "?videoId=" + video_id! + "&userId=" + Global.user_id
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
                            if let public_response = responseDic["public"] as? [Dictionary<String, AnyObject>] {
                                var dic_array = public_response
                                for i in 0 ..< dic_array.count {
                                    dic_array[i]["status"] = "parent" as AnyObject
                                    self.public_comment_array.append(dic_array[i])
                                    if var answer = dic_array[i]["answer"] as? [Dictionary<String, Any>] {
                                        for j in 0 ..< answer.count {
                                            answer[j]["status"] = "child"
                                            self.public_comment_array.append(answer[j])
                                        }
                                    }
                                }
                            }
                            if let private_response = responseDic["private"] as? [Dictionary<String, AnyObject>] {
                                var dic_array = private_response
                                for i in 0 ..< dic_array.count {
                                    dic_array[i]["status"] = "parent" as AnyObject
                                    self.private_comment_array.append(dic_array[i])
                                    if var answer = dic_array[i]["answer"] as? [Dictionary<String, Any>] {
                                        for j in 0 ..< answer.count {
                                            answer[j]["status"] = "child"
                                            self.private_comment_array.append(answer[j])
                                        }
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
                self.publiccommentButton.backgroundColor = UIColor(red: 41/255, green: 41/255, blue: 41/255, alpha: 1.0)
                self.privatecommentButton.backgroundColor = UIColor.clear
                self.displying_commnetsType = "public"
                self.comment_array = self.public_comment_array
                self.commentTableView.reloadData()
            }
        }
        task.resume();
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
        if tableView == commentTableView {
            return self.comment_array.count
        } else {
            return self.video_array.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == commentTableView {
            return 80
        } else {
            return 100
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(tableView == commentTableView) {
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
            let current_playing_time = Int(self.comment_array[indexPath.row]["comment_time"] as! String)
            if current_playing_time == 0 {
                cell?.playtimeButton.isHidden = true
            } else {
                cell?.playtimeButton.isHidden = false
                let hour_time = current_playing_time! / 3600
                let min_time = (current_playing_time! % 3600) / 60
                let sec_time = (current_playing_time! - hour_time * 3600 - min_time * 60)
                var hour_time_string = ""
                var min_time_string = ""
                var sec_time_string = ""
                if hour_time < 10 {
                    hour_time_string = "0\(hour_time)"
                } else {
                    hour_time_string = "\(hour_time)"
                }
                if min_time < 10 {
                    min_time_string = "0\(min_time)"
                } else {
                    min_time_string = "\(min_time)"
                }
                if sec_time < 10 {
                    sec_time_string = "0\(sec_time)"
                } else {
                    sec_time_string = "\(sec_time)"
                }
                let playtime = hour_time_string + ":" + min_time_string + ":" + sec_time_string
                cell?.playtimeButton.setTitle(playtime, for: .normal)
                
                cell?.timeButtonAction = {
                    self.player.pause()
                    self.player.replaceCurrentItem(with: nil)
                    let playtime_string = self.comment_array[indexPath.row]["comment_time"] as! String
                    let playtime_int = Int(playtime_string)
                    self.video_play(start_time: playtime_int!)
                }
            }
            
            
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "videotableviewcell") as? VideoListTableViewCell
            cell!.selectionStyle = UITableViewCell.SelectionStyle.none
            
            if let imageurlstring = self.video_array[indexPath.row]["img"] as? String {
                let image_url = URL(string: imageurlstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
                cell?.videoimageview.kf.setImage(with: image_url)
            }
            
            let isFav = self.video_array[indexPath.row]["isFav"] as! Int
            if isFav == 0 {
                cell?.favorButton.setImage(UIImage(named: "favor_empty"), for: .normal)
            } else {
                cell?.favorButton.setImage(UIImage(named: "favor_full"), for: .normal)
            }
            cell?.videotitleTextView.text = (self.video_array[indexPath.row]["video_title"] as! String)
            cell?.favorButtonAction = nil
            if self.selected_video!["num"] as! String == self.video_array[indexPath.row]["num"] as! String {
                cell?.layer.borderWidth = 1;
                cell?.layer.borderColor = UIColor.lightGray.cgColor
                self.selectedIndexPath = indexPath
            } else {
                cell?.layer.borderWidth = 0;
                cell?.layer.borderColor = UIColor.lightGray.cgColor
            }
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.videolistTableView {
            
            startActivityIndicator()
            let currentTime_double = player.currentItem?.currentTime().seconds
            var currentTime_int = 0
            if (currentTime_double?.isNaN)! {
                currentTime_int = 0
            } else {
                currentTime_int = Int(currentTime_double!)
            }
            let dict_param:[String:String] = ["videoId": self.selected_video!["num"] as! String, "userId": Global.user_id, "last_time": "\(currentTime_int)"]
            var data = [String]()
            for(key, value) in dict_param {
                data.append(key + "=\(value)")
            }
            let postString = data.map{String($0)}.joined(separator: "&")
            let url_string = Global.base_url + "last_seen.php"
            var request_url = URLRequest(url: URL(string: url_string)!)
            request_url.httpMethod = "POST"
            request_url.httpBody = postString.data(using: .utf8)
            
            self.player.pause()
            self.player.replaceCurrentItem(with: nil)
            
            let task = URLSession.shared.dataTask(with: request_url) { (data, response, error) in
                if error != nil {
                    
                } else {
                    let jsonData = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers);
                    if let responseDic = jsonData as? Dictionary<String, AnyObject> {
                        if let result_status = responseDic["status"] as? String {
                            if result_status == "success" {
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.stopActivityIndicator()
                    let fist_selectedcell = self.videolistTableView.cellForRow(at: self.selectedIndexPath)!
                    fist_selectedcell.layer.borderWidth = 0;
                    fist_selectedcell.layer.borderColor = UIColor.lightGray.cgColor
                    let cell = self.videolistTableView.cellForRow(at: indexPath)!
                    cell.layer.borderWidth = 1;
                    cell.layer.borderColor = UIColor.lightGray.cgColor
                    self.video_array[self.selectedIndexPath.row]["last_seen"] = currentTime_int
                    
                    self.selected_video = self.video_array[indexPath.row]
                    self.video_play(start_time: self.video_array[indexPath.row]["last_seen"] as! Int)
                    self.reload_commentTableView()
                    self.publiccommentButton.backgroundColor = UIColor(red: 41/255, green: 41/255, blue: 41/255, alpha: 1.0)
                    self.privatecommentButton.backgroundColor = UIColor.clear
                    self.displying_commnetsType = "public"
                    
                    let isFav = self.selected_video!["isFav"] as! Int
                    if isFav == 0 {
                        self.favorButton.setImage(UIImage(named: "favor_empty"), for: .normal)
                    } else {
                        self.favorButton.setImage(UIImage(named: "favor_full"), for: .normal)
                    }
                    self.selectedIndexPath = indexPath
                }
            }
            task.resume()

        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView == self.videolistTableView {
            let cell = self.videolistTableView.cellForRow(at: indexPath)!
            cell.layer.borderWidth = 0;
            cell.layer.borderColor = UIColor.lightGray.cgColor
        }
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
    
    @IBAction func comment_typeButtonAction(_ sender: UIButton) {
        if sender == self.publiccommentButton {
            self.publiccommentButton.backgroundColor = UIColor(red: 41/255, green: 41/255, blue: 41/255, alpha: 1.0)
            self.privatecommentButton.backgroundColor = UIColor.clear
            self.displying_commnetsType = "public"
            self.comment_array = self.public_comment_array
            self.commentTableView.reloadData()
        } else if sender == self.privatecommentButton {
            self.publiccommentButton.backgroundColor = UIColor.clear
            self.privatecommentButton.backgroundColor = UIColor(red: 41/255, green: 41/255, blue: 41/255, alpha: 1.0)
            self.displying_commnetsType = "private"
            self.comment_array = self.private_comment_array
            self.commentTableView.reloadData()
        }
    }
    
    @IBAction func addcommentButtonAction(_ sender: Any) {
        self.scrollview.isHidden = false
    }
    
    func initalizeCommentBox() {
        self.commentTextView.text = "Comment"
        self.timePickerView.selectRow(0, inComponent: 0, animated: true)
        self.timePickerView.selectRow(0, inComponent: 2, animated: true)
        self.timePickerView.selectRow(0, inComponent: 4, animated: true)
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        self.initalizeCommentBox()
        self.scrollview.isHidden = true
    }
    
    @IBAction func saveButtonAction(_ sender: Any) {
        self.commentTableView.resignFirstResponder()
        let comment = self.commentTextView.text
        if comment == "Comment" {
            self.createAlert(title: "Warning!", message: "Please input comment.", type: false)
            return;
        }
        let picked_time = Int(self.selected_hour_string)! * 3600 + Int(self.selected_min_string)! * 60 + Int(self.selected_sec_string)!
        let currentDuration_double = self.player.currentItem?.duration.seconds
        var currentDuration_int = 0
        if (currentDuration_double?.isNaN)! {
            self.createAlert(title: "Warning!", message: "Please wait until video loading is finished.", type: false)
            return;
        } else {
            currentDuration_int = Int(currentDuration_double!)
        }
        if currentDuration_int < picked_time {
            self.createAlert(title: "Warning!", message: "Time is larger than video duration.", type: false)
            return;
        }
        startActivityIndicator();

        var comment_type = "0"
        if self.displying_commnetsType == "private" {
            comment_type = "1"
        } else if self.displying_commnetsType == "public" {
            comment_type = "0"
        }
        
        let dict_param:[String:String] = ["user_id": Global.user_id, "video_id": self.selected_video!["num"] as! String, "comment": comment!, "comment_type": comment_type, "comment_time": "\(picked_time)"]
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
                            let added_comment:[String: Any?] = ["num": "-1", "video_id": self.selected_video!["num"] as! String, "comment": comment!, "user_id": Global.user_id, "first_name": Global.firstname, "last_name": Global.lastname, "created_on": "", "profile_pic": Global.avatar_url, "comment_type": comment_type, "comment_time": "\(picked_time)", "answer": nil, "status": "parent"]
                            if self.displying_commnetsType == "private" {
                                self.private_comment_array.insert(added_comment as [String : Any], at: 0)
                                self.comment_array = self.private_comment_array
                            } else if self.displying_commnetsType == "public" {
                                self.public_comment_array.insert(added_comment as [String : Any], at: 0)
                                self.comment_array = self.public_comment_array
                            }
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                self.stopActivityIndicator()
                self.commentTableView.reloadData()
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
                self.initalizeCommentBox()
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
