//
//  loadingScene.swift
//  newblackjack
//
//  Created by Kohei Nakai on 2017/06/17.
//  Copyright © 2017年 NakaiKohei. All rights reserved.
//

import SpriteKit
import GameplayKit

class loadingScene: SKScene {
	
	
	let Label = SKLabelNode(fontNamed: "HiraginoSans-W6")
	
	var last:CFTimeInterval!  //前に更新した時間
	
	let queue = DispatchQueue.main//メインスレッド
	
	
	override func didMove(to view: SKView) {
		
		backgroundColor=SKColor.init(red: 0.8, green: 0.3, blue: 0.3, alpha: 0.3)
		Label.text = "Now loading..."
		Label.fontSize = 20
		Label.position = CGPoint(x:self.frame.maxX - 100, y:self.frame.minY + 20)
		self.addChild(Label)
		
	}
	
	override func update(_ currentTime: CFTimeInterval) {
		
		
		
		// Called before each frame is rendered
		// lastが未定義ならば、今の時間を入れる。
		if last == nil{
			last = currentTime
		}
		
		// 3秒おきに行う処理をかく。
		if last + 1 <= currentTime  {
			queue.async {
				
				net().receiveData()
				
				if Cards.state=="ready"{
					Cards.state="p1turn"
					net().sendData()	//初期手札を受信したということを送信
					
					if net.dealer==2{
						let gameScene:Netp1Scene = Netp1Scene(size: self.view!.bounds.size) // create your new scene
						let transition = SKTransition.fade(withDuration: 1.0) // create type of transition (you can check in documentation for more transtions)
						gameScene.scaleMode = SKSceneScaleMode.fill
						self.view!.presentScene(gameScene, transition: transition) //Netp1Sceneに移動
					}else if net.dealer==1{
						let gameScene:Netp2Scene = Netp2Scene(size: self.view!.bounds.size) // create your new scene
						let transition = SKTransition.fade(withDuration: 1.0) // create type of transition (you can check in documentation for more transtions)
						gameScene.scaleMode = SKSceneScaleMode.fill
						self.view!.presentScene(gameScene, transition: transition) //Netp2Sceneに移動
					}else{
						print("dealerの値が\(net.dealer)です。")
						exit(1)
					}
					
					
				}
				
				
				self.last = currentTime
			}
		}
		
		
		
	}

	
	
}
