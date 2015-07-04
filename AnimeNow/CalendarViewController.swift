//
//  CalendarViewController.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 7/4/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import ANParseKit
import SDWebImage
import Alamofire
import ANCommonKit
import XLPagerTabStrip
import Bolts

class CalendarViewController: XLButtonBarPagerTabStripViewController {
    
    var weekdayStrings: [String] = []
    
    var dayViewControllers: [DayViewController] = []

    var airingDataSource: [[Anime]] = [] {
        didSet {
            updateControllersDataSource()
        }
    }
   
    var loadingView: LoaderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isProgressiveIndicator = true
        self.buttonBarView.selectedBar.backgroundColor = UIColor.peterRiver()
        
        loadingView = LoaderView(parentView: self.view)
        
        loadingView.startAnimating()
        fetchAiring()

    }
    
    func updateControllersDataSource() {
        
        
        
        for index in 0..<7 {
            let controller = dayViewControllers[index]
            let dayDataSource = airingDataSource[index]
            
            controller.updateDataSource(dayDataSource)
        }

    }
    
    func fetchAiring() {
        
        let query = Anime.query()!
        query.whereKeyExists("startDateTime")
        query.whereKey("status", equalTo: "currently airing")
        query.findObjectsInBackgroundWithBlock({ (result, error) -> Void in
            
            if let result = result as? [Anime] {
                
                var animeByWeekday: [[Anime]] = [[],[],[],[],[],[],[]]
                
                let calendar = NSCalendar.currentCalendar()
                let unitFlags: NSCalendarUnit = NSCalendarUnit.CalendarUnitWeekday
                
                for anime in result {
                    let startDateTime = anime.nextEpisodeDate
                    let dateComponents = calendar.components(unitFlags, fromDate: startDateTime)
                    let weekday = dateComponents.weekday-1
                    animeByWeekday[weekday].append(anime)
                    
                }
                
                var todayWeekday = calendar.components(unitFlags, fromDate: NSDate()).weekday - 1
                while (todayWeekday > 0) {
                    var currentFirstWeekdays = animeByWeekday[0]
                    animeByWeekday.removeAtIndex(0)
                    animeByWeekday.append(currentFirstWeekdays)
                    todayWeekday -= 1
                }
                
                self.airingDataSource = animeByWeekday
            }
            
            self.loadingView.stopAnimating()
        })
        
    }
    
    @IBAction func dismissViewControllerPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

extension CalendarViewController: XLPagerTabStripViewControllerDataSource {
    override func childViewControllersForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController!) -> [AnyObject]! {
        
        let storyboard = UIStoryboard(name: "Season", bundle: nil)
        
        // Set weekday strings
        let calendar = NSCalendar.currentCalendar()
        let today = NSDate()
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "eeee, MMM dd"
        for daysAhead in 0..<7 {
            let date = calendar.dateByAddingUnit(NSCalendarUnit.CalendarUnitDay, value: daysAhead, toDate: today, options: nil)
            let dateString = dateFormatter.stringFromDate(date!)
            weekdayStrings.append(dateString)
            
            // Instatiate view controller
            var controller = storyboard.instantiateViewControllerWithIdentifier("DayList") as! DayViewController
            controller.initWithTitle(dateString)
            dayViewControllers.append(controller)
        }
        
        return dayViewControllers
    }
}

extension CalendarViewController: UINavigationBarDelegate {
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }
}