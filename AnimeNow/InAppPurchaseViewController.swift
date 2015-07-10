//
//  InAppPurchaseViewController.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 7/7/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import RMStore
import ANCommonKit

class InAppPurchaseViewController: UITableViewController {

    var loadingView: LoaderView!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var proButton: UIButton!
    @IBOutlet weak var proPlusButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Aozora Pro"
        
        loadingView = LoaderView(parentView: view)
        
        updateViewForPurchaseState()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateViewForPurchaseState", name: PurchasedProNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setPrices", name: PurchasedProNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func updateViewForPurchaseState() {
        if let _ = InAppPurchaseController.purchasedAnyPro() {
            descriptionLabel.text = "Thanks for supporting Aozora! You're an exclusive Pro member that is helping me create an even better app"
        } else {
            descriptionLabel.text = "Browse all seasonal charts, unlock calendar view, discover more anime, remove all ads forever, and more importantly helps us take Aozora to the next level"
        }
    }
    
    func fetchProducts() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        loadingView.startAnimating()
        let products: Set = [ProInAppPurchase, ProPlusInAppPurchase]
        RMStore.defaultStore().requestProducts(products, success: { (products, invalidProducts) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.setPrices()
            self.loadingView.stopAnimating()
        }) { (error) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            var alert = UIAlertController(title: "Products Request Failed", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
            self.loadingView.stopAnimating()
        }
    }
    
    func setPrices() {
        
        if let _ = InAppPurchaseController.purchasedPro() {
            proButton.setTitle("Unlocked", forState: .Normal)
        } else {
            let product = RMStore.defaultStore().productForIdentifier(ProInAppPurchase)
            let localizedPrice = RMStore.localizedPriceOfProduct(product)
            proButton.setTitle(localizedPrice, forState: .Normal)
        }
        
        if let _ = InAppPurchaseController.purchasedProPlus(){
            proPlusButton.setTitle("Unlocked", forState: .Normal)
        } else {
            let product = RMStore.defaultStore().productForIdentifier(ProPlusInAppPurchase)
            let localizedPrice = RMStore.localizedPriceOfProduct(product)
            proPlusButton.setTitle(localizedPrice, forState: .Normal)
        }
    }
    
    func purchaseProductWithID(productID: String) {
        InAppPurchaseController.purchaseProductWithID(productID).continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
            
            var alert = UIAlertController(title: "Purchased!", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
            
            return nil
        }
    }
    
    @IBAction func buyProPressed(sender: AnyObject) {
        purchaseProductWithID(ProInAppPurchase)
    }
    
    @IBAction func buyProPlusPressed(sender: AnyObject) {
        purchaseProductWithID(ProPlusInAppPurchase)
    }
    
}
