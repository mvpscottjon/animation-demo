//
//  LaunchVC.swift
//  animation-demo
//
//  Created by Seven on 2022/8/19.
//

import UIKit
import RxCocoa
import RxSwift

class LaunchVC: UIViewController {
    private let catJumpsAnimationDuration = 1.0
    private let catJumpOffsetX = 50.0
    private var isCatJumpingRight = BehaviorRelay<Bool>(value: true)
    private var timer: Disposable?
    private let bag = DisposeBag()
    
    private lazy var logoLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 30.0)
        label.text = "Animation Demo"
        return label
    }()
    
    private lazy var catImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "cat1")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bindUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        runAnimation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    deinit {
        timer?.dispose()
    }
    
    private func setupViews() {
        let button = UIButton()
        button.setTitle("Animate", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .orange
        
        view.addSubview(button)
        button.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
                
        view.addSubview(logoLabel)
        logoLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(70)
            $0.leading.trailing.equalToSuperview()
        }
        
        view.addSubview(catImageView)
        catImageView.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(30)
            $0.leading.equalToSuperview().inset(50)
            $0.size.equalTo(50)
        }
    }
    
    private func bindUI() {
        catImageView.rx.observe(CGRect.self, #keyPath(UIView.frame))
            .distinctUntilChanged()
            .withLatestFrom(isCatJumpingRight) { ($0, $1)}
            .filter { [weak self] (frame, isCatJumpingRight) in
                guard let frame = frame, let self = self, isCatJumpingRight else { return false }
                let imageWidth = self.catImageView.frame.width
                // catImageView should add imageWidth to check if over right edge
                return frame.maxX + imageWidth  >= self.view.frame.maxX
            }
            .map { !$1 }
            .bind(to: isCatJumpingRight)
            .disposed(by: bag)
            
        catImageView.rx.observe(CGRect.self, #keyPath(UIView.frame))
            .distinctUntilChanged()
            .withLatestFrom(isCatJumpingRight) { ($0, $1)}
            .filter { [weak self] (frame, isCatJumpingRight) in
                guard let frame = frame, let self = self, !isCatJumpingRight else { return false }
                return frame.minX  <= self.view.frame.minY
            }
            .map { !$1 }
            .bind(to: isCatJumpingRight)
            .disposed(by: bag)
    }
    
    private func runAnimation() {
        logoLabelScrollUpAnimation()
        
        // must dispose timer before assign, prevent create timer more than one
        timer?.dispose()
        
        timer = Observable<Int>
            .timer(.seconds(0), period: .milliseconds(1000), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.catJumpAnimation()
            })
    }
    
    // MARK: - Animation
    
    private func logoLabelScrollUpAnimation() {
        logoLabel.alpha = 0.0
        self.logoLabel.transform = CGAffineTransform(translationX: 0, y: self.view.center.y)
        
        UIView.animate(withDuration: 1.2, delay: 0.0, options: []) {
            self.logoLabel.transform = .identity
            self.logoLabel.alpha = 1.0
        }
    }
    
    private func catJumpAnimation() {
        let isCatJumpingRight = isCatJumpingRight.value
        if  isCatJumpingRight {
            catJumpsRight()
        } else {
            catJumpsLeft()
        }
    }
    
    private func catJumpsRight() {
        let originPoint = CGPoint(x: catImageView.frame.minX, y: catImageView.frame.minY)
        let endPoint = CGPoint(x: originPoint.x + catJumpOffsetX, y: originPoint.y)
        let curveControlPoint = CGPoint(x: originPoint.x + (catJumpOffsetX / 2), y: originPoint.y - 70.0)
        
        let posAnimation = CAKeyframeAnimation(keyPath: #keyPath(CALayer.position))
        posAnimation.duration = catJumpsAnimationDuration
        posAnimation.isRemovedOnCompletion = false
        posAnimation.fillMode = .forwards
        
        let path = UIBezierPath()
        path.move(to: originPoint)
        path.addQuadCurve(to: endPoint, controlPoint: curveControlPoint)
        
        posAnimation.path = path.cgPath
        // need to set target layer anchorPoint to (0.0, 0.0)
        catImageView.layer.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        
        catImageView.layer.add(posAnimation, forKey: nil)
        // set endPoint to target view from really change view's frame
        catImageView.frame.origin = endPoint
    }
    
    private func catJumpsLeft() {
        let originPoint = CGPoint(x: catImageView.frame.minX, y: catImageView.frame.minY)
        let endPoint = CGPoint(x: originPoint.x - catJumpOffsetX, y: originPoint.y)
        let curveControlPoint = CGPoint(x: originPoint.x + (-catJumpOffsetX / 2), y: originPoint.y - 70.0)
        
        let posAnimation = CAKeyframeAnimation(keyPath: #keyPath(CALayer.position))
        posAnimation.duration = catJumpsAnimationDuration
        posAnimation.isRemovedOnCompletion = false
        posAnimation.fillMode = .forwards
        
        let path = UIBezierPath()
        path.move(to: originPoint)
        path.addQuadCurve(to: endPoint, controlPoint: curveControlPoint)
        
        posAnimation.path = path.cgPath
        // need to set target layer anchorPoint to (0.0, 0.0)
        catImageView.layer.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        
        catImageView.layer.add(posAnimation, forKey: nil)
        // set endPoint to target view from really change view's frame
        catImageView.frame.origin = endPoint
    }
}
