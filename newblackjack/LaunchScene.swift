//
//  LaunchScene.swift
//  newblackjack
//
//  Created by Kohei Nakai on 2017/03/09.
//  Copyright © 2017年 NakaiKohei. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class LaunchScene: SKScene {
	
	let vscpuButton=UIButton()
	let pvpButton=UIButton()
	let netButton=UIButton()
	
	
	let logo=SKSpriteNode(imageNamed:"Blackjack")
	
	
	override func didMove(to view: SKView) {
		
		//ロゴの設定及び設置
		let logowidth=self.view!.frame.width/6*5
		let logoheight=logowidth/5*2
		logo.size=CGSize(width:logowidth,height:logoheight)
		logo.position=CGPoint(x:self.view!.frame.width/2, y:self.view!.frame.height/4*3)
		self.addChild(logo)
		
		
		backgroundColor=SKColor.init(red: 0, green: 0.5, blue: 0, alpha: 0.1)
		
		//ボタンの設定
		vscpuButton.frame = CGRect(x: 0,y: 0,width: 200,height: 40)	//大きさ
		vscpuButton.backgroundColor = UIColor.brown;	//背景色
		vscpuButton.layer.masksToBounds = true  //角丸に合わせて画像をマスク（切り取る）
		vscpuButton.setTitle("CPUと対戦", for: UIControlState())
		vscpuButton.setTitleColor(UIColor.white, for: UIControlState())
		vscpuButton.setTitle("CPUと対戦", for: UIControlState.highlighted)
		vscpuButton.setTitleColor(UIColor.black, for: UIControlState.highlighted)
		vscpuButton.layer.cornerRadius = 20.0   //角丸を適用
		vscpuButton.layer.position = CGPoint(x: self.view!.frame.width/2, y:self.view!.frame.height/2)
		vscpuButton.addTarget(self, action: #selector(LaunchScene.onClickVscpuButton(_:)), for: .touchUpInside)
		vscpuButton.addTarget(self, action: #selector(LaunchScene.touchDownVSCPUButton(_:)), for: .touchDown)
		vscpuButton.addTarget(self, action: #selector(LaunchScene.enableButtons(_:)), for: .touchUpOutside)
		self.view!.addSubview(vscpuButton)
		
		
		pvpButton.frame = CGRect(x: 0,y: 0,width: 200,height: 40)	//大きさ
		pvpButton.backgroundColor = UIColor.brown;	//背景色
		pvpButton.layer.masksToBounds = true  //角丸に合わせて画像をマスク（切り取る）
		pvpButton.setTitle("2人で対戦", for: UIControlState())
		pvpButton.setTitleColor(UIColor.white, for: UIControlState())
		pvpButton.setTitle("2人で対戦", for: UIControlState.highlighted)
		pvpButton.setTitleColor(UIColor.black, for: UIControlState.highlighted)
		pvpButton.layer.cornerRadius = 20.0   //角丸を適用
		pvpButton.layer.position = CGPoint(x: self.view!.frame.width/2, y:self.view!.frame.height/2+80)
		pvpButton.addTarget(self, action: #selector(LaunchScene.onClickPVPButton(_:)), for: .touchUpInside)
		pvpButton.addTarget(self, action: #selector(LaunchScene.touchDownPVPButton(_:)), for: .touchDown)
		pvpButton.addTarget(self, action: #selector(LaunchScene.enableButtons(_:)), for: .touchUpOutside)
		self.view!.addSubview(pvpButton)
		
		netButton.frame = CGRect(x: 0,y: 0,width: 200,height: 40)	//大きさ
		netButton.backgroundColor = UIColor.brown;	//背景色
		netButton.layer.masksToBounds = true  //角丸に合わせて画像をマスク（切り取る）
		netButton.setTitle("ネットで対戦", for: UIControlState())
		netButton.setTitleColor(UIColor.white, for: UIControlState())
		netButton.setTitle("ネットで対戦", for: UIControlState.highlighted)
		netButton.setTitleColor(UIColor.black, for: UIControlState.highlighted)
		netButton.layer.cornerRadius = 20.0   //角丸を適用
		netButton.layer.position = CGPoint(x: self.view!.frame.width/2, y:self.view!.frame.height/2+160)
		netButton.addTarget(self, action: #selector(LaunchScene.onClickNetButton(_:)), for: .touchUpInside)
		netButton.addTarget(self, action: #selector(LaunchScene.touchDownNetButton(_:)), for: .touchDown)
		netButton.addTarget(self, action: #selector(LaunchScene.enableButtons(_:)), for: .touchUpOutside)
		self.view!.addSubview(netButton)
		
		

	}
	
	
	func onClickVscpuButton(_ sender : UIButton){
		//クラス変数を初期化（不要？）
		Cards.pcards.removeAll()
		Cards.cards.removeAll()
		Cards.ccards.removeAll()
		Cards.cards=[Int](1...52)
		
		//ボタンを隠す
		vscpuButton.isHidden=true
		pvpButton.isHidden=true
		netButton.isHidden=true
		
		let gameScene:GameScene = GameScene(size: self.view!.bounds.size) // create your new scene
		let transition = SKTransition.fade(withDuration: 1.0) // create type of transition (you can check in documentation for more transtions)
		gameScene.scaleMode = SKSceneScaleMode.fill
		self.view!.presentScene(gameScene, transition: transition) //GameSceneに移動

		
	}
	
	func onClickPVPButton(_ sender : UIButton){
		
		
		//クラス変数を初期化（不要？）
		Cards.pcards.removeAll()
		Cards.cards.removeAll()
		Cards.ccards.removeAll()
		Cards.cards=[Int](1...52)
		
		//ボタンを隠す
		vscpuButton.isHidden=true
		pvpButton.isHidden=true
		netButton.isHidden=true
		
		let gameScene:PVPScene = PVPScene(size: self.view!.bounds.size) // create your new scene
		let transition = SKTransition.fade(withDuration: 1.0) // create type of transition (you can check in documentation for more transtions)
		gameScene.scaleMode = SKSceneScaleMode.fill
		self.view!.presentScene(gameScene, transition: transition) //PVPSceneに移動
		
		
	}
	
	func onClickNetButton(_ sender : UIButton){
		
		//クラス変数を初期化（不要？）
		Cards.pcards.removeAll()
		Cards.cards.removeAll()
		Cards.ccards.removeAll()
		Cards.cards=[Int](1...52)
		
		
		//ボタンを隠す
		vscpuButton.isHidden=true
		pvpButton.isHidden=true
		netButton.isHidden=true
		
		
		let gameScene:waitingScene = waitingScene(size: self.view!.bounds.size) // create your new scene
		let transition = SKTransition.fade(withDuration: 1.0) // create type of transition (you can check in documentation for more transtions)
		gameScene.scaleMode = SKSceneScaleMode.fill
		self.view!.presentScene(gameScene, transition: transition) //waitingSceneに移動
		
		
	}
	
	
	
	
	//同時押し対策
	func touchDownVSCPUButton(_ sender: UIButton){
		pvpButton.isEnabled=false
		netButton.isEnabled=false
	}
	func touchDownPVPButton(_ sender: UIButton){
		vscpuButton.isEnabled=false
		netButton.isEnabled=false
	}
	func touchDownNetButton(_ sender: UIButton){
		vscpuButton.isEnabled=false
		pvpButton.isEnabled=false
	}
	
	func enableButtons(_ sender:UIButton){
		pvpButton.isEnabled=true
		vscpuButton.isEnabled=true
		netButton.isEnabled=true
	}


	
}
