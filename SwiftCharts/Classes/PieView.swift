//
//  PieView.swift
//  PersonalNote
//
//  Created by 钟凡 on 16/8/2.
//  Copyright © 2016年 钟凡. All rights reserved.
//

import UIKit

public class PieView: UIView {
    let legendHeight:CGFloat = 22
    var shapeWidth:CGFloat = 10
    var lastEndAg:CGFloat = 0.0
    var lineWidth:CGFloat = 40
    var totalValue:Float = 0
    var width:CGFloat = 0
    var height:CGFloat = 0
    var radius:CGFloat = 0
    var arcCenter:CGPoint = .zero
    lazy var tapPaths:[UIBezierPath] = [UIBezierPath]()
    lazy var linePaths:[UIBezierPath] = [UIBezierPath]()
    lazy var sublayers:[CAShapeLayer] = [CAShapeLayer]()
    lazy var centerLabel:CATextLayer = CATextLayer()
    var centerPath:UIBezierPath?
    
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
        shapeWidth = 10
        width = bounds.size.width
        height = bounds.size.height
        radius = height * 0.2
        arcCenter = CGPoint(x: width * 0.5, y: height * 0.5)
        lastEndAg = 0.0
        totalValue = 0
        centerPath = nil
        layer.sublayers = nil
        sublayers.removeAll()
        tapPaths.removeAll()
        linePaths.removeAll()
        layer.removeAllAnimations()
    }
    public func showEmptyAnimation() {
        reset()
        
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
    func drawCenter() {
        // 中间总数
        centerPath = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
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
    public func drawIconPie(_ dicts:[(icon: UIImage?, name:String, value:Float, color:UIColor)]){
        reset()
        shapeWidth = 22
        for dict in dicts {
            totalValue += dict.value
        }
        for (i,dict) in dicts.enumerated() {
            let color = dict.color
            let percent = dict.value / totalValue
            let angle = CGFloat(percent) * CGFloat.pi * 2
            let name = dict.name
            let sectorName = String(format: "%.f%%", percent * 100)
            let icon = dict.icon
            drawLegend(icon, name, color, i)
            drawSector(sectorName, lastEndAg, lastEndAg + angle, color, percent)
        }
        drawCenter()
    }
    public func drawPurePie(_ dicts:[(name:String, value:Float, color:UIColor)]){
        reset()
        for dict in dicts {
            totalValue += dict.value
        }
        
        for (i,dict) in dicts.enumerated() {
            let color = dict.color
            let percent = dict.value / totalValue
            let angle = CGFloat(percent) * CGFloat.pi * 2
            let name = dict.name
            let sectorName = String(format: "%.f%%", percent * 100)
            drawLegend(name, color, i)
            drawSector(sectorName, lastEndAg, lastEndAg + angle, color, percent)
        }
        drawCenter()
    }
    func drawLegendLabel(_ name:String,  _ index:Int) {
        let fontSize:CGFloat = 18
        let legend = CATextLayer()
        let legendWidth = CGFloat(name.count) * fontSize
        let legendPosition = CGPoint(x: 12 + shapeWidth, y: 8 + legendHeight * CGFloat(index))
        let legendFrame = CGRect(origin: legendPosition, size: CGSize(width: legendWidth, height: legendHeight))
        
        legend.frame = legendFrame
        legend.string = name
        legend.fontSize = fontSize
        
        legend.foregroundColor = UIColor.darkGray.cgColor
        legend.contentsScale = UIScreen.main.scale
        layer.addSublayer(legend)
    }
    func drawLegend(_ icon: UIImage?, _ name:String, _ color:UIColor, _ index:Int){
        drawLegendLabel(name, index)
        let shapePosition = CGPoint(x: 8, y: 8 + legendHeight * CGFloat(index) + (legendHeight - shapeWidth)  * 0.5)
        let shapeFrame = CGRect(origin: shapePosition, size: CGSize(width: shapeWidth, height: shapeWidth))
        
        // 图标
        let shape = CALayer()
        shape.contents = icon?.setTintColor(color)?.cgImage
        shape.frame = shapeFrame
        layer.addSublayer(shape)
    }
    func drawLegend(_ name:String, _ color:UIColor, _ index:Int){
        drawLegendLabel(name, index)
        let shapePosition = CGPoint(x: 8, y: 8 + legendHeight * CGFloat(index) + (legendHeight - shapeWidth)  * 0.5)
        let shapeFrame = CGRect(origin: shapePosition, size: CGSize(width: shapeWidth, height: shapeWidth))
        
        // 圆点
        let shape = CAShapeLayer()
        let rectPath = UIBezierPath(ovalIn: CGRect(origin: .zero, size: CGSize(width: shapeWidth, height: shapeWidth)))
        shape.frame = shapeFrame
        shape.path = rectPath.cgPath
        shape.strokeColor = UIColor.clear.cgColor //UIColor.clear.cgColor
        shape.fillColor = color.cgColor
        layer.addSublayer(shape)
    }
    ///这里为什么没有设置beginTime设置时差，因为只有最后一个有动画
    fileprivate func drawSector(_ name:String, _ startAg: CGFloat, _ endAg: CGFloat, _ color: UIColor, _ percent: Float) {
        lastEndAg = endAg
        
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
extension UIImage {
    func setTintColor(_ color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        color.setFill()
        let rect = CGRect(origin: .zero, size: size)
        UIRectFill(rect)
        self.draw(in: rect, blendMode: .destinationIn, alpha: 1)
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tintedImage
    }
}
