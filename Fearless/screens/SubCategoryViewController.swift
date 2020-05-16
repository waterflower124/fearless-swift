//
//  SubCategoryViewController.swift
//  Fearless
//
//  Created by Water Flower on 2019/4/24.
//  Copyright © 2019 Water Flower. All rights reserved.
//

import UIKit
import Kingfisher

class SubCategoryViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var subcategoryTableView: UITableView!
    ///////   for activity indicator  //////////
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView();
    var overlayView:UIView = UIView();
    
    var selected_subcate: Dictionary<String, Any>?
    var record_array = [Dictionary<String, Any>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = self.selected_subcate!["title"] as? String
        
        addSlideMenuButton()
        
        self.subcategoryTableView.separatorStyle = .none
        
        startActivityIndicator();
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        var apiString = Global.base_url + "sub_category_list.php"
        let num = self.selected_subcate!["num"] as? String
        apiString += "?num=" + num!
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
                            self.record_array = (responseDic["data"] as? [Dictionary<String, AnyObject>])!
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
                self.subcategoryTableView.reloadData()
            }
        }
        task.resume();
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.record_array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subcategorytableviewcell") as? CategoryTableViewCell
        cell?.outlineView.layer.cornerRadius = 5
        cell?.outlineView.layer.borderWidth = 1
        cell?.outlineView.layer.borderColor = UIColor.white.cgColor
        
        cell!.selectionStyle = UITableViewCell.SelectionStyle.none
        
        cell?.countTextField.text = String(describing: self.record_array[indexPath.row]["count"] as! Int)
        cell?.titleLabel.text = self.record_array[indexPath.row]["title"] as? String

        if let imageurlstring = self.record_array[indexPath.row]["img"] as? String {
            let image_url = URL(string: imageurlstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
            cell?.imageview.kf.setImage(with: image_url)
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var mainStoryboard = UIStoryboard()
        if UIDevice.current.userInterfaceIdiom == .pad {
            mainStoryboard = UIStoryboard(name: "MainiPad", bundle: nil)
        } else {
            mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        }
        let videolistVC = mainStoryboard.instantiateViewController(withIdentifier: "VideoListViewController") as! VideoListViewController
        videolistVC.selected_item = self.record_array[indexPath.row]
        self.navigationController?.pushViewController(videolistVC, animated: true)
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
