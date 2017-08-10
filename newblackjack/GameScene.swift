//
//  GameScene.swift
//  newblackjack
//
//  Created by Kohei Nakai on 2017/03/01.
//  Copyright © 2017年 NakaiKohei. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene , AVAudioPlayerDelegate{  //描写などの処理を主に行うクラス
	var last:CFTimeInterval!
	let queue = DispatchQueue.main    //メインスレッド
	let nets=net()
	var didchange=false   //攻守交代(netp2用)
	
	
	//効果音を生成
	var playcard : AVAudioPlayer! = nil  // 再生するサウンドのインスタンス
	var summon : AVAudioPlayer! = nil
	var satanIn : AVAudioPlayer! = nil
	var olivieIn : AVAudioPlayer! = nil
	var bahamutIn : AVAudioPlayer! = nil
	var zeusIn : AVAudioPlayer! = nil
	var aliceIn : AVAudioPlayer! = nil
	var breakcard : AVAudioPlayer! = nil
	
	var card:[SKSpriteNode] = []	  //カードの画像(空の配列)
	let pBPim=SKSpriteNode(imageNamed:"進化")
	let cBPim=SKSpriteNode(imageNamed:"進化2")
	let pBPLabel = SKLabelNode(fontNamed: "HiraginoSans-W6")
	let cBPLabel = SKLabelNode(fontNamed: "HiraginoSans-W6")
	
	let ppLabel = SKLabelNode(fontNamed: "HiraginoSans-W6") //得点表示用のラベル
	let cpLabel = SKLabelNode(fontNamed: "HiraginoSans-W6")
	var tPointLabel:[SKLabelNode]=[]//0~51
	var hcounter=0
	var chcounter=0 //comがヒットした数
	var scounter=0
	var fccardsc=2	//p2の手札の数(更新前)
	var fpcardsc=0	//p1の手札の数(更新前)
	var audioFinish=true
	//ボタンを生成
	static let hitButton = UIButton()
	static let standButton = UIButton()
	static let resetButton=UIButton()
	static let titleButton=UIButton()
	let Label = SKLabelNode(fontNamed: "HiraginoSans-W6")	//ターンを表示
	
	let p1Label=SKLabelNode(fontNamed: "HiraginoSans-W6")	//p1,comと表示
	let comLabel=SKLabelNode(fontNamed: "HiraginoSans-W6")
	
	let satanA=SKLabelNode(fontNamed: "HiraginoSans-W6")
	let satanHP=SKLabelNode(fontNamed: "HiraginoSans-W6")
	let olivieA=SKLabelNode(fontNamed: "HiraginoSans-W6")
	let olivieHP=SKLabelNode(fontNamed: "HiraginoSans-W6")
	let bahamutA=SKLabelNode(fontNamed: "HiraginoSans-W6")
	let bahamutHP=SKLabelNode(fontNamed: "HiraginoSans-W6")
	let zeusA=SKLabelNode(fontNamed: "HiraginoSans-W6")
	let zeusHP=SKLabelNode(fontNamed: "HiraginoSans-W6")
	let aliceA=SKLabelNode(fontNamed: "HiraginoSans-W6")
	let aliceHP=SKLabelNode(fontNamed: "HiraginoSans-W6")
	
	var resevation:[(sound:Int,x:CGFloat?,y:CGFloat?,card:Int?,hide:[Int])]=[(0,nil,nil,nil,[])]	//音付き描写の予約（音のみの場合もあり）をタプルの配列で表現
	
	/*
	soundは
	0:無音、1:カード音、(2:カード召喚音)、3:サタンin、4:オリヴィエin,5:バハムートin,6:ゼウスin,7:アリスin,8:破壊音9:10:
	*/
	
	
	
	
	override func didMove(to view: SKView) {
		Cards.pBP=0
		Cards.cBP=1
		
		//効果音の設定
		// サウンドファイルのパスを生成
		let playcardPath = Bundle.main.path(forResource: "カード音", ofType: "mp3")!    //m4aは不可
		let playcardsound:URL = URL(fileURLWithPath: playcardPath)
		// AVAudioPlayerのインスタンスを作成
		do {
			playcard = try AVAudioPlayer(contentsOf: playcardsound, fileTypeHint:nil)
		} catch {
			print("AVAudioPlayerインスタンス作成失敗")
		}
		// バッファに保持していつでも再生できるようにする
		playcard.prepareToPlay()
		
		//デリゲート先に自分を設定する。
		playcard.delegate=self
		
		let summonsound:URL = URL(fileURLWithPath: Bundle.main.path(forResource: "カード召喚音", ofType: "mp3")!)
		do {
			summon = try AVAudioPlayer(contentsOf: summonsound, fileTypeHint:nil)
		} catch {
			print("AVAudioPlayerインスタンス作成失敗")
		}
		summon.prepareToPlay()
		summon.delegate=self
		
		let satanInsound:URL = URL(fileURLWithPath: Bundle.main.path(forResource: "絶望よ、来たれ", ofType: "mp3")!)
		do {
			satanIn = try AVAudioPlayer(contentsOf: satanInsound, fileTypeHint:nil)
		} catch {
			print("AVAudioPlayerインスタンス作成失敗")
		}
		satanIn.prepareToPlay()
		satanIn.delegate=self
		
		let olivieInsound:URL = URL(fileURLWithPath: Bundle.main.path(forResource: "新たなる世界を求めて", ofType: "mp3")!)
		do {
			olivieIn = try AVAudioPlayer(contentsOf: olivieInsound, fileTypeHint:nil)
		} catch {
			print("AVAudioPlayerインスタンス作成失敗")
		}
		olivieIn.prepareToPlay()
		
		olivieIn.delegate=self
		let bahamutInsound:URL = URL(fileURLWithPath: Bundle.main.path(forResource: "（バハ登場）", ofType: "mp3")!)
		do {
			bahamutIn = try AVAudioPlayer(contentsOf: bahamutInsound, fileTypeHint:nil)
		} catch {
			print("AVAudioPlayerインスタンス作成失敗")
		}
		bahamutIn.prepareToPlay()
		bahamutIn.delegate=self
		
		let zeusInsound:URL = URL(fileURLWithPath: Bundle.main.path(forResource: "我こそ唯一にして無二たる神なり", ofType: "mp3")!)
		do {
			zeusIn = try AVAudioPlayer(contentsOf: zeusInsound, fileTypeHint:nil)
		} catch {
			print("AVAudioPlayerインスタンス作成失敗")
		}
		zeusIn.prepareToPlay()
		zeusIn.delegate=self
		
		let aliceInsound:URL = URL(fileURLWithPath: Bundle.main.path(forResource: "不思議な世界、素敵な世界！", ofType: "mp3")!)
		do {
			aliceIn = try AVAudioPlayer(contentsOf: aliceInsound, fileTypeHint:nil)
		} catch {
			print("AVAudioPlayerインスタンス作成失敗")
		}
		aliceIn.prepareToPlay()
		aliceIn.delegate=self
		
		let breakcardsound:URL = URL(fileURLWithPath: Bundle.main.path(forResource: "破壊音", ofType: "mp3")!)
		do {
			breakcard = try AVAudioPlayer(contentsOf: breakcardsound, fileTypeHint:nil)
		} catch {
			print("AVAudioPlayerインスタンス作成失敗")
		}
		breakcard.prepareToPlay()
		breakcard.delegate=self

		
		//描写物の設定
		let cheight = view.frame.height/3	//カードの縦の長さは画面サイズによって変わる.7+で138?
		let cwidth = cheight*2/3
		
		if Cards.mode=="scom"{
			//EP表示の設定
			pBPim.size=CGSize(width:cheight*30/138,height:cheight*30/138)
			self.addChild(pBPim)
			pBPim.position = CGPoint(x:view.frame.width/2-cheight*20/138, y:cheight+cheight*15/138)
			
			cBPim.size=CGSize(width:cheight*30/138,height:cheight*30/138)
			self.addChild(cBPim)
			cBPim.position = CGPoint(x:view.frame.width/2-cheight*20/138, y:view.frame.height-(cheight+cheight*20/138))
			
			pBPLabel.fontSize = cheight*30/138
			pBPLabel.horizontalAlignmentMode = .left
			pBPLabel.position=CGPoint(x:view.frame.width/2, y:cheight+cheight*5/138)
			pBPLabel.text="×"+String(Cards.pBP)
			self.addChild(pBPLabel)
			
			cBPLabel.fontSize = cheight*30/138
			cBPLabel.horizontalAlignmentMode = .left
			cBPLabel.position=CGPoint(x:view.frame.width/2, y:view.frame.height-(cheight+cheight*30/138))
			cBPLabel.text="×"+String(Cards.cBP)
			self.addChild(cBPLabel)
		}
		
		//ラベルの設定をしておく
		p1Label.fontSize = cheight*20/138
		p1Label.horizontalAlignmentMode = .left	//左寄せ
		p1Label.text="P1"
		p1Label.fontColor=SKColor.blue
		
		
		
		if Cards.mode=="com" || Cards.mode=="pvp" || Cards.mode=="netp1" || Cards.mode=="scom"{
			p1Label.position = CGPoint(x:0, y:cheight+cheight*35/138)
		}else{  //netp2
			p1Label.position = CGPoint(x:0, y:(view.frame.height)-cheight-cheight*55/138)
		}
		addChild(p1Label)
		
		comLabel.fontSize = cheight*20/138
		comLabel.horizontalAlignmentMode = .left	//左寄せ
		if Cards.mode=="com" || Cards.mode=="scom"{
			comLabel.position = CGPoint(x:0, y:(view.frame.height)-cheight-cheight*50/138)
			comLabel.text="com"
			comLabel.fontColor=SKColor.yellow
		}else if Cards.mode=="pvp" || Cards.mode=="netp1"{
			comLabel.position = CGPoint(x:0, y:(view.frame.height)-cheight-cheight*50/138)
			comLabel.text="P2"
			comLabel.fontColor=SKColor.red
		}else{
			comLabel.position = CGPoint(x:0, y:cheight+cheight*35/138)
			comLabel.text="P2"
			comLabel.fontColor=SKColor.red
		}
		addChild(comLabel)
		
		ppLabel.fontSize = cheight*30/138
		ppLabel.horizontalAlignmentMode = .left	//左寄せ
		if Cards.mode=="netp2"{
			ppLabel.position = CGPoint(x:0, y:(view.frame.height)-cheight-cheight*30/138)
		}else{
			ppLabel.position = CGPoint(x:0, y:cheight+cheight*5/138)
		}
		addChild(ppLabel)
		
		cpLabel.fontSize = cheight*30/138
		cpLabel.horizontalAlignmentMode = .left
		if Cards.mode=="netp2"{
			cpLabel.position = CGPoint(x:0, y:cheight+cheight*5/138)
		}else{
			cpLabel.position = CGPoint(x:0, y:(view.frame.height)-cheight-cheight*30/138)
		}
		addChild(cpLabel)
		
		
		if Cards.mode=="scom"{
			backgroundColor = SKColor.init(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.5)
		}else{
			backgroundColor = SKColor.init(red: 0, green: 0.5, blue: 0, alpha: 0.1)
		}
		
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
		
		//特殊カードを追加
		card.append(SKSpriteNode(imageNamed: "Satan"))
		card.append(SKSpriteNode(imageNamed: "Olivie"))
		card.append(SKSpriteNode(imageNamed: "Bahamut"))
		card.append(SKSpriteNode(imageNamed: "Zeus"))
		card.append(SKSpriteNode(imageNamed: "Alice"))
		

		
		//cardのサイズを設定
		for i in card{
			i.size=CGSize(width:cwidth,height:cheight)
			self.addChild(i)	//予め全カードを枠外に表示（重複描写防止の為）
			i.position=CGPoint(x:-100,y:0)    //枠外に
			i.zPosition=1

		}
		
		//トランプの得点のラベルを設定
		for _ in 1...52{
			tPointLabel.append(SKLabelNode(fontNamed: "HiraginoSans-W6"))
		}
		for i in tPointLabel{
			i.fontSize=cheight*16/138
			i.position=CGPoint(x:-100,y:0)
			i.zPosition=2
			i.fontColor=SKColor.white
			self.addChild(i)
		}
		
		
		if Cards.mode=="com" || Cards.mode=="scom" || Cards.mode=="pvp"{
			//最初の手札を獲得(pの手札、cの手札、pの得点、cの得点)
			let pccards=Cards().setcard()
			
			//各手札を表示
			for (index,value) in pccards.pcards.enumerated(){
				
				//card[value].position=CGPoint(x:cwidth/2+cwidth*CGFloat(index),y:cheight/2)
				if value.0<53{//トランプ
					resevation.append((1,cwidth/2+cwidth*CGFloat(index),cheight/2,value.0,[]))
					for i in Cards.pcards{//アリスの確認
						if i.card==57{
							Cards.pcards[index].point+=1
							tPointLabel[value.0-1].fontColor=SKColor.orange
						}
					}
				}else{
					let i=value.0-53+3
					resevation.append((i,cwidth/2+cwidth*CGFloat(index),cheight/2,value.0,[]))
					if value.0==54 {//オリヴィエ
						Cards.pBP=3
					}//アリス側からの得点操作は不要（最初に一気に配るから）
				}
			}
			//cpuの1枚目は表,2枚目は裏向き
			
			if pccards.ccards[0].0<53{
				resevation.append((1,cwidth/2,frame.size.height-cheight/2,pccards.ccards[0].0,[]))
				
			}else{
				let i=pccards.ccards[0].0-53+3
				resevation.append((i,cwidth/2,frame.size.height-cheight/2,pccards.ccards[0].0,[]))
				if pccards.ccards[0].0==54{//オリヴィエ
					Cards.cBP=3
				}
				//アリスの処理は不要
			}
			
			resevation.append((1,cwidth/2+cwidth,frame.size.height-cheight/2,0,[]))
			
			//Aの得点の確認
			let (ppoint,cpoint,_,_)=Cards().calculatepoints()
			for (index,value) in Cards.pcards.enumerated(){
				if value.card<53{//トランプ限定
					if value.card%13 == 1 && ppoint.inA<22{
						Cards.pcards[index].point+=10
						break	  //二枚目以降は更新しない
					}
					if value.card%13==1 && value.point>9{
						if ppoint.noA>21{
							Cards.pcards[index].point-=10
							break //後に直すべきAはないはず
						}
					}
				}
			}
			for (index,value) in Cards.ccards.enumerated(){
				if value.card<53{//トランプ限定
					if value.point==1 && cpoint.inA<22{
						Cards.ccards[index].point+=10
						break	  //二枚目以降は更新しない
					}
					if value.card%13==1 && value.point>9 && cpoint.noA>21{
						Cards.ccards[index].point-=10
						break //後に直すべきAはないはず
					}
				}
			}
			
			//プレイヤーの得点表示
			ppLabel.text=Cards().getpoints().pp
		}else{//ネット系
			let pcards:[(Int,Int)]=Cards.pcards
			let ccards:[(Int,Int)]=Cards.ccards
			
			if Cards.mode=="netp2"{
				//1p（敵）の各手札を表示
				for (index,value) in pcards.enumerated(){
					resevation.append((1,cwidth/2+cwidth*CGFloat(index),self.frame.size.height-cheight/2,value.0,[]))
				}
				
				//2pの1枚目は表,2枚目は裏向き
				resevation.append((1,cwidth/2,cheight/2,ccards[0].0,[]))
				resevation.append((1,cwidth/2+cwidth,cheight/2,0,[]))
			}else{//netp1
				//1pの各手札を表示
				for (index,value) in pcards.enumerated(){
					resevation.append((1,cwidth/2+cwidth*CGFloat(index),cheight/2,value.0,[]))
				}
				
				//2pの1枚目は表,2枚目は裏向き
				resevation.append((1,cwidth/2,self.frame.size.height-cheight/2,ccards[0].0,[]))
				resevation.append((1,cwidth/2+cwidth,self.frame.size.height-cheight/2,0,[]))

			}
			
			//Aの得点の確認
			let (ppoint,cpoint,_,_)=Cards().calculatepoints()
			for (index,value) in Cards.pcards.enumerated(){
				if value.card<53{//トランプ限定
					if value.card%13 == 1 && ppoint.inA<22{
						Cards.pcards[index].point+=10
						break	  //二枚目以降は更新しない
					}
					if value.card%13==1 && value.point>9{
						if ppoint.noA>21{
							Cards.pcards[index].point-=10
							break //後に直すべきAはないはず
						}
					}
				}
			}
			for (index,value) in Cards.ccards.enumerated(){
				if value.card<53{//トランプ限定
					if value.point==1 && cpoint.inA<22{
						Cards.ccards[index].point+=10
						break	  //二枚目以降は更新しない
					}
					if value.card%13==1 && value.point>9 && cpoint.noA>21{
						Cards.ccards[index].point-=10
						break //後に直すべきAはないはず
					}
				}
			}
			
			//得点表示
			ppLabel.text=Cards().getpoints().pp
		}
		// ボタンを設定.
		GameScene.hitButton.frame = CGRect(x: 0,y: 0,width: cheight*200/138,height: cheight*40/138)
		GameScene.hitButton.backgroundColor = UIColor.red
		GameScene.hitButton.layer.masksToBounds = true
		GameScene.hitButton.setTitle("ヒット", for: UIControlState())
		GameScene.hitButton.setTitleColor(UIColor.white, for: UIControlState())
		GameScene.hitButton.setTitle("ヒット", for: UIControlState.highlighted)
		GameScene.hitButton.setTitleColor(UIColor.black, for: UIControlState.highlighted)
		GameScene.hitButton.setTitle("...", for: UIControlState.disabled)
		GameScene.hitButton.setTitleColor(UIColor.black, for: UIControlState.disabled)
		GameScene.hitButton.layer.cornerRadius = 20.0
		GameScene.hitButton.layer.position = CGPoint(x: self.view!.frame.width-cheight*100/138, y:self.view!.frame.height/2-cheight*40/138)
		GameScene.hitButton.addTarget(self, action: #selector(GameScene.onClickHitButton(_:)), for: .touchUpInside)
		//同時押し対策
		GameScene.hitButton.addTarget(self, action: #selector(GameScene.touchDownHitButton(_:)), for: .touchDown) //一旦standボタンを押せないようにする
		GameScene.hitButton.addTarget(self, action: #selector(GameScene.enableButtons(_:)), for: .touchUpOutside)	//押せるように戻す
		self.view!.addSubview(GameScene.hitButton)
		if Cards.mode=="netp2"{
			GameScene.hitButton.isHidden=true
		}else{
			GameScene.hitButton.isHidden=false
		}
		
		
		GameScene.standButton.frame = CGRect(x: 0,y: 0,width: cheight*200/138,height: cheight*40/138)
		GameScene.standButton.backgroundColor = UIColor.red;
		GameScene.standButton.layer.masksToBounds = true
		GameScene.standButton.setTitle("スタンド", for: UIControlState())
		GameScene.standButton.setTitleColor(UIColor.white, for: UIControlState())
		GameScene.standButton.setTitle("スタンド", for: UIControlState.highlighted)
		GameScene.standButton.setTitleColor(UIColor.black, for: UIControlState.highlighted)
		GameScene.standButton.setTitle("...", for: UIControlState.disabled)
		GameScene.standButton.setTitleColor(UIColor.black, for: UIControlState.disabled)
		GameScene.standButton.layer.cornerRadius = 20.0
		GameScene.standButton.layer.position = CGPoint(x: self.view!.frame.width-cheight*100/138, y:self.view!.frame.height/2+cheight*40/138)
		GameScene.standButton.addTarget(self, action: #selector(GameScene.onClickStandButton(_:)), for: .touchUpInside)
		
		GameScene.standButton.addTarget(self, action: #selector(GameScene.touchDownStandButton(_:)), for: .touchDown)
		GameScene.standButton.addTarget(self, action: #selector(GameScene.enableButtons(_:)), for: .touchUpOutside)
		self.view!.addSubview(GameScene.standButton)
		if Cards.mode=="netp2"{
			GameScene.standButton.isHidden=true
		}else{
			GameScene.standButton.isHidden=false
		}
		
		//ターンを表示
		Label.text = "playerのターン"
		Label.fontSize = cheight*45/138
		Label.position = CGPoint(x:self.frame.midX, y:self.frame.midY - cheight*20/138)
		self.addChild(Label)
		
		//攻撃力と体力のラベルの設定
		satanA.text="6"
		satanHP.text="6"
		olivieA.text="4"
		olivieHP.text="4"
		bahamutA.text="13"
		bahamutHP.text="13"
		zeusA.text="5"
		zeusHP.text="10"
		aliceA.text="3"
		aliceHP.text="4"
		satanA.fontSize=cheight*11/138
		satanHP.fontSize=cheight*11/138
		olivieA.fontSize=cheight*11/138
		olivieHP.fontSize=cheight*11/138
		bahamutA.fontSize=cheight*11/138
		bahamutHP.fontSize=cheight*11/138
		zeusA.fontSize=cheight*11/138
		zeusHP.fontSize=cheight*11/138
		aliceA.fontSize=cheight*11/138
		aliceHP.fontSize=cheight*11/138
		satanA.position=CGPoint(x:card[53].position.x-cwidth/2+cheight*11/138,y:card[53].position.y-cheight/2+cheight*8/138)
		satanHP.position=CGPoint(x:card[53].position.x+cwidth/2-cheight*11/138,y:card[53].position.y-cheight/2+cheight*8/138)
		olivieA.position=CGPoint(x:card[54].position.x-cwidth/2+cheight*11/138,y:card[54].position.y-cheight/2+cheight*8/138)
		olivieHP.position=CGPoint(x:card[54].position.x+cwidth/2-cheight*11/138,y:card[54].position.y-cheight/2+cheight*8/138)
		bahamutA.position=CGPoint(x:card[55].position.x-cwidth/2+cheight*11/138,y:card[55].position.y-cheight/2+cheight*8/138)
		bahamutHP.position=CGPoint(x:card[55].position.x+cwidth/2-cheight*11/138,y:card[55].position.y-cheight/2+cheight*8/138)
		zeusA.position=CGPoint(x:card[56].position.x-cwidth/2+cheight*11/138,y:card[56].position.y-cheight/2+cheight*8/138)
		zeusHP.position=CGPoint(x:card[56].position.x+cwidth/2-cheight*11/138,y:card[56].position.y-cheight/2+cheight*8/138)
		aliceA.position=CGPoint(x:card[57].position.x-cwidth/2+cheight*11/138,y:card[57].position.y-cheight/2+cheight*8/138)
		aliceHP.position=CGPoint(x:card[57].position.x+cwidth/2-cheight*11/138,y:card[57].position.y-cheight/2+cheight*8/138)
		satanA.zPosition=2
		satanHP.zPosition=2
		olivieA.zPosition=2
		olivieHP.zPosition=2
		bahamutA.zPosition=2
		bahamutHP.zPosition=2
		zeusA.zPosition=2
		zeusHP.zPosition=2
		aliceA.zPosition=2
		aliceHP.zPosition=2
		self.addChild(satanA)
		self.addChild(satanHP)
		self.addChild(olivieA)
		self.addChild(olivieHP)
		self.addChild(bahamutA)
		self.addChild(bahamutHP)
		self.addChild(zeusA)
		self.addChild(zeusHP)
		self.addChild(aliceA)
		self.addChild(aliceHP)
		
		
		
		
		
		//BJの判定
		let j=Cards().judge(0)
		if j==5{
			ppLabel.text="Blackjack!"
			cpLabel.text="Blackjack!"
			draw()
			
			//2枚目を表に向ける
			var ccards=Cards.ccards
			if ccards[1].0<53{
				if Cards.mode=="netp2"{
					resevation.append((1,cwidth/2+cwidth,cheight/2,ccards[1].0,[0]))
				}else{
					resevation.append((1,cwidth/2+cwidth,frame.size.height-cheight/2,ccards[1].0,[0]))
				}
			}else{
				let i=ccards[1].0-53+3
				if Cards.mode=="netp2"{
					resevation.append((i,cwidth/2+cwidth,cheight/2,ccards[1].0,[0]))
				}else{
					resevation.append((i,cwidth/2+cwidth,frame.size.height-cheight/2,ccards[1].0,[0]))
				}
			}

		}else if j==3{
			ppLabel.text="Blackjack!"
			
			//2枚目を表に向ける
			var ccards=Cards.ccards
			if ccards[1].0<53{
				if Cards.mode=="netp2"{
					resevation.append((1,cwidth/2+cwidth,cheight/2,ccards[1].0,[0]))
					
				}else{
					resevation.append((1,cwidth/2+cwidth,frame.size.height-cheight/2,ccards[1].0,[0]))
				}
			}else{
				let i=ccards[1].0-53+3
				if Cards.mode=="netp2"{
					resevation.append((i,cwidth/2+cwidth,cheight/2,ccards[1].0,[0]))
				}else{
					resevation.append((i,cwidth/2+cwidth,frame.size.height-cheight/2,ccards[1].0,[0]))
				}
				
			}
			
			//得点表示
			cpLabel.text=Cards().getpoints().cp
			
			pwin()
		}else if j==4{
			//			card[0].run(SKAction.hide())	  //裏面カードを非表示にする
			
			//2枚目を表に向ける
			var ccards=Cards.ccards
			if ccards[1].0<53{
				if Cards.mode=="netp2"{
					resevation.append((1,cwidth/2+cwidth,cheight/2,ccards[1].0,[0]))
				}else{
					resevation.append((1,cwidth/2+cwidth,frame.size.height-cheight/2,ccards[1].0,[0]))
				}
			}else{
				let i=ccards[1].0-53+3
				if Cards.mode=="netp2"{
					resevation.append((i,cwidth/2+cwidth,cheight/2,ccards[1].0,[0]))
				}else{
					resevation.append((i,cwidth/2+cwidth,frame.size.height-cheight/2,ccards[1].0,[0]))
				}
			}
			
			
			//得点表示
			cpLabel.text="Blackjack!"

			plose()
		}
	}
	
	override func update(_ currentTime: CFTimeInterval) {
		
		
		let cheight = (view?.frame.height)!/3	//カードの縦の長さは画面サイズによって変わる
		let cwidth = cheight*2/3
		
		pBPLabel.text="×"+String(Cards.pBP)
		cBPLabel.text="×"+String(Cards.cBP)
		

		
		//トランプ得点ラベルの位置更新
		for i in Cards.pcards{
			if i.card<53{ //Cards.cards.cardは1~57の値を取り、tPointLabelは[0]~[51]まである。
				tPointLabel[i.card-1].position=CGPoint(x:card[i.card].position.x+cwidth/2-cheight*16/138,y:card[i.card].position.y+cheight/2-cheight*28/138)
				tPointLabel[i.card-1].text=String(i.point)
			}
		}
		for i in Cards.ccards{
			if i.card<53{ //Cards.cards.cardは1~57の値を取り、tPointLabelは[0]~[51]まである。
				tPointLabel[i.card-1].position=CGPoint(x:card[i.card].position.x+cwidth/2-cheight*16/138,y:card[i.card].position.y+cheight/2-cheight*28/138)
				tPointLabel[i.card-1].text=String(i.point)
			}
		}
		
		//ラベルとカードをくっつける
		satanA.position=CGPoint(x:card[53].position.x-cwidth/2+cheight*11/138,y:card[53].position.y-cheight/2+cheight*8/138)
		satanHP.position=CGPoint(x:card[53].position.x+cwidth/2-cheight*11/138,y:card[53].position.y-cheight/2+cheight*8/138)
		olivieA.position=CGPoint(x:card[54].position.x-cwidth/2+cheight*11/138,y:card[54].position.y-cheight/2+cheight*8/138)
		olivieHP.position=CGPoint(x:card[54].position.x+cwidth/2-cheight*11/138,y:card[54].position.y-cheight/2+cheight*8/138)
		bahamutA.position=CGPoint(x:card[55].position.x-cwidth/2+cheight*11/138,y:card[55].position.y-cheight/2+cheight*8/138)
		bahamutHP.position=CGPoint(x:card[55].position.x+cwidth/2-cheight*11/138,y:card[55].position.y-cheight/2+cheight*8/138)
		zeusA.position=CGPoint(x:card[56].position.x-cwidth/2+cheight*11/138,y:card[56].position.y-cheight/2+cheight*8/138)
		zeusHP.position=CGPoint(x:card[56].position.x+cwidth/2-cheight*11/138,y:card[56].position.y-cheight/2+cheight*8/138)
		aliceA.position=CGPoint(x:card[57].position.x-cwidth/2+cheight*11/138,y:card[57].position.y-cheight/2+cheight*8/138)
		aliceHP.position=CGPoint(x:card[57].position.x+cwidth/2-cheight*11/138,y:card[57].position.y-cheight/2+cheight*8/138)
		
		if audioFinish==true {
			if resevation.count>0{
				GameScene.resetButton.isEnabled=false
				GameScene.titleButton.isEnabled=false
				GameScene.hitButton.isEnabled=false
				GameScene.standButton.isEnabled=false
				
				if let cardnum=resevation[0].card{
					card[cardnum].position=CGPoint(x:resevation[0].x!,y:resevation[0].y!)
				}
				
				switch(resevation[0].sound){
				case 1 : playcard.play()
				audioFinish=false
				case 2 : summon.play()
				audioFinish=false
				case 3 : satanIn.play()
				audioFinish=false
				case 4 : olivieIn.play()
				audioFinish=false
				case 5 : bahamutIn.play()
				audioFinish=false
				case 6 : zeusIn.play()
				audioFinish=false
				case 7 : aliceIn.play()
				audioFinish=false
				case 8: breakcard.play()
				audioFinish=false
				default : break
				}
				
				for i in resevation[0].hide{
					card[i].position=CGPoint(x:-100,y:0)    //枠外に
					if i<53 && i>0{//トランプ表の得点も隠す
					tPointLabel[i-1].position=CGPoint(x:-100,y:0)
					}
				}
				
				resevation.removeFirst()
				
			}else{
				GameScene.resetButton.isEnabled=true
				GameScene.titleButton.isEnabled=true
				GameScene.hitButton.isEnabled=true
				GameScene.standButton.isEnabled=true
			}
		}
		
		if Cards.mode=="netp1" || Cards.mode=="netp2"{
			if last == nil{
				last = currentTime
			}
			
			// 3秒おきに行う処理をかく。
			if last + 1 <= currentTime {
				queue.async {
					
					//				if self.sentfirst==true{    //初期手札を送る前の空データの受信防止
					//サーバーから山札、手札を獲得（1つずつ）
					if Cards.state != "end"{
						self.nets.receiveData()
					}
					
					if Cards.state=="break"{	  //breakを受信したら強制終了
						GameScene.hitButton.isHidden=true
						GameScene.standButton.isHidden=true
						GameScene.resetButton.isHidden=true
						GameScene.titleButton.isHidden=true
						
						let gameScene = LaunchScene(size: self.view!.bounds.size) // create your new scene
						let transition = SKTransition.fade(withDuration: 1.0) // create type of transition (you can check in documentation for more transtions)
						gameScene.scaleMode = SKSceneScaleMode.fill
						self.view!.presentScene(gameScene, transition: transition) //LaunchSceneに移動
					}
					
					GameScene.hitButton.isEnabled=true
					GameScene.standButton.isEnabled=true
					GameScene.resetButton.isEnabled=true
					GameScene.titleButton.isEnabled=true
					
					if Cards.mode=="netp1"{
						let ccardsc=Cards.ccards.count
						
						if Cards.state=="judge"{
							
							//最終判定(ループ外)
							let j=Cards().judge(1)
							if j==0{
								Cards.state="end"
								Cards.pcards.removeAll()
								Cards.cards.removeAll()
								Cards.ccards.removeAll()
								
								self.nets.sendData()	//サーバーをendに更新し、以後の受信を停止
								self.draw()
							}else if j==1{
								Cards.state="end"
								Cards.pcards.removeAll()
								Cards.cards.removeAll()
								Cards.ccards.removeAll()
								
								self.nets.sendData()	//サーバーをendに更新し、以後の受信を停止
								self.pwin()
							}else if j==2{
								Cards.state="end"
								Cards.pcards.removeAll()
								Cards.cards.removeAll()
								Cards.ccards.removeAll()
								
								self.nets.sendData()	//サーバーをendに更新し、以後の受信を停止
								self.plose()
							}
						}
						

						
						if ccardsc != self.fccardsc && (Cards.state=="p2turn"||Cards.state=="judge"){//更新
							self.playcard.currentTime=0
							self.playcard.play()
							
							let ccards:[(Int,Int)]=Cards.ccards
							
							let (_,cp)=Cards().getpoints()
							//2p（敵）の各手札を表示
							
							self.card[ccards[ccardsc-1].0].position=CGPoint(x:cwidth/2+cwidth*CGFloat(ccardsc-1),y:self.frame.size.height-cheight/2)
							
							//敵の得点表示
							self.cpLabel.text=cp
							self.fccardsc=ccardsc
							//引いた直後にバストの判定(ループ内)
							let j=Cards().judge(1)
							if j==3{
								Cards.state="end"
								Cards.pcards.removeAll()
								Cards.cards.removeAll()
								Cards.ccards.removeAll()
								
								self.nets.sendData()	//サーバーをendに更新し、以後の受信を停止
								
								self.cpLabel.text! += " Bust!!!"
								self.pwin()
							}
							
						}
					}else if Cards.mode=="netp2"{
						let pcardsc=Cards.pcards.count    //毎回更新
						if (pcardsc > self.fpcardsc) && (Cards.state == "p1turn"||Cards.state == "p2turn"){//更新されたら(startはまだ配った手札が来てない状態、end,breakは手札がからの状態、judgeでもエラー発生)
							
							self.playcard.currentTime=0
							self.playcard.play()
							
							let pcards:[(Int,Int)]=Cards.pcards
							
							let (pp,_)=Cards().getpoints()
							//1p（敵）の各手札を表示
							
							self.card[pcards[pcardsc-1].0].position=CGPoint(x:cwidth/2+cwidth*CGFloat(pcardsc-1),y:self.frame.size.height-cheight/2)
							
							//敵の得点表示
							self.ppLabel.text=pp
							
							self.fpcardsc=pcardsc
							
							//敵のbustの判定
							let j=Cards().judge(1)
							if j==4{
								self.isPaused=true  //updateによる受信防止
								self.ppLabel.text! += " Bust!!!"
								self.plose()
								
								//2枚目を表に向ける
								var ccards=Cards.ccards
								self.resevation.append((1,cwidth/2+cwidth,cheight/2,ccards[1].0,[]))
								
								//得点を表示する
								let (_,cp0)=Cards().getpoints()
								self.cpLabel.text=cp0
								self.isPaused=false
								
								Cards.state="end"
								Cards.pcards.removeAll()
								Cards.cards.removeAll()
								Cards.ccards.removeAll()
								self.nets.sendData()	//サーバーをendに更新し、以後の受信を停止
							}
						}
						if Cards.state=="p2turn" && self.didchange==false{
							self.playcard.currentTime=0
							self.playcard.play()	//裏返しの音
							
							GameScene.hitButton.isHidden=false
							GameScene.standButton.isHidden=false
							self.card[0].run(SKAction.hide())	  //p2の裏面カードを非表示にする
							
							//2枚目を表に向ける
							var ccards=Cards.ccards
							self.card[ccards[1].card].position=CGPoint(x:cwidth/2+cwidth,y:cheight/2)
							
							//得点を表示する
							let (_,cp0)=Cards().getpoints()
							self.cpLabel.text=cp0
							self.Label.text="player2のターン"
							
							self.didchange=true
						}
					}
					self.last = currentTime
				}
			}//if last + 1 <= currentTime
		}
	}
	
	
	func onClickHitButton(_ sender : UIButton){
		GameScene.hitButton.isEnabled=false
		GameScene.standButton.isEnabled=false
		
		let cheight = (view?.frame.height)!/3	//フィールドの1パネルの大きさは画面サイズによって変わる
		let cwidth = cheight*2/3
		
		self.isPaused=true  //updateによる受信防止
		
		if Cards.mode=="com" || Cards.mode=="scom" {
			let ccards=Cards.ccards	  //バハによる除去前の敵の手札
			var (pcards,_)=Cards().hit()
			
			//手札追加
			if pcards[2+hcounter].0<53{//引いたのがトランプのとき
				resevation.append((1,cwidth/2+cwidth*CGFloat(2+hcounter),cheight/2,pcards[2+hcounter].0,[]))
				for i in Cards.pcards{//アリスの確認
					if i.card==57{
						Cards.pcards[2+hcounter].point+=1
						tPointLabel[Cards.pcards[2+hcounter].card-1].fontColor=SKColor.orange
					}
				}
			}else{
				let i=pcards[2+hcounter].0-53+3
				resevation.append((i,cwidth/2+cwidth*CGFloat(2+hcounter),cheight/2,pcards[2+hcounter].0,[]))
				if pcards[2+hcounter].0==55{//バハ
					hcounter = -2
					scounter = -2 //敵の手札も消える
					var remove=[0]
					for i in pcards{
						remove.append(i.0)
					}
					for i in ccards{
						remove.append(i.0)
					}
					
					resevation.append((8,nil,nil,nil,remove))
					resevation.append((0,cwidth/2,cheight/2,55,[]))
					Cards.pcards.removeAll()
					Cards.ccards.removeAll()
					Cards.pcards.append((55,10))
					
				}else if pcards[2+hcounter].0==54 {//オリヴィエ
					Cards.pBP=3
				}else if pcards[2+hcounter].0==57{//アリス
					for (index,value) in Cards.pcards.enumerated(){
						if value.card<53{//トランプの得点を増やす
							Cards.pcards[index].point+=1
							tPointLabel[value.0-1].fontColor=SKColor.orange
						}else if value.card<57{
							//特殊カードの攻撃、体力を増やす
						}
					}

				}
			}

			//Aの得点の確認
			let (ppoint,_,_,_)=Cards().calculatepoints()
			for (index,value) in Cards.pcards.enumerated(){
				if value.card<53{//トランプ限定
					if value.card%13 == 1 && ppoint.inA<22{
						Cards.pcards[index].point+=10
						break	  //二枚目以降は更新しない
					}
					if value.card%13==1 && value.point>9{
						if ppoint.noA>21{
							Cards.pcards[index].point-=10
							break //後に直すべきAはないはず
						}
					}
				}
			}
			
			//得点を更新
			ppLabel.text=Cards().getpoints().pp
			hcounter+=1
			
			//バストの判定
			var j=Cards().judge(1)
			
			while j==4{
				if Cards.pBP>0 {
					Cards.pBP -= 1	//--は抹消された...
					resevation.append((8,nil,nil,nil,[Cards.pcards.last!.card]))
					Cards.pcards.removeLast()
					hcounter-=1
					
					let (pp,_)=Cards().getpoints()
					ppLabel.text=pp
					j=Cards().judge(1)
					continue
				}else{
					ppLabel.text! += " Bust!!!"
					plose()
					
					//2枚目を表に向ける
					var ccards=Cards.ccards
					if ccards.count>0{//バハで消えてないか確認
						if ccards[1].card<53{
							resevation.append((1,cwidth/2+cwidth,frame.size.height-cheight/2,ccards[1].card,[0]))
							
						}else{
							let i=ccards[1].card-53+3
							resevation.append((i,cwidth/2+cwidth,frame.size.height-cheight/2,ccards[1].card,[0]))
							
						}
						//得点を表示する
						let (_,cp0)=Cards().getpoints()
						cpLabel.text=cp0
					}
					break
				}
			}
		}else if Cards.mode=="pvp"{
			if scounter==0{ //p1のターンで押されたとき
				let (pcards,pp)=Cards().hit()
				
				//p1の手札追加
				resevation.append((1,cwidth/2+cwidth*CGFloat(2+hcounter),cheight/2,pcards[2+hcounter].0,[]))
				
				//Aの得点の確認
				let (ppoint,_,_,_)=Cards().calculatepoints()
				for (index,value) in Cards.pcards.enumerated(){
					if value.card<53{//トランプ限定
						if value.card%13 == 1 && ppoint.inA<22{
							Cards.pcards[index].point+=10
							break	  //二枚目以降は更新しない
						}
						if value.card%13==1 && value.point>9{
							if ppoint.noA>21{
								Cards.pcards[index].point-=10
								break //後に直すべきAはないはず
							}
						}
					}
				}
				
				//得点を更新
				ppLabel.text=pp
				
				hcounter+=1
				
				//バストの判定
				let j=Cards().judge(1)
				if j==4{
					ppLabel.text! += " Bust!!!"
					plose()
					
					//2枚目を表に向ける
					var ccards=Cards.ccards
					if ccards[1].card<53{
						
						resevation.append((1,cwidth/2+cwidth,frame.size.height-cheight/2,ccards[1].card,[0]))
						
					}else{
						let i=ccards[1].card-53+3
						
						resevation.append((i,cwidth/2+cwidth,frame.size.height-cheight/2,ccards[1].card,[0]))
						
					}
					
					//得点を表示する
					let (_,cp0)=Cards().getpoints()
					cpLabel.text=cp0
				}
			}else if scounter==1{	//p2のターン
				let (ccards,cp)=Cards().stand() //カードを引く
				
				
				//手札追加
				resevation.append((1,cwidth/2+cwidth*CGFloat(2+chcounter),frame.size.height-cheight/2,ccards[2+chcounter].0,[]))
				
				//Aの得点の確認
				let (_,cpoint,_,_)=Cards().calculatepoints()
				for (index,value) in Cards.ccards.enumerated(){
					if value.card<53{//トランプ限定
						if value.point==1 && cpoint.inA<22{
							Cards.ccards[index].point+=10
							break	  //二枚目以降は更新しない
						}
						if value.card%13==1 && value.point>9 && cpoint.noA>21{
							Cards.ccards[index].point-=10
							break //後に直すべきAはないはず
						}
					}
				}
				
				//得点を更新
				cpLabel.text=cp
				
				//引いた直後にバストの判定(ループ内)
				let j=Cards().judge(1)
				if j==3{
					cpLabel.text! += " Bust!!!"
					pwin()
					
				}
				chcounter+=1
			}

		}else if Cards.mode=="netp1"{
			repeat { //最新まで受信(受信防止しているが、後で更新時に前のデータを受信するとバグる）
				nets.receiveData()  //送信前に受信(stand時のみ)（押した瞬間に）
			}while net.isLatest==false
			
			let (pcards,pp)=Cards().hit()
			
			//p1の手札追加
			resevation.append((1,cwidth/2+cwidth*CGFloat(2+hcounter),cheight/2,pcards[2+hcounter].0,[]))
			
			//Aの得点の確認
			let (ppoint,_,_,_)=Cards().calculatepoints()
			for (index,value) in Cards.pcards.enumerated(){
				if value.card<53{//トランプ限定
					if value.card%13 == 1 && ppoint.inA<22{
						Cards.pcards[index].point+=10
						break	  //二枚目以降は更新しない
					}
					if value.card%13==1 && value.point>9{
						if ppoint.noA>21{
							Cards.pcards[index].point-=10
							break //後に直すべきAはないはず
						}
					}
				}
			}
			
		
			
			//得点を更新
			ppLabel.text=pp
			
			hcounter+=1
			
			nets.sendData()
			
			//バストの判定
			let j=Cards().judge(1)
			if j==4{
				
				ppLabel.text! += " Bust!!!"
				plose()
				
				//2枚目を表に向ける
				var ccards=Cards.ccards
				if ccards[1].card<53{
					
					resevation.append((1,cwidth/2+cwidth,frame.size.height-cheight/2,ccards[1].card,[0]))
					
				}else{
					let i=ccards[1].card-53+3
					
					resevation.append((i,cwidth/2+cwidth,frame.size.height-cheight/2,ccards[1].card,[0]))
					
				}
				
				//得点を表示する
				let (_,cp0)=Cards().getpoints()
				cpLabel.text=cp0
				
				//サーバーをendに更新し、以後の受信を停止
			}
		}else{//netp2
			repeat { //最新まで受信（こっちの状態を送信する直前のデータを受信した状態だとエラー）
				nets.receiveData()  //送信前に受信(stand時のみ)（押した瞬間に）
			}while net.isLatest==false
			
			let (ccards,cp)=Cards().stand() //カードを引く
			
			//手札追加
			resevation.append((1,cwidth/2+cwidth*CGFloat(2+chcounter),cheight/2,ccards[2+chcounter].0,[]))
			
			//Aの得点の確認
			let (_,cpoint,_,_)=Cards().calculatepoints()
			for (index,value) in Cards.ccards.enumerated(){
				if value.card<53{//トランプ限定
					if value.point==1 && cpoint.inA<22{
						Cards.ccards[index].point+=10
						break	  //二枚目以降は更新しない
					}
					if value.card%13==1 && value.point>9 && cpoint.noA>21{
						Cards.ccards[index].point-=10
						break //後に直すべきAはないはず
					}
				}
			}
			
			//得点を更新
			cpLabel.text=cp
			
			nets.sendData()
			
			
			//引いた直後にバストの判定(ループ内)
			let j=Cards().judge(1)
			if j==3{
				
				cpLabel.text! += " Bust!!!"
				pwin()
				
			}
			
			chcounter+=1
			
		}
		
		//standボタンを押せるようにする（touchDown時に押せなくしたものを戻す）
		GameScene.standButton.isEnabled=true
		GameScene.hitButton.isEnabled=true
		self.isPaused=false
		
	}
	
	func onClickStandButton(_ sender : UIButton){
		self.isPaused=true  //updateによる受信防止
		
		let cheight = (view?.frame.height)!/3	//フィールドの1パネルの大きさは画面サイズによって変わる
		let cwidth = cheight*2/3
		
		if Cards.mode != "netp2"{
			//2枚目を表に向ける
			var ccards=Cards.ccards
			if ccards.count>0{//バハで消えてないか確認
				if ccards[1].card<53{
					resevation.append((1,cwidth/2+cwidth,frame.size.height-cheight/2,ccards[1].card,[0]))
					for i in Cards.ccards{//アリスの確認
						if i.card==57{
							Cards.ccards[1].point+=1
							tPointLabel[ccards[1].card-1].fontColor=SKColor.orange
						}
					}

				}else{
					let i=ccards[1].card-53+3
					resevation.append((i,cwidth/2+cwidth,frame.size.height-cheight/2,ccards[1].card,[0]))
					if ccards[1].card==55 {//バハ
						let pcards=Cards.pcards
						scounter = -1
						var remove:[Int]=[]
						for i in pcards{
							remove.append(i.card)
						}
						for i in ccards{
							remove.append(i.card)
						}
						resevation.append((8,nil,nil,nil,remove))
						resevation.append((0,cwidth/2,frame.size.height-cheight/2,55,[]))
						Cards.pcards.removeAll()
						Cards.ccards.removeAll()
						Cards.ccards.append((55,10))
					}else if ccards[1].card==54 {//オリヴィエ
						Cards.cBP=3
					}else if ccards[1].card==57{//アリス
						for (index,value) in Cards.ccards.enumerated(){
							if value.card<53{//トランプの得点を増やす
								Cards.cards[index].point+=1
								tPointLabel[value.0-1].fontColor=SKColor.orange
							}else if value.card<57{
								//特殊カードの攻撃、体力を増やす
							}
						}

					}
				}
			}
			
			
			
			//得点を表示する
			let (pp,cp0)=Cards().getpoints()
			cpLabel.text=cp0
			ppLabel.text=pp
		}
		
		if Cards.mode=="com" || Cards.mode=="scom" {
			var j=Cards().judge(1)
			while j != 3{//バストしてない間
				//引く前に次に引くべきかを判定
				var (_,cpoint,_,cA)=Cards().calculatepoints()
				if (cpoint.inA>16 && cA==true && cpoint.inA<22 && Cards.cBP==0) || cpoint.noA>16 && Cards.cBP==0{
					break
				}
				
				let pcards=Cards.pcards
				var (ccards,cp)=Cards().stand()
				var pp:String
				
				//手札追加
				
				if ccards[2+scounter].0<53{
					resevation.append((1,cwidth/2+cwidth*CGFloat(2+scounter),frame.size.height-cheight/2,ccards[2+scounter].0,[]))
					for i in Cards.ccards{//アリスの確認
						if i.card==57{
							Cards.ccards[2+scounter].point+=1
							tPointLabel[Cards.ccards[2+scounter].card-1].fontColor=SKColor.orange
						}
					}

				}else{
					let i=ccards[2+scounter].0-53+3
					resevation.append((i,cwidth/2+cwidth*CGFloat(2+scounter),frame.size.height-cheight/2,ccards[2+scounter].0,[]))
					if ccards[2+scounter].0==55{//バハ
						scounter = -2
						var remove:[Int]=[]
						for i in pcards{
							remove.append(i.card)
						}
						for i in ccards{
							remove.append(i.0)
						}
						resevation.append((8,nil,nil,nil,remove))
						resevation.append((0,cwidth/2,frame.size.height-cheight/2,55,[]))
						Cards.pcards.removeAll()
						Cards.ccards.removeAll()
						Cards.ccards.append((55,10))
						
					}else if ccards[2+scounter].0==54 {//オリヴィエ
						Cards.cBP=3
					}else if ccards[2+scounter].0==57{//アリス
						for (index,value) in Cards.ccards.enumerated(){
							if value.card<53{//トランプの得点を増やす
								Cards.ccards[index].point+=1
								tPointLabel[value.0-1].fontColor=SKColor.orange
							}else if value.card<57{
								//特殊カードの攻撃、体力を増やす
							}
						}

					}
				}
				
				//Aの得点の確認
				(_,cpoint,_,_)=Cards().calculatepoints()
				for (index,value) in Cards.ccards.enumerated(){
					if value.card<53{//トランプ限定
						if value.point==1 && cpoint.inA<22{
							Cards.ccards[index].point+=10
							break	  //二枚目以降は更新しない
						}
						if value.card%13==1 && value.point>9 && cpoint.noA>21{
							Cards.ccards[index].point-=10
							break //後に直すべきAはないはず
						}
					}
				}
				
				//得点を更新
				(pp,cp)=Cards().getpoints()
				cpLabel.text=cp
				ppLabel.text=pp
				
				//引いた直後にバストの判定(ループ内)
				j=Cards().judge(1)
				while j==3{
					if Cards.cBP>0 {
						Cards.cBP -= 1	//--は抹消された...
						resevation.append((8,nil,nil,nil,[Cards.ccards.last!.card]))
						Cards.ccards.removeLast()
						scounter-=1
						
						let (_,cp)=Cards().getpoints()
						cpLabel.text=cp
						j=Cards().judge(1)
						continue
					}else{
						cpLabel.text! += " Bust!!!"
						pwin()
						break//一番内側からしか抜けられない！
					}
				}
				scounter+=1
			}
			//最終判定(ループ外)
			j=Cards().judge(1)
			if j==0{
				draw()
			}else if j==1{
				pwin()
			}else if j==2{
				plose()
			}
		}else if Cards.mode=="pvp" {
			if scounter==0{ //p2のターンへ移行
				
				scounter+=1
				
				Label.text="player2のターン"
				
			}else if scounter==1{
				//最終判定(ループ外)
				let j=Cards().judge(1)
				if j==0{
					draw()
				}else if j==1{
					pwin()
				}else if j==2{
					plose()
				}
				
				//初期化
				scounter=0
			}

		}else if Cards.mode=="netp1" {
			repeat { //最新まで受信
				nets.receiveData()  //送信前に受信(stand時のみ)（押した瞬間に）
			}while net.isLatest==false
			
			Label.text="player2のターン"
			
			Cards.state="p2turn"
			nets.sendData()
			
			GameScene.hitButton.isHidden=true
			GameScene.standButton.isHidden=true
			self.isPaused=false

		}else {//netp2
			repeat { //最新まで受信（こっちの状態を送信する直前のデータを受信した状態だとエラー）
				nets.receiveData()  //送信前に受信(stand時のみ)（押した瞬間に）
			}while net.isLatest==false
			Cards.state="judge"
			nets.sendData()
			Cards.state="end"	  //今後の受信を停止
			
			//最終判定(ループ外)
			let j=Cards().judge(1)
			if j==0{
				
				draw()
			}else if j==1{
				pwin()
			}else if j==2{
				plose()
			}
			
			GameScene.hitButton.isHidden=true
			GameScene.standButton.isHidden=true
		}
		//hitボタンを押せるようにする
		GameScene.hitButton.isEnabled=true
		self.isPaused=false
		
	}
	
	func pwin(){
		
		GameScene.hitButton.isHidden=true
		GameScene.standButton.isHidden=true
		
		if Cards.mode=="pvp"{
			Label.text="P1 Win!"
		}else if Cards.mode=="netp2"{
			Label.text="You Lose..."
		}else {
			Label.text = "You Win!"
		}
		endofthegame()
	}
	
	func plose(){
		
		GameScene.hitButton.isHidden=true
		GameScene.standButton.isHidden=true
		
		if Cards.mode=="pvp"{
			Label.text="P2 Win!"
		}else if Cards.mode=="netp2"{
			Label.text="You Win!"
		}else {
			Label.text = "You Lose..."
		}
		endofthegame()
	}
	
	func draw(){  //引き分け！「描く」とは関係ない！
		
		GameScene.hitButton.isHidden=true
		GameScene.standButton.isHidden=true
		
		
		
		Label.text = "Draw"
		
		endofthegame()
	}
	
	func endofthegame(){
		// ボタンを生成.
		
		GameScene.resetButton.frame = CGRect(x: 0,y: 0,width: 200,height: 40)
		GameScene.resetButton.backgroundColor = UIColor.red;
		GameScene.resetButton.layer.masksToBounds = true
		GameScene.resetButton.setTitle("リプレイ", for: UIControlState())
		GameScene.resetButton.setTitleColor(UIColor.white, for: UIControlState())
		GameScene.resetButton.setTitle("リプレイ", for: UIControlState.highlighted)
		GameScene.resetButton.setTitleColor(UIColor.black, for: UIControlState.highlighted)
		GameScene.resetButton.setTitle("...", for: UIControlState.disabled)
		GameScene.resetButton.setTitleColor(UIColor.black, for: UIControlState.disabled)
		GameScene.resetButton.layer.cornerRadius = 20.0
		GameScene.resetButton.layer.position = CGPoint(x: self.view!.frame.width-100, y:self.view!.frame.height-20)
		GameScene.resetButton.addTarget(self, action: #selector(GameScene.onClickResetButton(_:)), for: .touchUpInside)
		GameScene.resetButton.addTarget(self, action: #selector(GameScene.touchDownResetButton(_:)), for: .touchDown)
		GameScene.resetButton.addTarget(self, action: #selector(GameScene.enableButtons(_:)), for: .touchUpOutside)
		self.view!.addSubview(GameScene.resetButton)
		GameScene.resetButton.isHidden=false
		
		
		GameScene.titleButton.frame = CGRect(x: 0,y: 0,width: 200,height: 40)
		GameScene.titleButton.backgroundColor = UIColor.red;
		GameScene.titleButton.layer.masksToBounds = true
		GameScene.titleButton.setTitle("タイトルへ戻る", for: UIControlState())
		GameScene.titleButton.setTitleColor(UIColor.white, for: UIControlState())
		GameScene.titleButton.setTitle("タイトルへ戻る", for: UIControlState.highlighted)
		GameScene.titleButton.setTitleColor(UIColor.black, for: UIControlState.highlighted)
		GameScene.titleButton.setTitle("...", for: UIControlState.disabled)
		GameScene.titleButton.setTitleColor(UIColor.black, for: UIControlState.disabled)
		GameScene.titleButton.layer.cornerRadius = 20.0
		GameScene.titleButton.layer.position = CGPoint(x: self.view!.frame.width-100, y:self.view!.frame.height-70)
		GameScene.titleButton.addTarget(self, action: #selector(GameScene.onClickTitleButton(_:)), for: .touchUpInside)
		GameScene.titleButton.addTarget(self, action: #selector(GameScene.touchDownTitleButton(_:)), for: .touchDown)
		GameScene.titleButton.addTarget(self, action: #selector(GameScene.enableButtons(_:)), for: .touchUpOutside)
		self.view!.addSubview(GameScene.titleButton)
		GameScene.titleButton.isHidden=false

	}
	
	func onClickResetButton(_ sender : UIButton){
		if Cards.mode=="pvp" || Cards.mode=="com" || Cards.mode=="scom"{
			//クラス変数を初期化
			Cards.pcards.removeAll()
			Cards.cards.removeAll()
			Cards.ccards.removeAll()
		}
		//ボタンを隠す
		GameScene.resetButton.isHidden=true
		GameScene.titleButton.isHidden=true
		
		if Cards.mode=="pvp" || Cards.mode=="com" || Cards.mode=="scom"{
			let gameScene:GameScene = GameScene(size: self.view!.bounds.size) // create your new scene
			let transition = SKTransition.fade(withDuration: 1.0) // create type of transition (you can check in documentation for more transtions)
			gameScene.scaleMode = SKSceneScaleMode.fill
			self.view!.presentScene(gameScene, transition: transition) //GameSceneに移動
		}else{//net系
			let gameScene:waitingScene = waitingScene(size: self.view!.bounds.size) // create your new scene
			let transition = SKTransition.fade(withDuration: 1.0) // create type of transition (you can check in documentation for more transtions)
			gameScene.scaleMode = SKSceneScaleMode.fill
			self.view!.presentScene(gameScene, transition: transition) //waitingSceneに移動

		}
	}
	
	func onClickTitleButton(_ sender : UIButton){
		if Cards.mode=="pvp" || Cards.mode=="com" || Cards.mode=="scom"{
			//クラス変数を初期化
			Cards.pcards.removeAll()
			Cards.cards.removeAll()
			Cards.ccards.removeAll()
		}
		
		//ボタンを隠す
		GameScene.resetButton.isHidden=true
		GameScene.titleButton.isHidden=true
		
		let gameScene = LaunchScene(size: self.view!.bounds.size) // create your new scene
		let transition = SKTransition.fade(withDuration: 1.0) // create type of transition (you can check in documentation for more transtions)
		gameScene.scaleMode = SKSceneScaleMode.fill
		self.view!.presentScene(gameScene, transition: transition) //LaunchSceneに移動
	}
	
	
	//同時押し対策
	func touchDownHitButton(_ sender: UIButton){  //(disableされたボタンは外にドラッグして戻したときに表示がhilightされなくなる)
		GameScene.standButton.isEnabled=false
		GameScene.hitButton.isEnabled=false
	}
	func touchDownStandButton(_ sender: UIButton){
		GameScene.hitButton.isEnabled=false
	}
	func touchDownTitleButton(_ sender: UIButton){
		GameScene.resetButton.isEnabled=false
	}
	func touchDownResetButton(_ sender: UIButton){
		GameScene.titleButton.isEnabled=false
	}
	func enableButtons(_ sender:UIButton){
		GameScene.resetButton.isEnabled=true
		GameScene.titleButton.isEnabled=true
		GameScene.hitButton.isEnabled=true
		GameScene.standButton.isEnabled=true
	}
	
	//再生終了時の呼び出しメソッド
	func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		
		audioFinish=true
	}
	

}



