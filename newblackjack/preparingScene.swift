//
//  preparingScene.swift
//  newblackjack
//
//  Created by Kohei Nakai on 2017/06/17.
//  Copyright © 2017年 NakaiKohei. All rights reserved.
//



import SpriteKit
import GameplayKit

class preparingScene: SKScene { //先攻後攻を決め、配り、送信する→該当のシーンへ
	
	
	let Label = SKLabelNode(fontNamed: "HiraginoSans-W6")
	
	
	
	var last:CFTimeInterval!  //前に更新した時間
	
	let queue = DispatchQueue.main//メインスレッド
	
	
	override func didMove(to view: SKView) {
		
		
		
		
		self.backgroundColor=SKColor.init(red: 0.8, green: 0.3, blue: 0.3, alpha: 0.3)
		self.Label.text = "Now loading..."
		self.Label.fontSize = 20
		self.Label.position = CGPoint(x:self.frame.maxX - 100, y:self.frame.minY + 20)
		self.addChild(self.Label)
		
		net.dealer=Int(arc4random_uniform(2))+1	//1~2
		
		Cards().setcard()
		
		Cards.state="ready"
		net().sendData()	  //初期手札を送信
		Thread.sleep(forTimeInterval: 3.0)
		
		
		
	}
	
	
	
	override func update(_ currentTime: CFTimeInterval) {
		
		
		
		// Called before each frame is rendered
		// lastが未定義ならば、今の時間を入れる。
		if last == nil{
			last = currentTime
		}
		
		// 3秒おきに行う処理をかく。
		if last + 1 <= currentTime  {
			net().receiveData()
			
			if Cards.state=="break"{	  //breakを受信したら強制終了
				let gameScene = LaunchScene(size: self.view!.bounds.size) // create your new scene
				let transition = SKTransition.fade(withDuration: 1.0) // create type of transition (you can check in documentation for more transtions)
				gameScene.scaleMode = SKSceneScaleMode.fill
				self.view!.presentScene(gameScene, transition: transition) //LaunchSceneに移動
			}

			
			if(Cards.state=="p1turn"){	//相手の受信を確認（こちら側が一方的にどんどん進めるのを防ぐため）
				if net.dealer==1{
					let gameScene:Netp1Scene = Netp1Scene(size: self.view!.bounds.size) // create your new scene
					let transition = SKTransition.fade(withDuration: 1.0) // create type of transition (you can check in documentation for more transtions)
					gameScene.scaleMode = SKSceneScaleMode.fill
					self.view!.presentScene(gameScene, transition: transition) //Netp1Sceneに移動
				}else if net.dealer==2{
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

