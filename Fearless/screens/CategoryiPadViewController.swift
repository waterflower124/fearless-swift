//
//  CategoryiPadViewController.swift
//  Fearless
//
//  Created by Water Flower Mac on 2019/5/27.
//  Copyright © 2019 Water Flower. All rights reserved.
//

import UIKit

class CategoryiPadViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var categoryCollectionView: UICollectionView!
    
    ///////   for activity indicator  //////////
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView();
    var overlayView:UIView = UIView();
    
    var record_array = [Dictionary<String, Any>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Category"
        self.navigationItem.hidesBackButton = true
        
        addSlideMenuButton()
        
        let layout = self.categoryCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        layout.minimumInteritemSpacing = 20
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.width - 40) / 2, height: 200)
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
                //                self.categoryTableView.reloadData()
                self.categoryCollectionView.reloadData()
            }
        }
        task.resume();
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.record_array.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CategoryCollectionViewCell
        cell.outlineView.layer.cornerRadius = 5
        cell.outlineView.layer.borderWidth = 1
        cell.outlineView.layer.borderColor = UIColor.white.cgColor
        cell.countTextField.text = String(describing: self.record_array[indexPath.row]["count"] as! Int)
        let image_url = URL(string: self.record_array[indexPath.row]["img"] as! String)!
        cell.titleLabel.text = self.record_array[indexPath.row]["title"] as? String
        if let imageurlstring = self.record_array[indexPath.row]["img"] as? String {
            let image_url = URL(string: imageurlstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
            cell.itemImageView.kf.setImage(with: image_url)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let mainStoryboard = UIStoryboard(name: "MainiPad", bundle: nil)
            let subcategoryVC = mainStoryboard.instantiateViewController(withIdentifier: "SubCategoryiPadViewController") as! SubCategoryiPadViewController
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
