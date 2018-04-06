//
//  PieView.swift
//  PersonalNote
//
//  Created by 钟凡 on 16/8/2.
//  Copyright © 2016年 钟凡. All rights reserved.
//

import UIKit

public class PieView: UIView {
    var lastEndAg:CGFloat = 0.0
    var lineWidth:CGFloat = 40
    lazy var tapPaths:[UIBezierPath] = [UIBezierPath]()
    lazy var linePaths:[UIBezierPath] = [UIBezierPath]()
    lazy var sublayers:[CAShapeLayer] = [CAShapeLayer]()
    lazy var centerLabel:CATextLayer = CATextLayer()
    var centerPath:UIBezierPath?
    // 动画 1
    lazy var basic0: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "path")
        let width = bounds.size.width
        let height = bounds.size.height
        let radius = height * 0.2
        let arcWidth = height * 0.2
        
        let arcCenter = CGPoint(x: width * 0.5, y: height * 0.5)
        let fromPath = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: 1, endAngle: 1, clockwise: true)
        let toPath = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: 1, endAngle: CGFloat.pi, clockwise: true)
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 1
        return animation
    }()
    // 动画 1
    lazy var strokeEnd: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 1
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        
        return animation
    }()
    lazy var rotateAnimation:CABasicAnimation = {
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.fromValue = 0
        rotation.toValue = Double.pi * 2
        rotation.duration = 4
        rotation.beginTime = CACurrentMediaTime() + 2
        return rotation
    }()
    // 动画 2
    lazy var basic2: CAKeyframeAnimation = {
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        
        animation.values = [0, 0.2, 0, 0.2, 0]
        animation.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
        animation.duration = 1.5
        animation.isAdditive = true
        
        return animation
    }()
    // 加载动画
    var loaddingAnimation: CAAnimationGroup {
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.fromValue = 0
        rotation.toValue = Double.pi * 2
        rotation.duration = 4
        rotation.beginTime = 0
        
        let strokeStart = CABasicAnimation(keyPath: "strokeStart")
        strokeStart.fromValue = 0
        strokeStart.toValue = 1
        strokeStart.duration = 2
        strokeStart.beginTime = 2
        
        let strokeEnd = CABasicAnimation(keyPath: "strokeEnd")
        strokeEnd.fromValue = 0
        strokeEnd.toValue = 1
        strokeEnd.duration = 2
        strokeEnd.beginTime = 0
        
        let group = CAAnimationGroup()
        group.duration = 4
        group.animations = [rotation, strokeStart, strokeEnd]
        group.fillMode = kCAFillModeBackwards
        group.repeatCount = .greatestFiniteMagnitude
        
        return group
    }
    
    func reset() {
        lastEndAg = 0.0
        layer.sublayers = nil
        centerPath = nil
        sublayers.removeAll()
        tapPaths.removeAll()
        linePaths.removeAll()
        layer.removeAllAnimations()
    }
    public func showEmptyAnimation() {
        reset()
        let width = bounds.size.width
        let height = bounds.size.height
        let arcCenter = CGPoint(x: width * 0.5, y: height * 0.5)
        let radius = height * 0.2
        
        let path = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        let arc = CAShapeLayer()
        arc.frame = self.bounds
        arc.path = path.cgPath
        arc.strokeColor = UIColor.red.cgColor
        arc.fillColor = UIColor.clear.cgColor
        arc.lineWidth = 1
        
        arc.add(loaddingAnimation, forKey: "loaddingAnimation")
        layer.addSublayer(arc)
    }
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let point = touches.first?.location(in: self)
        for (i, subLayer) in sublayers.enumerated() {
            let tapPath = tapPaths[i]
            if point != nil && tapPath.contains(point!) && !centerPath!.contains(point!) {
                let positionAnimation = CAKeyframeAnimation(keyPath: "position")
                positionAnimation.path = linePaths[i].cgPath
                positionAnimation.duration = 0.1
                positionAnimation.isRemovedOnCompletion = false
                positionAnimation.fillMode = kCAFillModeForwards
                
                let widthAnimation = CABasicAnimation(keyPath: "lineWidth")
                widthAnimation.fromValue = lineWidth
                widthAnimation.toValue = lineWidth * 1.2
                widthAnimation.duration = 0.1
                widthAnimation.isRemovedOnCompletion = false
                widthAnimation.fillMode = kCAFillModeForwards
                
                subLayer.add(widthAnimation, forKey: "widthAnimation")
                subLayer.add(positionAnimation, forKey: "positionAnimation")
                centerLabel.string = subLayer.name
                print(subLayer)
            }else {
                subLayer.removeAllAnimations()
            }
        }
    }
    public func drawSectors(_ dicts:[(name:String, percent:Float, color:UIColor)]){
        reset()
        let width = bounds.size.width
        let height = bounds.size.height
        let arcCenter = CGPoint(x: width * 0.5, y: height * 0.5)
        
        for (i,dict) in dicts.enumerated() {
            let color = dict.color
            let percent = dict.percent
            let angle = CGFloat(percent) * CGFloat.pi * 2
            let name = dict.name
            
            drawLegend(name, color, i)
            drawSector(name, lastEndAg, lastEndAg + angle, color, percent)
        }
        
        // 中间总数
        centerPath = UIBezierPath(arcCenter: arcCenter, radius: height * 0.2, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        let circle = CAShapeLayer()
        circle.path = centerPath?.cgPath
        circle.fillColor = UIColor.white.cgColor
        
        centerLabel.frame = CGRect(origin: .zero, size: CGSize(width: width * 0.5, height: 22))
        centerLabel.position = arcCenter
        centerLabel.contentsScale = UIScreen.main.scale
        centerLabel.fontSize = 20
        centerLabel.alignmentMode = kCAAlignmentCenter
        centerLabel.foregroundColor = UIColor.darkGray.cgColor
        centerLabel.string = "---"
        circle.addSublayer(centerLabel)
        layer.addSublayer(circle)
    }
    func drawLegend(_ name:String, _ color:UIColor, _ index:Int){
        let fontSize:CGFloat = 18
        let legend = CATextLayer()
        let legendWidth = CGFloat(name.count) * fontSize
        let legendHeight:CGFloat = 22
        let shapeWidth:CGFloat = 10
        let shapePosition = CGPoint(x: 8, y: 8 + legendHeight * CGFloat(index) + (legendHeight - shapeWidth)  * 0.5)
        let legendPosition = CGPoint(x: 12 + shapeWidth, y: 8 + legendHeight * CGFloat(index))
        let legendFrame = CGRect(origin: legendPosition, size: CGSize(width: legendWidth, height: legendHeight))
        let shapeFrame = CGRect(origin: shapePosition, size: CGSize(width: 40, height: legendHeight))
        
        legend.frame = legendFrame
        legend.string = name
        legend.fontSize = fontSize
        legend.foregroundColor = UIColor.darkGray.cgColor
//        legend.backgroundColor = color.cgColor
        legend.contentsScale = UIScreen.main.scale
        
        let shape = CAShapeLayer()
        let rectPath = UIBezierPath(ovalIn: CGRect(origin: .zero, size: CGSize(width: shapeWidth, height: shapeWidth)))
        shape.frame = shapeFrame
        shape.path = rectPath.cgPath
        shape.strokeColor = UIColor.clear.cgColor //UIColor.clear.cgColor
        shape.fillColor = color.cgColor
        layer.addSublayer(shape)
        layer.addSublayer(legend)
    }
    ///这里为什么没有设置beginTime设置时差，因为只有最后一个有动画
    fileprivate func drawSector(_ name:String, _ startAg: CGFloat, _ endAg: CGFloat, _ color: UIColor, _ percent: Float) {
        lastEndAg = endAg
        let width = bounds.size.width
        let height = bounds.size.height
        let radius = height * 0.2
        let arcCenter = CGPoint(x: width * 0.5, y: height * 0.5)
        
        //点击后位移的路径
        let linePath = UIBezierPath()
        linePath.move(to: arcCenter)
        let midAg = (startAg + endAg) * 0.5
        linePath.addLine(to: CGPoint(x: arcCenter.x + cos(midAg) * 5, y: arcCenter.y +  sin(midAg) * 5))
        linePaths.append(linePath)
        //可点击区域路径
        let tapPath = UIBezierPath()
        tapPath.move(to: arcCenter)
        tapPath.addArc(withCenter: arcCenter, radius: radius + lineWidth * 0.5, startAngle: startAg, endAngle: endAg, clockwise: true)
        tapPath.addLine(to: arcCenter)
        tapPaths.append(tapPath)
        //添加CAShapeLayer
        let arc = CAShapeLayer()
        let arcPath = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: startAg, endAngle: endAg, clockwise: true)
        arc.frame = bounds
        arc.name = name
        arc.path = arcPath.cgPath
        arc.strokeColor = color.cgColor //UIColor.clear.cgColor
        arc.fillColor = UIColor.clear.cgColor
        arc.lineWidth = lineWidth
        arc.add(strokeEnd, forKey: "strokeEnd")
        sublayers.append(arc)
        layer.insertSublayer(arc, at: 0)
    }
}
