//
//  ViewController.swift
//  PIPDemo
//
//  Created by Zhen,Lintie on 2020/11/13.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    let disposeBag = DisposeBag()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return tableView
    }()
    
    var dataSource: Observable<[(String, String)]> = .just([
        ("CCTV1 高清", "http://ivi.bupt.edu.cn/hls/cctv1hd.m3u8"),
        ("惊奇队长", "http://vfx.mtime.cn/Video/2019/02/04/mp4/190204084208765161.mp4")
    ])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.height.equalToSuperview()
        }
        
        dataSource.bind(to: tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)) { (row, element, cell) in
            cell.textLabel?.text = element.0
        }
        .disposed(by: disposeBag)
        
        tableView.rx.modelSelected((String, String).self)
        .subscribe(onNext: { [weak self] model in
            guard let self = self else { return }
            self.present(PlayerViewController(url: model.1), animated: true, completion: nil)
        })
        .disposed(by: disposeBag)
        
    }


}

