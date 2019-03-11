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
        tableView.backgroundColor = .white
        
        let overview = DGChartOverview(frame: .zero)
        view.addSubview(overview)
        
        overview.translatesAutoresizingMaskIntoConstraints = false
        overview.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        overview.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        overview.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        overview.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        overview.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        overview.displayChart(chart)
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
