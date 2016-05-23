//
//  ChartViewController.swift
//  Sinai App
//
//  Created by Zachary Bernstein on 5/23/16.
//  Copyright © 2016 Zachary Bernstein. All rights reserved.

import ResearchKit

class ChartViewController: UIViewController
{
    
    @IBOutlet var pieChartView: ORKPieChartView!
    let dataSource = PieChartDataSource.sharedPieChartDataSource
    override func viewDidLoad() {
        
        _ = self.view
        pieChartView.dataSource = dataSource
    }
    required init?(coder aDecoder:NSCoder)
    {
        super.init(coder:aDecoder)
    }
    
    
    @IBAction func addToData(sender: AnyObject) {
        
        PieChartDataSource.sharedPieChartDataSource.values[0] += 10.0
        pieChartView.reloadData()
        print(PieChartDataSource.sharedPieChartDataSource.values)
    }
    
    
    
    
    
}