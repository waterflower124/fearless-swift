//
//  VideoListViewController.swift
//  Fearless
//
//  Created by Water Flower on 2019/4/24.
//  Copyright © 2019 Water Flower. All rights reserved.
//

import UIKit
import Kingfisher

class VideoListViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var videoTableView: UITableView!
    
    ///////   for activity indicator  //////////
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView();
    var overlayView:UIView = UIView();
    
    var selected_item: Dictionary<String, Any>?
    
    var video_array = [Dictionary<String, Any>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = self.selected_item!["title"] as? String
        
        addSlideMenuButton()
        
        self.videoTableView.separatorStyle = .none
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        startActivityIndicator();
        
        var apiString = Global.base_url + "video_list.php"
        let sub_cate_id = self.selected_item!["num"] as? String
        apiString += "?sub_cat_id=" + sub_cate_id! + "&userId=" + Global.user_id
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
                            self.video_array = (responseDic["data"] as? [Dictionary<String, AnyObject>])!
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
                self.videoTableView.reloadData()
            }
        }
        task.resume();
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.video_array.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 200
        } else {
            return 100
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "videolisttableviewcell") as? VideoListTableViewCell
        cell!.selectionStyle = UITableViewCell.SelectionStyle.none

        if let imageurlstring = self.video_array[indexPath.row]["img"] as? String {
            let image_url = URL(string: imageurlstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
            cell?.videoimageview.kf.setImage(with: image_url)
        } else {
            
        }
        
        let isFav = self.video_array[indexPath.row]["isFav"] as! Int
        let video_id = self.video_array[indexPath.row]["num"] as? String
        var dict_param = Dictionary<String, Any>()
        if isFav == 0 {
            cell?.favorButton.setImage(UIImage(named: "favor_empty"), for: .normal)
            dict_param = ["userId": Global.user_id, "videoId": video_id!, "isFav": "1"]
        } else {
            cell?.favorButton.setImage(UIImage(named: "favor_full"), for: .normal)
            dict_param = ["userId": Global.user_id, "videoId": video_id!, "isFav": "0"]
        }
        cell?.videotitleTextView.text = (self.video_array[indexPath.row]["video_title"] as! String)
        cell?.favorButtonAction = {

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
                        if cell?.favorButton.currentImage == UIImage(named: "favor_empty") {
                            cell?.favorButton.setImage(UIImage(named: "favor_full"), for: .normal)
                            self.video_array[indexPath.row].updateValue(1, forKey: "isFav")
                        } else {
                            cell?.favorButton.setImage(UIImage(named: "favor_empty"), for: .normal)
                            self.video_array[indexPath.row].updateValue(0, forKey: "isFav")
                        }
                    }
                }
            }
            task.resume()
            
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            var mainStoryboard = UIStoryboard()
            if UIDevice.current.userInterfaceIdiom == .pad {
                mainStoryboard = UIStoryboard(name: "MainiPad", bundle: nil)
            } else {
                mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            }
            let videoplayerVC = mainStoryboard.instantiateViewController(withIdentifier: "VideoPlayeriPadViewController") as! VideoPlayeriPadViewController
            videoplayerVC.selected_video = self.video_array[indexPath.row]
            videoplayerVC.passVC = "videolistVC"
            videoplayerVC.video_array = self.video_array
            self.navigationController?.pushViewController(videoplayerVC, animated: true)
        } else {
            var mainStoryboard = UIStoryboard()
            if UIDevice.current.userInterfaceIdiom == .pad {
                mainStoryboard = UIStoryboard(name: "MainiPad", bundle: nil)
            } else {
                mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            }
            let videoplayerVC = mainStoryboard.instantiateViewController(withIdentifier: "VideoPlayerViewController") as! VideoPlayerViewController
            videoplayerVC.selected_video = self.video_array[indexPath.row]
            videoplayerVC.passVC = "videolistVC"
            self.navigationController?.pushViewController(videoplayerVC, animated: true)
        }
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
