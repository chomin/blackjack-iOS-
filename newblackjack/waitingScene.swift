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
	let cancelButton=UIButton()
	let nets=net()
	var last:CFTimeInterval!  //前に更新した時間
	var didfirst=false
	static var sendstart=false	//ダブルwaiting対策→net.swiftのreceive()
	
	static var dobreak=false  //受信と同時に働くのを防ぐため？
	
	let queue = DispatchQueue.main//メインスレッド
	
	
	
	
	override func didMove(to view: SKView) {
		let uuid1=UIDevice.current.identifierForVendor!.uuidString //識別子
		let start=uuid1.startIndex
		let end=uuid1.characters.index(start, offsetBy: 4)
		net.uuid=uuid1[start...end]
		
		backgroundColor=SKColor.init(red: 0.8, green: 0.3, blue: 0.3, alpha: 0.3)
		Label.text = "Waiting..."
		Label.fontSize = 45
		Label.position = CGPoint(x:self.frame.midX, y:self.frame.midY - 20)
		self.addChild(Label)
		
		self.cancelButton.frame = CGRect(x: 0,y: 0,width: 160,height: 30)
		self.cancelButton.backgroundColor = UIColor.gray
		self.cancelButton.layer.masksToBounds = true
		self.cancelButton.setTitle("キャンセル", for: UIControlState())
		self.cancelButton.setTitleColor(UIColor.white, for: UIControlState())
		self.cancelButton.setTitle("キャンセル", for: UIControlState.highlighted)
		self.cancelButton.setTitleColor(UIColor.black, for: UIControlState.highlighted)
		
		self.cancelButton.layer.position = CGPoint(x: 100, y:self.view!.frame.height-20)
		self.cancelButton.addTarget(self, action: #selector(self.onClickBreakButton(_:)), for: .touchUpInside)  //動作はbreakButtonと同じ
		self.cancelButton.addTarget(self, action: #selector(self.touchDownCancelButton(_:)), for: .touchDown)
		self.cancelButton.addTarget(self, action: #selector(self.enableButtons(_:)), for: .touchUpOutside)
		self.view!.addSubview(self.cancelButton)

	}
	
	
	
	override func update(_ currentTime: CFTimeInterval) {
		// Called before each frame is rendered
		// lastが未定義ならば、今の時間を入れる。
		if last == nil{
			last = currentTime
		}
		
		// 3秒おきに行う処理をかく。(1秒だと到着順番が入れ替わりやすい)
		if last + 1 <= currentTime {
			queue.async { //3秒以上たっても処理が終わるまで次の処理を行わない
				
				if waitingScene.dobreak==true{
					Cards.state="break"
					//クラス変数を初期化
					Cards.pcards.removeAll()
					Cards.cards.removeAll()
					Cards.ccards.removeAll()
					self.nets.sendData()
					
					let gameScene = LaunchScene(size: self.view!.bounds.size) // create your new scene
					let transition = SKTransition.fade(withDuration: 1.0) // create type of transition (you can check in documentation for more transtions)
					gameScene.scaleMode = SKSceneScaleMode.fill
					self.view!.presentScene(gameScene, transition: transition) //LaunchSceneに移動
					self.breakButton.isHidden=true
					self.cancelButton.isHidden=true
					waitingScene.dobreak=false
					self.didfirst=false
					net.fLastId=0

				}else{
					
					
					
					let tmp=Cards.state   //更新前の状態
					self.nets.receiveData() //更新(Cardsに反映)

					if net.isLatest==true{
						
						if (Cards.state=="start" && tmp=="waiting") || (Cards.state=="ready" && tmp=="start") {//こっちがwaitingで向こうからstart(p1turn???)が帰ってきたとき（didfirstより前に行う）
							self.breakButton.isHidden=true
							self.cancelButton.isHidden=true
							let gameScene:loadingScene = loadingScene(size: self.view!.bounds.size) // create your new scene
							let transition = SKTransition.fade(withDuration: 0.3) // create type of transition (you can check in documentation for more transtions)
							gameScene.scaleMode = SKSceneScaleMode.fill
							self.view!.presentScene(gameScene, transition: transition) //loadingSceneに移動
						}
						
						
//						if Cards.state=="p2turn" && tmp=="p1turn"{//2つ進んでいたらloadingSceneを飛ばす(片方が進め過ぎるとバグるので、起こらないように仕様変更)
//							if net.dealer==2{	//ありえないはず
//								let gameScene:Netp1Scene = Netp1Scene(size: self.view!.bounds.size) // create your new scene
//								let transition = SKTransition.fade(withDuration: 1.0) // create type of transition (you can check in documentation for more transtions)
//								gameScene.scaleMode = SKSceneScaleMode.fill
//								self.view!.presentScene(gameScene, transition: transition) //Netp1Sceneに移動
//							}else if net.dealer==1{
//								let gameScene:Netp2Scene = Netp2Scene(size: self.view!.bounds.size) // create your new scene
//								let transition = SKTransition.fade(withDuration: 1.0) // create type of transition (you can check in documentation for more transtions)
//								gameScene.scaleMode = SKSceneScaleMode.fill
//								self.view!.presentScene(gameScene, transition: transition) //Netp2Sceneに移動
//							}else{
//								print("dealerの値が\(net.dealer)です。")
//								exit(1)
//							}
//						}
						
						if self.didfirst==false{//最初だけ行うべき内容？
							if Cards.state=="end"||Cards.state=="break"{
								Cards.state="waiting"
								self.nets.sendData()
								self.Label.text = "Waiting..."
								self.breakButton.isHidden=true
							}else if Cards.state=="waiting"{	//誰かが待っていたら→p2
								self.cancelButton.isHidden=true
								Cards.state="start"
								self.nets.sendData()
								Thread.sleep(forTimeInterval: 3.0)
								let gameScene:preparingScene = preparingScene(size: self.view!.bounds.size) // create your new scene
								let transition = SKTransition.fade(withDuration: 0.3) // create type of transition (you can check in documentation for more transtions)
								gameScene.scaleMode = SKSceneScaleMode.fill
								self.view!.presentScene(gameScene, transition: transition) //preparingSceneに移動
								
							}else{
								self.Label.text="対戦中"
								self.breakButton.frame = CGRect(x: 0,y: 0,width: 200,height: 40)
								self.breakButton.backgroundColor = UIColor.red;
								self.breakButton.layer.masksToBounds = true
								self.breakButton.setTitle("強制終了", for: UIControlState())
								self.breakButton.setTitleColor(UIColor.white, for: UIControlState())
								self.breakButton.setTitle("強制終了", for: UIControlState.highlighted)
								self.breakButton.setTitleColor(UIColor.black, for: UIControlState.highlighted)
								self.breakButton.layer.cornerRadius = 20.0
								self.breakButton.layer.position = CGPoint(x: self.view!.frame.width-100, y:self.view!.frame.height-20)
								self.breakButton.addTarget(self, action: #selector(self.onClickBreakButton(_:)), for: .touchUpInside)
								self.breakButton.addTarget(self, action: #selector(self.touchDownBreakButton(_:)), for: .touchDown)
								self.breakButton.addTarget(self, action: #selector(self.enableButtons(_:)), for: .touchUpOutside)
								self.view!.addSubview(self.breakButton)
								
							}
							self.didfirst=true
							
						}
						
						
						
						if (Cards.state=="end")||(Cards.state=="break"){//??
							Cards.state="waiting"
							self.nets.sendData()
							self.Label.text = "Waiting..."
							self.breakButton.isHidden=true
							
						}
						if waitingScene.sendstart==true{
							self.cancelButton.isHidden=true
							Cards.state="start"
							waitingScene.sendstart=false
							self.nets.sendData()
							let gameScene:preparingScene = preparingScene(size: self.view!.bounds.size) // create your new scene
							let transition = SKTransition.fade(withDuration: 0.3) // create type of transition (you can check in documentation for more transtions)
							gameScene.scaleMode = SKSceneScaleMode.fill
							self.view!.presentScene(gameScene, transition: transition) //preparingSceneに移動
							
						}
						
					}//
				}
				self.last = currentTime
			}
		}
		
		

		
		
		
	}
	
	func onClickBreakButton(_ sender : UIButton){
		waitingScene.dobreak=true
	}
	
	//同時押し対策
	
	func touchDownBreakButton(_ sender: UIButton){	  //他のボタンをdisableする
		cancelButton.isEnabled=false
	}
	func touchDownCancelButton(_ sender: UIButton){	  //他のボタンをdisableする
		breakButton.isEnabled=false
	}
	
	func enableButtons(_ sender:UIButton){
		breakButton.isEnabled=true
		cancelButton.isEnabled=true
	}

	
	
}
