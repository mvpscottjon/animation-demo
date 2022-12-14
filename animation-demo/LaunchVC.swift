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
    private let customShapeScales = [0.7, 0.9, 0.7, 1.2, 0.7, 1.25]
    private let catJumpsAnimationDuration = 1.0
    private let catJumpEndPointOffsetX = 50.0
    private let catJumpControlPointOffsetY = -70.0
    private let isCatJumpingRight = BehaviorRelay<Bool>(value: true)
    private let needsFlipCatImage = PublishRelay<Void>()
    /// The `CGRect` as a temp frame for `catImageView`.
    /// In order to re-assign frame when flip image(It will change `catImageView` when flip image).
    private var cacheCatFrame = CGRect.zero
    private var catTimer: Disposable?
    private var labelTimer: Disposable?

    private let bag = DisposeBag()
    
    private lazy var logoLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 30.0)
        label.text = "Animation Demo"
        return label
    }()
    
    private lazy var circleView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray.withAlphaComponent(0.9)
                
        return view
    }()
    
    private lazy var customShapeView: UIView = {
        let view = CustomShapeView()
        return view
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
        runAllAnimations()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        circleView.layer.cornerRadius = circleView.frame.width / 2
    }
    
    deinit {
        catTimer?.dispose()
        labelTimer?.dispose()
    }
    
    private func setupViews() {
        
        view.addSubview(customShapeView)
        customShapeView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(300)
        }
        
        view.addSubview(circleView)
        circleView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(250)
        }
        
        view.addSubview(logoLabel)
        logoLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }
        
        view.addSubview(catImageView)
        catImageView.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(30)
            $0.leading.equalToSuperview()
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
//                let imageWidth = 0.0

                // `catImageView` should add imageWidth to check if over right edge
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
                let imageWidth = 0.0
                return frame.minX + imageWidth / 2  <= self.view.frame.minY
            }
            .map { !$1 }
            .bind(to: isCatJumpingRight)
            .disposed(by: bag)
        
        isCatJumpingRight.distinctUntilChanged().map { _ in }.bind(to: needsFlipCatImage).disposed(by: bag)
        
        needsFlipCatImage
            .subscribe(with: self, onNext: { `self`, _ in
                self.catTimer?.dispose()
                self.cacheCatFrame = self.catImageView.frame
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    self.flipCatImage() {
                        // After flip image, must re-assign old frame for `catImageView`, otherwise, `catImageView`'s
                        // frame will become original frame(imageView initial frame).
                        self.catImageView.frame = self.cacheCatFrame
                        // Need to run
                        self.catJumpAnimation()
                    }
                })
            })
            .disposed(by: bag)
    }
    
    // MARK: - Animation
    
    private func runAllAnimations() {
        logoLabelScrollToCenterAnimation()
        shapeViewAnimation()
        catJumpAnimation()
    }
    
    private func logoLabelScrollToCenterAnimation() {
        logoLabel.alpha = 0.0
        logoLabel.transform = CGAffineTransform(translationX: 0, y: -self.view.safeAreaLayoutGuide.layoutFrame.minY)

        UIView.animate(withDuration: 1.5) {
            self.logoLabel.transform = .identity
            self.logoLabel.alpha = 1.0
        }
    }

    private func shapeViewAnimation() {
        // must dispose timer before assign, prevent create timer more than one
        labelTimer?.dispose()
        
        labelTimer = Observable<Int>
            .timer(.seconds(0), period: .milliseconds(1000), scheduler: MainScheduler.instance)
            .subscribe(with:self, onNext: { `self`, time in
                let scaleIndex = time % self.customShapeScales.count
                guard self.customShapeScales.count > scaleIndex else { return }
                
                let scale = self.customShapeScales[scaleIndex]
                UIView.animate(withDuration: 1.0) {
                    self.customShapeView.transform = CGAffineTransform(scaleX: scale, y: scale)
                }
            })
    }
    
    private func catJumpAnimation() {
        // must dispose timer before assign, prevent create timer more than one
        catTimer?.dispose()
        
        catTimer = Observable<Int>
            .timer(.seconds(0), period: .milliseconds(1000), scheduler: MainScheduler.instance)
            .subscribe(with:self, onNext: { `self`, _ in
                let isCatJumpingRight = self.isCatJumpingRight.value
                let endPointOffsetX = isCatJumpingRight ? self.catJumpEndPointOffsetX : -self.catJumpEndPointOffsetX
                self.catJumps(
                    withEndPointOffsetX: endPointOffsetX,
                    controlPointOffsetY: self.catJumpControlPointOffsetY
                )
            })
    }
    
    private func catJumps(withEndPointOffsetX endPointOffsetX: CGFloat, controlPointOffsetY: CGFloat) {
        // If offsetX is positive means jump to right
        // If offsetY is positive means jump to down
        let originPoint = CGPoint(x: catImageView.frame.minX, y: catImageView.frame.minY)
        let endPoint = CGPoint(x: originPoint.x + endPointOffsetX, y: originPoint.y)
        let curveControlPoint = CGPoint(
            x: originPoint.x + (endPointOffsetX / 2),
            y: originPoint.y + controlPointOffsetY
        )
        
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
        self.catImageView.frame.origin = endPoint
    }
    
    private func flipCatImage(completion: (() -> ())? = nil) {
        UIView.animate(
            withDuration: 1.0,
            animations: {
                self.catImageView.image = self.catImageView.image?.withHorizontallyFlippedOrientation()
            },
            completion: { _ in
                completion?()
            }
        )
    }
}
