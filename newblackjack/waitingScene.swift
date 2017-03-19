//
//  waitingScene.swift
//  newblackjack
//
//  Created by Kohei Nakai on 2017/03/17.
//  Copyright © 2017年 NakaiKohei. All rights reserved.
//

import SpriteKit
import GameplayKit

class waitingScene: SKScene {
	
	let Label = SKLabelNode(fontNamed: "HiraginoSans-W6")
	let breakButton=UIButton()	//対戦中じゃないのに対戦中から移動しないとき用
	let nets=net()
	// lastを用意しておく
	var last:CFTimeInterval!
	var didfirst=false

	

	
	override func didMove(to view: SKView) {
		
		backgroundColor=SKColor.init(red: 0.8, green: 0.3, blue: 0.3, alpha: 0.3)
		Label.text = "Waiting..."
		Label.fontSize = 45
		Label.position = CGPoint(x:self.frame.midX, y:self.frame.midY - 20)
		self.addChild(Label)
		

	}
	
	
	
	override func update(_ currentTime: CFTimeInterval) {
		// Called before each frame is rendered
		// lastが未定義ならば、今の時間を入れる。
		if last == nil{
			last = currentTime
		}
		
		// 4秒おきに行う処理をかく。
		if last + 4 <= currentTime {
			let tmp=Cards.state   //こっちがwaitingで向こうからstartが帰ってきたとき
			nets.receiveData() //更新
			if didfirst==false{
				if Cards.state=="end"||Cards.state=="break"{
					Cards.state="waiting"
					nets.sendData()
					Label.text = "Waiting..."
					breakButton.isHidden=true
				}else if Cards.state=="waiting"{	//誰かが待っていたら→p2
					Cards.state="start"
					nets.sendData()
					let gameScene:Netp2Scene = Netp2Scene(size: self.view!.bounds.size) // create your new scene
					let transition = SKTransition.fade(withDuration: 1.0) // create type of transition (you can check in documentation for more transtions)
					gameScene.scaleMode = SKSceneScaleMode.fill
					self.view!.presentScene(gameScene, transition: transition) //Netp2Sceneに移動
					
				}else{
					Label.text="対戦中"
					breakButton.frame = CGRect(x: 0,y: 0,width: 200,height: 40)
					breakButton.backgroundColor = UIColor.red;
					breakButton.layer.masksToBounds = true
					breakButton.setTitle("強制終了", for: UIControlState())
					breakButton.setTitleColor(UIColor.white, for: UIControlState())
					breakButton.setTitle("強制終了", for: UIControlState.highlighted)
					breakButton.setTitleColor(UIColor.black, for: UIControlState.highlighted)
					breakButton.layer.cornerRadius = 20.0
					breakButton.layer.position = CGPoint(x: self.view!.frame.width-100, y:self.view!.frame.height-20)
					breakButton.addTarget(self, action: #selector(self.onClickBreakButton(_:)), for: .touchUpInside)
					breakButton.addTarget(self, action: #selector(self.touchDownBreakButton(_:)), for: .touchDown)
					breakButton.addTarget(self, action: #selector(self.enableButtons(_:)), for: .touchUpOutside)
					self.view!.addSubview(breakButton)
					
				}
				didfirst=true

			}
			
			
			if (Cards.state=="start"||Cards.state=="p1turn") && tmp=="waiting"{
				breakButton.isHidden=true
				let gameScene:Netp1Scene = Netp1Scene(size: self.view!.bounds.size) // create your new scene
				let transition = SKTransition.fade(withDuration: 1.0) // create type of transition (you can check in documentation for more transtions)
				gameScene.scaleMode = SKSceneScaleMode.fill
				self.view!.presentScene(gameScene, transition: transition) //Netp1Sceneに移動
			}
			if (Cards.state=="end")||(Cards.state=="break"){
				Cards.state="waiting"
				nets.sendData()
				Label.text = "Waiting..."
				breakButton.isHidden=true
				
			}
			
			
			last = currentTime
		}
		
		

		
		
		
	}
	
	func onClickBreakButton(_ sender : UIButton){

		
		Cards.state="break"
		//クラス変数を初期化
		Cards.pcards.removeAll()
		Cards.cards.removeAll()
		Cards.ccards.removeAll()
		Cards.cards=[Int](1...52)
		nets.sendData()
		
		let gameScene = LaunchScene(size: self.view!.bounds.size) // create your new scene
		let transition = SKTransition.fade(withDuration: 1.0) // create type of transition (you can check in documentation for more transtions)
		gameScene.scaleMode = SKSceneScaleMode.fill
		self.view!.presentScene(gameScene, transition: transition) //LaunchSceneに移動
		breakButton.isHidden=true


	}
	
	
	
	
	//同時押し対策
	
	func touchDownBreakButton(_ sender: UIButton){	  //他のボタンをdisableする
		
	}
	
	func enableButtons(_ sender:UIButton){
		breakButton.isEnabled=true
	}

	
	
}
