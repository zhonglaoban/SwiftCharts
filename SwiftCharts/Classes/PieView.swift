//
//  PieView.swift
//  PersonalNote
//
//  Created by 钟凡 on 16/8/2.
//  Copyright © 2016年 钟凡. All rights reserved.
//

import UIKit

public class PieView: UIView {
    let legendHeight:CGFloat = 30
    var shapeWidth:CGFloat = 10
    ///记录上一个扇形的结束角度
    var lastEndAg:CGFloat = 0.0
    ///扇形的宽度
    var lineWidth:CGFloat = 40
    ///保存总计的值
    var totalValue:Float = 0
    ///PieView的宽度
    var width:CGFloat = 0
    ///PieView的高度
    var height:CGFloat = 0
    ///饼图path的半径
    var radius:CGFloat = 0
    ///饼图的中心
    var arcCenter:CGPoint = .zero
    ///计算好的点击区域
    lazy var tapPaths:[UIBezierPath] = [UIBezierPath]()
    ///点击后位移动画的路线
    lazy var linePaths:[UIBezierPath] = [UIBezierPath]()
    ///饼图所有的扇形
    lazy var sublayers:[CAShapeLayer] = [CAShapeLayer]()
    ///中间显示的文字
    lazy var centerLabel:CATextLayer = CATextLayer()
    ///中间圆形的区域
    var centerPath:UIBezierPath?
    
    /// 画扇形的动画
    lazy var strokeEnd: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 1
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        
        return animation
    }()
    /// 加载动画
    lazy var loaddingAnimation: CAAnimationGroup = {
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
    }()
    ///扇形位移动画
    lazy var sectorPositionAnimation:CAKeyframeAnimation = {
        let position = CAKeyframeAnimation(keyPath: "position")
        position.duration = 0.1
        position.isRemovedOnCompletion = false
        position.fillMode = kCAFillModeForwards
        return position
    }()
    ///扇形宽度动画
    lazy var sectorWidthAnimation:CABasicAnimation = {
        let sector = CABasicAnimation(keyPath: "lineWidth")
        sector.duration = 0.1
        sector.isRemovedOnCompletion = false
        sector.fillMode = kCAFillModeForwards
        return sector
    }()
    ///重置属性，移除图层等
    func reset() {
        shapeWidth = 10
        width = bounds.size.width
        height = bounds.size.height
        radius = height * 0.2
        arcCenter = CGPoint(x: width * 0.5, y: height * 0.5)
        lastEndAg = 0.0
        totalValue = 0
        centerPath = nil
        sublayers.removeAll()
        tapPaths.removeAll()
        linePaths.removeAll()
        layer.sublayers = nil
        layer.removeAllAnimations()
    }
    ///点击事件
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let point = touches.first?.location(in: self)
        for (i, subLayer) in sublayers.enumerated() {
            let tapPath = tapPaths[i]
            if point != nil && centerPath != nil && tapPath.contains(point!) && !centerPath!.contains(point!) {
                sectorWidthAnimation.fromValue = lineWidth
                sectorWidthAnimation.toValue = lineWidth * 1.2
                subLayer.add(sectorWidthAnimation, forKey: "sectorWidthAnimation")
                if sublayers.count > 1 {
                    sectorPositionAnimation.path = linePaths[i].cgPath
                    subLayer.add(sectorPositionAnimation, forKey: "sectorPositionAnimation")
                }
                centerLabel.string = subLayer.name
                print(subLayer)
            }else {
                subLayer.removeAllAnimations()
            }
        }
    }
    ///没有数据时显示的动画
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
    ///画带图标的图例
    public func drawIconPie(_ dicts:[(icon: UIImage?, name:String?, value:Float, color:UIColor)]){
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
    ///根据（名称，值，颜色）画饼图
    public func drawPurePie(_ dicts:[(name:String?, value:Float, color:UIColor)]){
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
    /// 中间图层
    func drawCenter() {
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
        centerLabel.string = "100%"
        circle.addSublayer(centerLabel)
        layer.addSublayer(circle)
    }
    func drawLegendLabel(_ name:String?,  _ index:Int) {
        let fontSize:CGFloat = 18
        let labelHeight:CGFloat = 22
        let legend = CATextLayer()
        let legendWidth = CGFloat(name?.count ?? 0) * fontSize
        let legendPosition = CGPoint(x: 12 + shapeWidth, y: 8 + legendHeight * CGFloat(index) + (legendHeight - labelHeight)  * 0.5)
        let legendFrame = CGRect(origin: legendPosition, size: CGSize(width: legendWidth, height: labelHeight))
        
        legend.frame = legendFrame
        legend.string = name
        legend.fontSize = fontSize
        
        legend.foregroundColor = UIColor.darkGray.cgColor
        legend.contentsScale = UIScreen.main.scale
        layer.addSublayer(legend)
    }
    func drawLegend(_ icon: UIImage?, _ name:String?, _ color:UIColor, _ index:Int){
        drawLegendLabel(name, index)
        let shapePosition = CGPoint(x: 8, y: 8 + legendHeight * CGFloat(index) + (legendHeight - shapeWidth)  * 0.5)
        let shapeFrame = CGRect(origin: shapePosition, size: CGSize(width: shapeWidth, height: shapeWidth))
        
        /// 图标
        let shape = CALayer()
        shape.contents = icon?.setTintColor(color)?.cgImage
        shape.frame = shapeFrame
        layer.addSublayer(shape)
    }
    func drawLegend(_ name:String?, _ color:UIColor, _ index:Int){
        drawLegendLabel(name, index)
        let shapePosition = CGPoint(x: 8, y: 8 + legendHeight * CGFloat(index) + (legendHeight - shapeWidth)  * 0.5)
        let shapeFrame = CGRect(origin: shapePosition, size: CGSize(width: shapeWidth, height: shapeWidth))
        
        /// 圆点
        let shape = CAShapeLayer()
        let rectPath = UIBezierPath(ovalIn: CGRect(origin: .zero, size: CGSize(width: shapeWidth, height: shapeWidth)))
        shape.frame = shapeFrame
        shape.path = rectPath.cgPath
        shape.strokeColor = UIColor.clear.cgColor ///UIColor.clear.cgColor
        shape.fillColor = color.cgColor
        layer.addSublayer(shape)
    }
    ///画每一片扇形
    fileprivate func drawSector(_ name:String?, _ startAg: CGFloat, _ endAg: CGFloat, _ color: UIColor, _ percent: Float) {
        lastEndAg = endAg
        
        ///点击后位移的路径
        let linePath = UIBezierPath()
        linePath.move(to: arcCenter)
        let midAg = (startAg + endAg) * 0.5
        linePath.addLine(to: CGPoint(x: arcCenter.x + cos(midAg) * 5, y: arcCenter.y +  sin(midAg) * 5))
        linePaths.append(linePath)
        ///可点击区域路径
        let tapPath = UIBezierPath()
        tapPath.move(to: arcCenter)
        tapPath.addArc(withCenter: arcCenter, radius: radius + lineWidth * 0.5, startAngle: startAg, endAngle: endAg, clockwise: true)
        tapPath.addLine(to: arcCenter)
        tapPaths.append(tapPath)
        ///添加CAShapeLayer
        let arc = CAShapeLayer()
        let arcPath = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: startAg, endAngle: endAg, clockwise: true)
        arc.frame = bounds
        arc.name = name
        arc.path = arcPath.cgPath
        arc.strokeColor = color.cgColor ///UIColor.clear.cgColor
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
