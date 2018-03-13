//
//  ScenicLocationTableViewController.swift
//  ScenicMap
//
//  Created by Yi Jiang on 13/3/18.
//  Copyright © 2018 Siphty. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ScenicLocationTableViewController: UITableViewController {

    fileprivate let disposeBag = DisposeBag()
    var viewModel: ScenicLocationViewModel? {
        didSet {
            bindViewModel()
        }
    }
    var selectedCellIndexPath: IndexPath?
    @IBOutlet weak var refreshBarbuttonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        setupUI()
        viewModel = ScenicLocationViewModel(ApiClient())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTableViewDetailsViewSegue" {
            if let destinationVC = segue.destination as? ScenicDetailsViewController {
                guard let selectedCellIndexPath = selectedCellIndexPath else { return }
                guard let cell = tableView.cellForRow(at: selectedCellIndexPath) as? ScenicLocationTableViewCell else { return }
                guard let scenic = cell.scenic else { return }
                destinationVC.scenic = scenic
                destinationVC.title = cell.scenicName.text
            }
        }
    }
    
    fileprivate func setupUI() {
        tableView.register(ScenicLocationTableViewCell.nib(), forCellReuseIdentifier: "ScenicLocationTableViewCell")
        
        // MARK: set up tableview cell selected action
        tableView.rx.itemSelected
            .subscribe(onNext: { indexPath in
                self.selectedCellIndexPath = indexPath
                self.performSegue(withIdentifier: "ShowTableViewDetailsViewSegue", sender: self)
            }).disposed(by: disposeBag)
        
        refreshBarbuttonItem.rx.tap.asObservable().subscribe(onNext: { () in
            self.viewModel?.updateScenicLocation()
        }, onError: { error in
            print("error: \(error.localizedDescription)")
        }, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }

    fileprivate func bindViewModel() {
        tableView.dataSource = nil
        viewModel?.locations.asObservable().bind(to: tableView.rx.items(cellIdentifier: "ScenicLocationTableViewCell", cellType: ScenicLocationTableViewCell.self)) { (_, scenic, cell) in
            cell.configureCell(scenic)
        }.disposed(by: disposeBag)
        
    }
}
