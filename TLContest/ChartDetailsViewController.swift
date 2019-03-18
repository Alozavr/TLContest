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
        tableView.backgroundColor = Colors.shared.backgroundColor
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        title = "Statistics"
        tableView.setupThemeNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ThemeManager.shared.setupTheme()
    }
    
    func registerCells() {
        tableView.register(ChartOverviewCell.self, forCellReuseIdentifier: "ChartOverviewCell")
        tableView.register(LineInfoCell.self, forCellReuseIdentifier: "LineInfoCell")
        tableView.register(ButtonCell.self, forCellReuseIdentifier: "ButtonCell")
    }
}

extension ChartDetailsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
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
        } else if indexPath.section == 1, indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonCell") as! ButtonCell
            cell.configure(texts: [.light: "Switch to Night Mode", .dark: "Switch to Day Mode"])
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return chart.lines.count + 1
        case 1:
            return 1
        default:
            return 0
        }
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
        overviewCell.setChart(chart)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0, indexPath.row == 0 {
            return 200 + 64 + 32
        } else if indexPath.section == 0 {
            return 44
        } else if indexPath.section == 1, indexPath.row == 0 {
            return 60
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 { return "FOLLOWERS" }
        else if section == 1 { return "" }
        return nil
    }
}

// MARK: - UIGestureRecognizerDelegate

extension ChartDetailsViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
