//
//  ViewController.swift
//  animation-demo
//
//  Created by Seven on 2022/8/19.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    private lazy var cloud1 = makeCloud()
    private lazy var cloud2 = makeCloud()
    private var c1Contraint: Constraint?
    var c2Contraint: Constraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        c2Contraint?.update(offset: -100)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        c1Contraint?.update(offset: 10)
        
        UIView.animate(withDuration: 1.0) { [weak self] in
            self?.view.layoutIfNeeded()
            
        }
        
        c2Contraint?.update(offset: 0)
        
        UIView.animate(withDuration: 1.0, delay: 0.7, options: [.repeat, .autoreverse, .curveEaseOut]) { [weak self] in
            self?.view.layoutIfNeeded()
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        cloud1.layer.cornerRadius = cloud1.bounds.size.width / 2
        cloud2.layer.cornerRadius = cloud2.bounds.size.width / 2
    }

    private func setupViews(){
        
        view.addSubview(cloud1)
        
        cloud1.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(40)
            c1Contraint = $0.size.equalTo(50).constraint
        }
        
        
        view.addSubview(cloud2)
        
        cloud2.snp.makeConstraints {
            $0.top.equalToSuperview().inset(60)
            c2Contraint = $0.trailing.equalToSuperview().constraint
            $0.size.equalTo(60)
        }
        
    }
    
    // MARK: - Factories
    
    private func makeCloud() -> UIView {
        let view = UIView()
        view.backgroundColor = .blue
        
        return view
    }
    
}

