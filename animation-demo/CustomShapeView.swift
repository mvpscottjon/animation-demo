//
//  CustomShapeView.swift
//  animation-demo
//
//  Created by Seven on 2022/8/23.
//

import UIKit

class CustomShapeView: UIView {
    private lazy var shapeLayer = makeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(makeLayer())
    }
    
    init() {
        super.init(frame: .zero)
        layer.addSublayer(shapeLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        shapeLayer.position = .zero
    }
    
    private func makeLayer() -> CALayer {
        let startPoint = CGPoint(x: 170, y: 0.0)
        let path = UIBezierPath()

        path.move(to: startPoint)
        let length = 300.0
        
        // right-top
        let endPoint1 = CGPoint(x: length, y: 150.0)
        let cPoint1 = CGPoint(x: length, y: 0.0)

        path.addQuadCurve(to: endPoint1, controlPoint: cPoint1)
        let endPoint2 = CGPoint(x: 230 , y: 270)
        let cPoint2 = CGPoint(x: length, y: length)

        path.addQuadCurve(to: endPoint2, controlPoint: cPoint2)

        let endPoint3 = CGPoint(x: 130, y: 300.0)
        let cPoint3 = CGPoint(x: 150.0, y: length)

        path.addQuadCurve(to: endPoint3, controlPoint: cPoint3)

        let endPoint4 = CGPoint(x: 50.0, y: 270.0)
        let cPoint4 = CGPoint(x: 30.0, y: length)
        path.addQuadCurve(to: endPoint4, controlPoint: cPoint4)

        let endPoint5 = CGPoint(x: 0.0, y: 150.0)
        let cPoint5 = CGPoint(x: 0.0, y: 270)
        path.addQuadCurve(to: endPoint5, controlPoint: cPoint5)
        
        let endPoint6 = CGPoint(x: 30.0, y: 70.0)
        let cPoint6 = CGPoint(x: 0.0, y: 100)
        path.addQuadCurve(to: endPoint6, controlPoint: cPoint6)
        
        let endPoint7 = CGPoint(x: 50.0, y: 20.0)
        let cPoint7 = CGPoint(x: 20.0, y: 20.0)
        path.addQuadCurve(to: endPoint7, controlPoint: cPoint7)
        
        let endPoint8 = CGPoint(x: 100.0, y: 0.0)
        let cPoint8 = CGPoint(x: 60.0, y: 0.0)
        path.addQuadCurve(to: endPoint8, controlPoint: cPoint8)
        
        path.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.lightGray.cgColor
        shapeLayer.lineWidth = 2.0
        shapeLayer.opacity = 0.3
        return shapeLayer
    }

}
