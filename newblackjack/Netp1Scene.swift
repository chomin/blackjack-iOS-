//
//  NetScene.swift
//  newblackjack
//
//  Created by Kohei Nakai on 2017/03/17.
//  Copyright © 2017年 NakaiKohei. All rights reserved.
//

import SpriteKit
import GameplayKit

class Netp1Scene:SKScene{
	
	var card:[SKSpriteNode] = []	  //カードの画像(空の配列)
	let ppLabel = SKLabelNode(fontNamed: "HiraginoSans-W6") //得点表示用のラベル
	let cpLabel = SKLabelNode(fontNamed: "HiraginoSans-W6")
	var hcounter=0	//p1がヒットした数
	var fccardsc=2	//p2の手札の数(更新前)
	//ボタンを生成
	static let hitButton = UIButton()
	static let standButton = UIButton()
	static let resetButton=UIButton()
	static let titleButton=UIButton()
	let Label = SKLabelNode(fontNamed: "HiraginoSans-W6")	//ターンを表示→結果を表示
	
	var chcounter=0 //comがヒットした数
	
	let p1Label=SKLabelNode(fontNamed: "HiraginoSans-W6")	//p1,p2と表示
	let p2Label=SKLabelNode(fontNamed: "HiraginoSans-W6")
	// lastを用意しておく
	var last:CFTimeInterval!
	let nets=net()
	let queue = DispatchQueue.main    //メインスレッド
//	var sentfirst=false

