//
//  IAPService.swift
//  Fearless
//
//  Created by Water Flower on 2019/5/6.
//  Copyright © 2019 Water Flower. All rights reserved.
//

import Foundation
import StoreKit

class IAPService: NSObject {
    private override init() {}
    static let shared = IAPService()
    
    var products = [SKProduct]()
    let paymentQueue = SKPaymentQueue.default()
    
    func getProducts() {
        let products: Set = [IAPProduct.nonconsumable.rawValue, IAPProduct.nonconsumable.rawValue]
        let request = SKProductsRequest(productIdentifiers: products)
        request.delegate = self
        request.start()
        paymentQueue.add(self)
    }
    
    func purchase(product: IAPProduct) {
        guard let productToPurchase = products.filter({$0.productIdentifier == product.rawValue}).first else {return}
        let payment = SKPayment(product: productToPurchase)
        paymentQueue.add(payment)
    }
    
    func restorePurchase() {
        print("restore purchase...")
        paymentQueue.restoreCompletedTransactions()
    }

}

extension IAPService: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print(response.products)
        print("ssss")
        self.products = response.products
        for product in response.products {
            print(product.localizedDescription)
        }
    }
}

extension IAPService: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            print(transaction.transactionState)
            print(transaction.transactionState.status(), transaction.payment.productIdentifier)
            switch transaction.transactionState {
                case .purchasing: break
                case .purchased:
                    var apiString = Global.base_url + "savePurchase.php"
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
                                        
                                    } else {
                                    }
                                } else {
                                }
                            }
                        } else {
                        }
                        DispatchQueue.main.async {
                            
                        }
                    }
                    task.resume();
                default: queue.finishTransaction(transaction)
            }
        }
    }
}

extension SKPaymentTransactionState {
    func status() -> String {
        switch self {
            case .deferred: return "deferred"
            case .failed: return "failed"
            case .purchased: return "purchased"
            case .purchasing: return "purchasing"
            case .restored: return "restored"
        }
    }
}
