//
//  ViewController.swift
//  TLContest
//
//  Created by Dmitry Grebenschikov on 11/03/2019.
//  Copyright © 2019 dd-team. All rights reserved.
//

import UIKit

protocol ViewControllerWithTable: class {
    var tableView: UITableView! { get set }
    func createTableView()
    func registerCells()
}

extension ViewControllerWithTable where Self: UITableViewDelegate, Self: UITableViewDataSource, Self: UIViewController {
    func createTableView() {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView = tableView
        
        registerCells()
        
        tableView.bindToSuperView()
    }
}

extension UIView {
    func bindToSuperView(with insets: UIEdgeInsets = .zero) {
        guard let superView = self.superview else { return }
        
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: superView.topAnchor, constant: insets.top),
            self.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: -insets.bottom),
            self.trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: insets.right),
            self.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: insets.left)
            ])
    }
}

class ViewController: UIViewController, ViewControllerWithTable {
    
    weak var tableView: UITableView!
    weak var loadingIndicator: UIActivityIndicatorView?
    var charts = [Chart]()
    let queue = DispatchQueue(label: "TableQueue", qos: .default, attributes: DispatchQueue.Attributes.concurrent)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select a chart"
        createTableView()
        startLoading()
        queue.async {
            let data = (try? DataParser().parseFile(named: "chart_data")) ?? []
            DispatchQueue.main.async { [weak self] in
                self?.charts = data
                self?.stopLoading()
                self?.tableView.reloadData()
            }
        }
    }
    
    func registerCells() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func startLoading() {
        let indicator = UIActivityIndicatorView(style: .whiteLarge)
        indicator.color = .black
        view.addSubview(indicator)
        indicator.center = view.center
        self.loadingIndicator = indicator
        indicator.startAnimating()
    }
    
    func stopLoading() {
        loadingIndicator?.stopAnimating()
        loadingIndicator?.removeFromSuperview()
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return charts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = "Chart #\(indexPath.section + 1)"
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 20))
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let chart = charts[indexPath.section]
        let vc = ChartDetailsViewController.init(nibName: nil, bundle: nil)
        vc.chart = chart
        navigationController?.pushViewController(vc, animated: true)
    }
}
