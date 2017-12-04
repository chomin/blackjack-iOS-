//
//  ScrollNode.swift
//  newblackjack
//
//  Created by Kohei Nakai on 2017/12/03.
//  Copyright © 2017年 NakaiKohei. All rights reserved.
//

import SpriteKit

class ScrollNode: SKSpriteNode {
	
    	var contentNode = SKNode()
	private var startX: CGFloat = 0.0
	private var lastX: CGFloat = 0.0
	// タッチされているかどうか
	private var touching = false
	// 少しずつ移動させる
	private var lastScrollDistX: CGFloat = 0.0
	
	init(size: CGSize ,position:CGPoint) {
		super.init(texture: nil, color: SKColor.clear, size: size)
		
		self.isUserInteractionEnabled = true
		
		self.position = position
		self.addChild(self.contentNode)
		
//		// スクロールさせるコンテンツ
//		let myLabel = SKLabelNode(fontNamed: "Helvetica")
//		myLabel.text = "scroll"
//		myLabel.fontSize = 20
//		self.contentNode.addChild(myLabel)
	}
	
	
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		
		// store the starting position of the touch
		let touch = touches.first
		let location = touch!.location(in: self)
		
//		if location.y > self.size.height  || location.y < 0{
//			return
//		}
		
		startX = location.x
		lastX = location.x
		
		self.touching = true
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//		if !self.touching {
//			return
//		}
		
		let touch = touches.first
		let location = touch!.location(in: self)
		
		// set the new location of touch
		let currentX = location.x
		
		lastScrollDistX =  lastX - currentX
		
		self.contentNode.position.x -= lastScrollDistX
		
		// Set new last location for next time
		lastX = currentX
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.touching = false
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
		self.touching = false
	}
	
	func update(currentTime: CFTimeInterval) {
		// タッチされてたらupdateを実行しない
		guard !touching else {
			return
		}
		
		// 左と右端の設定
		let limitFactor: CGFloat = 0.3
		let leftLimitX: CGFloat = self.size.width * (-limitFactor)
		let rightLimitX: CGFloat = self.size.width * limitFactor
		if self.contentNode.position.x < leftLimitX {
			// 行き過ぎたから戻す
			self.contentNode.position.x = leftLimitX
			lastScrollDistX = 0.0
			return
		}
		if self.contentNode.position.x > rightLimitX {
			// 行き過ぎたから戻す
			self.contentNode.position.x = rightLimitX
			lastScrollDistX = 0.0
			return
		}
		
		// 慣性処理
		var slowDown: CGFloat = 0.98
		if fabs(lastScrollDistX) < 0.5 {
			slowDown = 0.0
		}
		lastScrollDistX *= slowDown
		self.contentNode.position.x -= lastScrollDistX
	}
}
