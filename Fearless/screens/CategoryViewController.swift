//
//  CategoryViewController.swift
//  Fearless
//
//  Created by Water Flower on 2019/4/23.
//  Copyright © 2019 Water Flower. All rights reserved.
//

import UIKit
import Kingfisher

class CategoryViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var categoryTableView: UITableView!
    
    ///////   for activity indicator  //////////
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView();
    var overlayView:UIView = UIView();
    
    var record_array = [Dictionary<String, Any>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Category"
        self.navigationItem.hidesBackButton = true
        
        addSlideMenuButton()
        
        self.categoryTableView.separatorStyle = .none
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        startActivityIndicator();
        
        var apiString = Global.base_url + "assign_cat.php"
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
                            self.record_array = (responseDic["data"] as? [Dictionary<String, AnyObject>])!
                        } else {
                            
                        }
                    } else {
                        
                    }
                } else {
                    print("json pass error")
                }
            } else {
                print("netowrk error")
            }
            DispatchQueue.main.async {
                self.stopActivityIndicator()
                self.categoryTableView.reloadData()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "categorytableviewcell") as? CategoryTableViewCell
        cell?.outlineView.layer.cornerRadius = 5
        cell?.outlineView.layer.borderWidth = 1
        cell?.outlineView.layer.borderColor = UIColor.white.cgColor
        
        cell!.selectionStyle = UITableViewCell.SelectionStyle.none
        
        cell?.countTextField.text = String(describing: self.record_array[indexPath.row]["count"] as! Int)
        cell?.titleLabel.text = self.record_array[indexPath.row]["title"] as? String
        let image_url = URL(string: self.record_array[indexPath.row]["img"] as! String)!
        cell?.imageview.kf.setImage(with: image_url)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let subcategoryVC = mainStoryboard.instantiateViewController(withIdentifier: "SubCategoryViewController") as! SubCategoryViewController
        subcategoryVC.selected_subcate = self.record_array[indexPath.row]
        self.navigationController?.pushViewController(subcategoryVC, animated: true)
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