	override func didMove(to view: SKView) {
		
		
		
		let cheight = view.frame.height/3	//カードの縦の長さは画面サイズによって変わる
		let cwidth = cheight*2/3
		
		
		//ラベルの設定をしておく
		p1Label.fontSize = cheight*20/138	//20はもともとの定数、138は7plusでのcheightの値
		p1Label.horizontalAlignmentMode = .left	//左寄せ
		p1Label.position = CGPoint(x:0, y:cheight+cheight*35/138)
		p1Label.text="P1"
		p1Label.fontColor=SKColor.blue
		addChild(p1Label)
		
		p2Label.fontSize = cheight*20/138
		p2Label.horizontalAlignmentMode = .left	//左寄せ
		p2Label.position = CGPoint(x:0, y:(view.frame.height)-cheight-cheight*55/138)
		p2Label.text="P2"
		p2Label.fontColor=SKColor.red
		addChild(p2Label)
		
		ppLabel.fontSize = cheight*30/138
		ppLabel.horizontalAlignmentMode = .left	//左寄せ
		ppLabel.position = CGPoint(x:0, y:cheight+cheight*5/138)
		addChild(ppLabel)
		
		cpLabel.fontSize = cheight*30/138
		cpLabel.horizontalAlignmentMode = .left
		cpLabel.position = CGPoint(x:0, y:(view.frame.height)-cheight-cheight*30/138)
		addChild(cpLabel)
		
		
		backgroundColor = SKColor.init(red: 0, green: 0.5, blue: 0, alpha: 0.1)
		
		//card[0]に裏面を格納
		card.append(SKSpriteNode(imageNamed:"z02"))
		
		//クローバー、ダイヤ、ハート、スペードの順に画像を格納
		for i in 1...13{
			card.append(SKSpriteNode(imageNamed: "c\(i)-1"))	  //配列に画像を追加
		}
		for i in 1...13{
			card.append(SKSpriteNode(imageNamed: "d\(i)-1"))
		}
		for i in 1...13{
			card.append(SKSpriteNode(imageNamed: "h\(i)-1"))
		}
		for i in 1...13{
			card.append(SKSpriteNode(imageNamed: "s\(i)-1"))
		}
		
		//cardのサイズを設定
		for i in card{
			i.size=CGSize(width:cwidth,height:cheight)
			self.addChild(i)	//予め全カードを枠外に表示（重複描写防止の為）
			i.position=CGPoint(x:-100,y:0)    //枠外に
		}
		
		//最初の手札を獲得(pの手札、cの手札、pの得点、cの得点)
//		let pccards=Cards().setcard()
		let (pp,cp)=Cards().getpoints()
		
		
		//各手札を表示
		for (index,value) in Cards.pcards.enumerated(){
			card[value].position=CGPoint(x:cwidth/2+cwidth*CGFloat(index),y:cheight/2)
			
		}
		
		//cpuの1枚目は表,2枚目は裏向き
		card[Cards.ccards[0]].position=CGPoint(x:cwidth/2,y:frame.size.height-cheight/2)
		card[0].position=CGPoint(x:cwidth/2+cwidth,y:frame.size.height-cheight/2)
		
		
		//得点表示
		ppLabel.text=pp
		
		
		
		
		
		// ボタンを設定.
		
		Netp1Scene.hitButton.frame = CGRect(x: 0,y: 0,width: 200,height: 40)
		Netp1Scene.hitButton.backgroundColor = UIColor.red;
		Netp1Scene.hitButton.layer.masksToBounds = true
		Netp1Scene.hitButton.setTitle("ヒット", for: UIControlState())
		Netp1Scene.hitButton.setTitleColor(UIColor.white, for: UIControlState())
		Netp1Scene.hitButton.setTitle("ヒット", for: UIControlState.highlighted)
		Netp1Scene.hitButton.setTitleColor(UIColor.black, for: UIControlState.highlighted)
		Netp1Scene.hitButton.setTitle("...", for: UIControlState.disabled)
		Netp1Scene.hitButton.setTitleColor(UIColor.black, for: UIControlState.disabled)
		Netp1Scene.hitButton.layer.cornerRadius = 20.0
		Netp1Scene.hitButton.layer.position = CGPoint(x: self.view!.frame.width-100, y:self.view!.frame.height/2-40)
		Netp1Scene.hitButton.addTarget(self, action: #selector(PVPScene.onClickHitButton(_:)), for: .touchUpInside)
		Netp1Scene.hitButton.addTarget(self, action: #selector(PVPScene.touchDownHitButton(_:)), for: .touchDown)
		Netp1Scene.hitButton.addTarget(self, action: #selector(PVPScene.enableButtons(_:)), for: .touchUpOutside)
//		Netp1Scene.hitButton.isHidden=true	//初期手札の送信完了まで隠す
		Netp1Scene.hitButton.isHidden=false	//前回終了時に消したものを見せる
		self.view!.addSubview(Netp1Scene.hitButton)
		
		
		
		Netp1Scene.standButton.frame = CGRect(x: 0,y: 0,width: 200,height: 40)
		Netp1Scene.standButton.backgroundColor = UIColor.red;
		Netp1Scene.standButton.layer.masksToBounds = true
		Netp1Scene.standButton.setTitle("スタンド", for: UIControlState())
		Netp1Scene.standButton.setTitleColor(UIColor.white, for: UIControlState())
		Netp1Scene.standButton.setTitle("スタンド", for: UIControlState.highlighted)
		Netp1Scene.standButton.setTitleColor(UIColor.black, for: UIControlState.highlighted)
		Netp1Scene.standButton.setTitle("...", for: UIControlState.disabled)
		Netp1Scene.standButton.setTitleColor(UIColor.black, for: UIControlState.disabled)
		Netp1Scene.standButton.layer.cornerRadius = 20.0
		Netp1Scene.standButton.layer.position = CGPoint(x: self.view!.frame.width-100, y:self.view!.frame.height/2+40)
		Netp1Scene.standButton.addTarget(self, action: #selector(PVPScene.onClickStandButton(_:)), for: .touchUpInside)
		Netp1Scene.standButton.addTarget(self, action: #selector(PVPScene.touchDownStandButton(_:)), for: .touchDown)
		Netp1Scene.standButton.addTarget(self, action: #selector(PVPScene.enableButtons(_:)), for: .touchUpOutside)
//		Netp1Scene.standButton.isHidden=true
		Netp1Scene.standButton.isHidden=false
		self.view!.addSubview(Netp1Scene.standButton)
		
			
		//ターンを表示
		
		Label.text = "player1のターン"
		Label.fontSize = 45
		Label.position = CGPoint(x:self.frame.midX, y:self.frame.midY - 20)
		self.addChild(Label)
		
		
//		Cards.state="p1turn"
//		
//		//初期の山札、手札を送信
//		
//			self.nets.sendData()
//		Thread.sleep(forTimeInterval: 3.0)
//			self.sentfirst=true
//			Netp1Scene.hitButton.isHidden=false
//			Netp1Scene.standButton.isHidden=false
		
			
			
			//BJの判定
			let j=Cards().judge(0)
			if j==5{
				self.ppLabel.text="Blackjack!"
				self.cpLabel.text="Blackjack!"
				self.draw()
				
			}else if j==3{
				self.ppLabel.text="Blackjack!"
				
				//2枚目を表に向ける
				var ccards=Cards.ccards
				self.card[ccards[1]].position=CGPoint(x:cwidth/2+cwidth,y:self.frame.size.height-cheight/2)
				
				
				//得点表示
				self.cpLabel.text=cp
				
				self.pwin()
			}else if j==4{
				self.card[0].run(SKAction.hide())	  //裏面カードを非表示にする
				
				//2枚目を表に向ける
				var ccards=Cards.ccards
				self.card[ccards[1]].position=CGPoint(x:cwidth/2+cwidth,y:self.frame.size.height-cheight/2)
				
				
				//得点表示
				self.cpLabel.text="Blackjack!"
				
				
				self.plose()
			}
		
		
		
	}
	
	
	
	
	func onClickHitButton(_ sender : UIButton){
		self.isPaused=true  //updateによる受信防止
		let cheight = (view?.frame.height)!/3	//フィールドの1パネルの大きさは画面サイズによって変わる
		let cwidth = cheight*2/3
		repeat { //最新まで受信(←なぜrepeatする必要がある？)
			nets.receiveData()  //送信前に受信(stand時のみ)（押した瞬間に）
		}while net.isLatest==false
		
		let (pcards,pp)=Cards().hit(hcounter)
		
		//p1の手札追加
		card[pcards[2+hcounter]].position=CGPoint(x:cwidth/2+cwidth*CGFloat(2+hcounter),y:cheight/2)
		
		
		//得点を更新
		ppLabel.text=pp
		
		hcounter+=1
		
		//バストの判定
		let j=Cards().judge(1)
		if j==4{
			ppLabel.text! += " Bust!!!"
			plose()
			
			card[0].run(SKAction.hide())	  //p2の裏面カードを非表示にする
			
			//2枚目を表に向ける
			var ccards=Cards.ccards
			card[ccards[1]].position=CGPoint(x:cwidth/2+cwidth,y:frame.size.height-cheight/2)
			
			
			//得点を表示する
			let (_,cp0)=Cards().getpoints()
			cpLabel.text=cp0
		}
		
		
		
		
		nets.sendData()
		
		Netp1Scene.standButton.isEnabled=true
		self.isPaused=false
	
	}
	
	func onClickStandButton(_ sender : UIButton){
		self.isPaused=true  //updateによる受信防止
		repeat { //最新まで受信
			nets.receiveData()  //送信前に受信(stand時のみ)（押した瞬間に）
		}while net.isLatest==false
		
		
		
		let cheight = (view?.frame.height)!/3	//フィールドの1パネルの大きさは画面サイズによって変わる
		let cwidth = cheight*2/3
		
		card[0].run(SKAction.hide())	  //裏面カードを非表示にする
		
		//2枚目を表に向ける
		var ccards=Cards.ccards
		card[ccards[1]].position=CGPoint(x:cwidth/2+cwidth,y:frame.size.height-cheight/2)	//幾つか前の空データを受信したときにindex out of range
		
		
		//得点を表示する
		let (_,cp0)=Cards().getpoints()
		cpLabel.text=cp0
		
		Label.text="player2のターン"
		
		
		Cards.state="p2turn"
		nets.sendData()
		
		
		
		Netp1Scene.hitButton.isHidden=true
		Netp1Scene.standButton.isHidden=true
		self.isPaused=false
		
	}
	
	override func update(_ currentTime: CFTimeInterval) {
		let cheight = (view?.frame.height)!/3	//カードの縦の長さは画面サイズによって変わる
		let cwidth = cheight*2/3

		// Called before each frame is rendered
		// lastが未定義ならば、今の時間を入れる。
		if last == nil{
			last = currentTime
		}
		
		// 3秒おきに行う処理をかく。
		if last + 1 <= currentTime {
			queue.async {
				
//				if self.sentfirst==true{    //初期手札を送る前の空データの受信防止
				//サーバーから山札、手札を獲得（1つずつ）
				self.nets.receiveData()
				
				let ccardsc=Cards.ccards.count
				
				if Cards.state=="break"{	  //breakを受信したら強制終了
					Netp1Scene.hitButton.isHidden=true
					Netp1Scene.standButton.isHidden=true
					Netp1Scene.resetButton.isHidden=true
					Netp1Scene.titleButton.isHidden=true
					
					let gameScene = LaunchScene(size: self.view!.bounds.size) // create your new scene
					let transition = SKTransition.fade(withDuration: 1.0) // create type of transition (you can check in documentation for more transtions)
					gameScene.scaleMode = SKSceneScaleMode.fill
					self.view!.presentScene(gameScene, transition: transition) //LaunchSceneに移動
				}
				if Cards.state=="judge"{
					//最終判定(ループ外)
					let j=Cards().judge(1)
					if j==0{
						self.draw()
					}else if j==1{
						self.pwin()
					}else if j==2{
						
						self.plose()
					}
				}
				
				
				Netp1Scene.hitButton.isEnabled=true
				Netp1Scene.standButton.isEnabled=true
				Netp1Scene.resetButton.isEnabled=true
				Netp1Scene.titleButton.isEnabled=true
				
				if ccardsc != self.fccardsc && (Cards.state=="p2turn"||Cards.state=="judge"){//更新
					
					let ccards:[Int]=Cards.ccards
					
					let (_,cp)=Cards().getpoints()
					//2p（敵）の各手札を表示
					
					self.card[ccards[ccardsc-1]].position=CGPoint(x:cwidth/2+cwidth*CGFloat(ccardsc-1),y:self.frame.size.height-cheight/2)
					
					
					//敵の得点表示
					self.cpLabel.text=cp
					self.fccardsc=ccardsc
					//引いた直後にバストの判定(ループ内)
					let j=Cards().judge(1)
					if j==3{
						self.cpLabel.text! += " Bust!!!"
						self.pwin()
						
					}
					
					
				}
				//				}
				
				self.last = currentTime
			}
		}//if last + 2 <= currentTime
		
		
		
	}
	
	
	func pwin(){
		
		Netp1Scene.hitButton.isHidden=true
		Netp1Scene.standButton.isHidden=true
		
		
		
		Label.text = "Player1 win!"
		
		endofthegame()
	}
	
	func plose(){
		
		Netp1Scene.hitButton.isHidden=true
		Netp1Scene.standButton.isHidden=true
		
		
		
		Label.text = "Player2 win!"
		
		endofthegame()
	}
	
	func draw(){  //引き分け！「描く」とは関係ない！
		
		Netp1Scene.hitButton.isHidden=true
		Netp1Scene.standButton.isHidden=true
		
		
		
		Label.text = "Draw"
		
		endofthegame()
	}
	
	func endofthegame(){
		Netp1Scene.titleButton.isEnabled=false
		Netp1Scene.resetButton.isEnabled=false
		
		hcounter=0
		
		// ボタンを生成.
		
		Netp1Scene.resetButton.frame = CGRect(x: 0,y: 0,width: 200,height: 40)
		Netp1Scene.resetButton.backgroundColor = UIColor.red;
		Netp1Scene.resetButton.layer.masksToBounds = true
		Netp1Scene.resetButton.setTitle("リプレイ", for: UIControlState())
		Netp1Scene.resetButton.setTitleColor(UIColor.white, for: UIControlState())
		Netp1Scene.resetButton.setTitle("リプレイ", for: UIControlState.highlighted)
		Netp1Scene.resetButton.setTitleColor(UIColor.black, for: UIControlState.highlighted)
		Netp1Scene.resetButton.setTitle("...", for: UIControlState.disabled)
		Netp1Scene.resetButton.setTitleColor(UIColor.black, for: UIControlState.disabled)
		Netp1Scene.resetButton.layer.cornerRadius = 20.0
		Netp1Scene.resetButton.layer.position = CGPoint(x: self.view!.frame.width-100, y:self.view!.frame.height-20)
		Netp1Scene.resetButton.addTarget(self, action: #selector(PVPScene.onClickResetButton(_:)), for: .touchUpInside)
		Netp1Scene.resetButton.addTarget(self, action: #selector(PVPScene.touchDownResetButton(_:)), for: .touchDown)
		Netp1Scene.resetButton.addTarget(self, action: #selector(PVPScene.enableButtons(_:)), for: .touchUpOutside)
		Netp1Scene.resetButton.isHidden=false
		self.view!.addSubview(Netp1Scene.resetButton)
		
		
		
		Netp1Scene.titleButton.frame = CGRect(x: 0,y: 0,width: 200,height: 40)
		Netp1Scene.titleButton.backgroundColor = UIColor.red;
		Netp1Scene.titleButton.layer.masksToBounds = true
		Netp1Scene.titleButton.setTitle("タイトルへ戻る", for: UIControlState())
		Netp1Scene.titleButton.setTitleColor(UIColor.white, for: UIControlState())
		Netp1Scene.titleButton.setTitle("タイトルへ戻る", for: UIControlState.highlighted)
		Netp1Scene.titleButton.setTitleColor(UIColor.black, for: UIControlState.highlighted)
		Netp1Scene.titleButton.setTitle("...", for: UIControlState.disabled)
		Netp1Scene.titleButton.setTitleColor(UIColor.black, for: UIControlState.disabled)
		Netp1Scene.titleButton.layer.cornerRadius = 20.0
		Netp1Scene.titleButton.layer.position = CGPoint(x: self.view!.frame.width-100, y:self.view!.frame.height-70)
		Netp1Scene.titleButton.addTarget(self, action: #selector(PVPScene.onClickTitleButton(_:)), for: .touchUpInside)
		Netp1Scene.titleButton.addTarget(self, action: #selector(PVPScene.touchDownTitleButton(_:)), for: .touchDown)
		Netp1Scene.titleButton.addTarget(self, action: #selector(PVPScene.enableButtons(_:)), for: .touchUpOutside)
		Netp1Scene.titleButton.isHidden=false
		self.view!.addSubview(Netp1Scene.titleButton)
		
		
		
	}
	
	func onClickResetButton(_ sender : UIButton){
		self.isPaused=true  //updateによる受信防止
		repeat{ //(サーバーの)最新まで受信（こっちの状態を送信する直前のデータを受信した状態だとエラー）
			nets.receiveData()  //送信前に受信(stand時のみ)（押した瞬間に）
		}while net.isLatest==false

		
		
			if Cards.state=="p2turn"||Cards.state=="judge"{	//ebdofthegameに入れると、カードの表示前に初期化してしまう！
				
				
				
				Cards.state="end"//クラス変数を初期化
				Cards.pcards.removeAll()
				Cards.cards.removeAll()
				Cards.ccards.removeAll()
				Cards.cards=[Int](1...52)
				
				self.nets.sendData() //受け手側が送るようにする
				
				
			}
			//ボタンを隠す
			Netp1Scene.resetButton.isHidden=true
			Netp1Scene.titleButton.isHidden=true
			
			let gameScene:waitingScene = waitingScene(size: self.view!.bounds.size) // create your new scene
			let transition = SKTransition.fade(withDuration: 1.0) // create type of transition (you can check in documentation for more transtions)
			gameScene.scaleMode = SKSceneScaleMode.fill
			self.view!.presentScene(gameScene, transition: transition) //waitingSceneに移動
		self.isPaused=false
		
	}
	
	func onClickTitleButton(_ sender : UIButton){
		self.isPaused=true  //updateによる受信防止
		repeat { //最新まで受信
			nets.receiveData()  //送信前に受信(stand時のみ)（押した瞬間に）
		}while net.isLatest==false

		
			if Cards.state=="p2turn"||Cards.state=="judge"{	//ebdofthegameに入れると、カードの表示前に初期化してしまう！
				
				
				
				Cards.state="end"//クラス変数を初期化
				Cards.pcards.removeAll()
				Cards.cards.removeAll()
				Cards.ccards.removeAll()
				Cards.cards=[Int](1...52)
				
				self.nets.sendData() //受け手側が送るようにする
				Thread.sleep(forTimeInterval: 3.0)
				
			}
			
			//ボタンを隠す
			Netp1Scene.resetButton.isHidden=true
			Netp1Scene.titleButton.isHidden=true
			
			let gameScene = LaunchScene(size: self.view!.bounds.size) // create your new scene
			let transition = SKTransition.fade(withDuration: 1.0) // create type of transition (you can check in documentation for more transtions)
			gameScene.scaleMode = SKSceneScaleMode.fill
			self.view!.presentScene(gameScene, transition: transition) //LaunchSceneに移動
		self.isPaused=false
		
	}
	
	//同時押し対策
	func touchDownHitButton(_ sender: UIButton){  //(disableされたボタンは外にドラッグして戻したときに表示がhilightされなくなる)
		Netp1Scene.standButton.isEnabled=false
	}
	func touchDownStandButton(_ sender: UIButton){
		Netp1Scene.hitButton.isEnabled=false
	}
	func touchDownTitleButton(_ sender: UIButton){
		Netp1Scene.resetButton.isEnabled=false
	}
	func touchDownResetButton(_ sender: UIButton){
		Netp1Scene.titleButton.isEnabled=false
	}
	
	func enableButtons(_ sender:UIButton){
		Netp1Scene.resetButton.isEnabled=true
		Netp1Scene.titleButton.isEnabled=true
		Netp1Scene.hitButton.isEnabled=true
		Netp1Scene.standButton.isEnabled=true
	}
	
	

	
}
