//
//  FavoritesViewController.swift
//  Fearless
//
//  Created by Water Flower on 2019/4/23.
//  Copyright © 2019 Water Flower. All rights reserved.
//

import UIKit
import Kingfisher

class FavoritesViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var videoTableView: UITableView!
    
    ///////   for activity indicator  //////////
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView();
    var overlayView:UIView = UIView();
    
    var video_array = [Dictionary<String, Any>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Favorites"
        self.navigationItem.hidesBackButton = true
        
        addSlideMenuButton()
        
        self.videoTableView.separatorStyle = .none
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        startActivityIndicator();
        
        var apiString = Global.base_url + "isFav.php"
        apiString += "?userId=" + Global.user_id
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
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "videolisttableviewcell") as? VideoListTableViewCell
        cell!.selectionStyle = UITableViewCell.SelectionStyle.none
        
        let image_url = URL(string: self.video_array[indexPath.row]["img"] as! String)!
        cell?.videoimageview.kf.setImage(with: image_url)

        cell?.favorButton.setImage(UIImage(named: "favor_full"), for: .normal)
        cell?.videotitleTextView.text = (self.video_array[indexPath.row]["video_title"] as! String)
        cell?.favorButtonAction = {
            let video_id = self.video_array[indexPath.row]["num"] as? String
            let dict_param:[String:String] = ["userId": Global.user_id, "videoId": video_id!, "isFav": "0"]
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
                        self.video_array.remove(at: indexPath.row)
                        self.videoTableView.reloadData()

                    }
                }
            }
            task.resume()
            
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let videoplayerVC = mainStoryboard.instantiateViewController(withIdentifier: "VideoPlayerViewController") as! VideoPlayerViewController
        videoplayerVC.selected_video = self.video_array[indexPath.row]
        videoplayerVC.passVC = "favorVC"
        self.navigationController?.pushViewController(videoplayerVC, animated: true)
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
