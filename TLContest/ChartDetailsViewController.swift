//
//  ChartDetailsViewController.swift
//  TLContest
//
//  Created by Dmitry Grebenschikov on 11/03/2019.
//  Copyright © 2019 dd-team. All rights reserved.
//

import UIKit

class ChartDetailsViewController: UIViewController, ViewControllerWithTable {
    
    weak var tableView: UITableView!
    var chart: Chart!
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        createTableView()
        tableView.isScrollEnabled = false
        
        let overview = DGChartOverview(frame: .zero)
        overview.translatesAutoresizingMaskIntoConstraints = false
        
        
    }
    
    func registerCells() {
        
    }
    
    
}

extension ChartDetailsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
}

extension ChartDetailsViewController: UITableViewDelegate {
    
}
