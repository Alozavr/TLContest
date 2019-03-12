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
        title = "Statistics"

    }
    
    func registerCells() {
        tableView.register(ChartOverviewCell.self, forCellReuseIdentifier: "ChartOverviewCell")
        tableView.register(LineInfoCell.self, forCellReuseIdentifier: "LineInfoCell")
    }
}

extension ChartDetailsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0, indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChartOverviewCell") as! ChartOverviewCell
            cell.setChart(chart)
            return cell
        } else if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LineInfoCell") as! LineInfoCell
            let line = chart.lines[indexPath.row - 1]
            cell.configure(color: line.color, text: line.name, isChecked: line.isVisible)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chart.lines.count + 1
    }
}

extension ChartDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard indexPath.section == 0, indexPath.row > 0 else { return }
        let cell = tableView.cellForRow(at: indexPath) as? LineInfoCell
        let line = chart.lines[indexPath.row - 1]
        cell?.setIsChecked(!line.isVisible)
        let newLine = Line.init(id: line.id, name: line.name, values: line.values, color: line.color, isVisible: !line.isVisible)
        var newLines = chart.lines
        newLines[indexPath.row - 1] = newLine
        chart = Chart(dateAxis: chart.dateAxis, lines: newLines)
        
        guard let overviewCell = tableView.visibleCells.first(where: { $0 is ChartOverviewCell }) as? ChartOverviewCell else { return }
//        overviewCell.chartView.overview.setLineVisible(newLine: newLine)
        overviewCell.chartView.overview.refresh(chart: chart)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0, indexPath.row == 0 {
            return 200 + 64
        } else if indexPath.section == 0 {
            return 44
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 { return "FOLLOWERS" }
        return nil
    }
}
