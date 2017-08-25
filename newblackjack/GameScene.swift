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

class GameScene: Sounds {  //描写などの処理を主に行うクラス。音の再生終了の通知を受け取るためDelegateを実装。(SKSceneはSoundsで継承)
	var last:CFTimeInterval!
	let queue = DispatchQueue.main    //メインスレッド
	let nets=net()	//netクラスのインスタンス化
	var didchange=false   //攻守交代(netp2用)
	var comRoop=false	//(com,scom用)
	
	//画像
	var card:[SKSpriteNode] = []	  //カードの画像(空の配列)
	var pBPim=SKSpriteNode()
	var cBPim=SKSpriteNode()
	
	
	//ラベル
	var specialLabels:[String:SKLabelNode]=[:]//特殊カードの攻撃力、体力
	var pBPLabel = SKLabelNode(fontNamed: "HiraginoSans-W6")//BP
	var cBPLabel = SKLabelNode(fontNamed: "HiraginoSans-W6")
	var ppLabel = SKLabelNode(fontNamed: "HiraginoSans-W6") //得点表示用のラベル
	var cpLabel = SKLabelNode(fontNamed: "HiraginoSans-W6")
	var pbjLabel = SKLabelNode(fontNamed: "HiraginoSans-W6") //bj表示用のラベル
	var cbjLabel = SKLabelNode(fontNamed: "HiraginoSans-W6")
	var tPointLabel:[SKLabelNode]=[]//トランプの得点ラベル（52個）
	var centerLabel = SKLabelNode(fontNamed: "HiraginoSans-W6")	//ターンや最終結果を表示
	var p1Label=SKLabelNode(fontNamed: "HiraginoSans-W6")	//p1,comと表示
	var comLabel=SKLabelNode(fontNamed: "HiraginoSans-W6")


	//ボタンを生成(他のクラスから設定できるようにクラス変数)
	static let hitButton = UIButton()
	static let standButton = UIButton()
	static let resetButton = UIButton()
	static let titleButton = UIButton()
	
	
	var hcounter=0
	var chcounter=0 //comがヒットした数
	var scounter=0
	var fccardsc=2	//p2の手札の数(更新前)
	var fpcardsc=0	//p1の手札の数(更新前)
	static var audioFinish=true
	var resevation:[(sound:Int,x:CGFloat?,y:CGFloat?,card:Int?,hide:[Int],pointLabel:(pp:String,cp:String),tPointLabel:[(index:Int,value:String,color:UIColor?)],BPLabel:(pBP:String?,cBP:String?))]=[(0,nil,nil,nil,[],("0","0"),[],(nil,nil))]	//音付き描写の予約（音のみの場合もあり）をタプルの配列で表現
	//tPointLabelの変更は現時点でアリス召喚、退場時のみ
	
	/*
	soundは
	0:無音、1:カード音、(2:カード召喚音)、3:サタンin、4:オリヴィエin,5:バハムートin,6:ゼウスin,7:アリスin,8:破壊音9:10:
	*/
	
	//resevationに代入する関数群
	func makePaintResevation(sound:Int,x:CGFloat?,y:CGFloat?,card:Int?){//カード表示と持ち点のみ(トランプ、特殊カードを引いたとき用、持ち点は代入時の値を取得して代入)
		resevation.append((sound,x,y,card,[],Cards().getpoints(),[],(nil,nil)))
	}
	func makeAliceResevation(x:CGFloat?,y:CGFloat?,card:Int?,tPointLabel:[(index:Int,value:String,color:UIColor?)]){//カード表示と得点群のみ(アリス引いたとき用)
		
		resevation.append((7,x,y,card,[],Cards().getpoints(),tPointLabel,(nil,nil)))
		
	}
	func makeOlivieResevation(x:CGFloat?,y:CGFloat?,card:Int?,BPLabel:(pBP:String?,cBP:String?)){//カード表示と持ち点、BPのみ(オリヴィエ引いたとき用)
		resevation.append((4,x,y,card,[],Cards().getpoints(),[],BPLabel))
	}
	func makeHideAndPaintResevation(sound:Int,x:CGFloat?,y:CGFloat?,card:Int?,hide:[Int]){//カード表示と非表示、持ち点のみ(バハムートの効果｛→破壊音8｝、comの２枚目｛→カード音1or特殊カード音3~7｝用)
		
		resevation.append((sound,x,y,card,hide,Cards().getpoints(),[],(nil,nil)))
	}
	func makeUseBPResevation(hide:[Int],BPLabel:(pBP:String?,cBP:String?)){//カード非表示と、持ち点、BPのみ(bust回避用)
		resevation.append((8,nil,nil,nil,hide,Cards().getpoints(),[],BPLabel))
	}
	
	
	override func didMove(to view: SKView) {//このシーンに移ったときに最初に実行される
		
		Cards.pBP=0
		Cards.cBP=1
		
		//音の設定
		setAllSounds()
		
		playcard.delegate=self//デリゲート先（通知先）に自分を設定する。
		summon.delegate=self
		satanIn.delegate=self
		olivieIn.delegate=self
		bahamutIn.delegate=self
		zeusIn.delegate=self
		aliceIn.delegate=self
		breakcard.delegate=self
		
		//描写物の設定
		let cheight = view.frame.height/3	//カードの縦の長さは画面サイズによって変わる。7+で138?
		let cwidth = cheight*2/3
		
		
		//ラベルの設定
		
		(pBPLabel,cBPLabel,ppLabel,cpLabel,pbjLabel,cbjLabel,tPointLabel,centerLabel,p1Label,comLabel,specialLabels)=Labels().setLabels(frame_height: view.frame.height, frame_width: view.frame.width)
		
		self.addChild(pBPLabel)
		self.addChild(cBPLabel)
		self.addChild(ppLabel)
		self.addChild(cpLabel)
		self.addChild(pbjLabel)
		self.addChild(cbjLabel)
		for i in tPointLabel{
			self.addChild(i)
		}
		self.addChild(centerLabel)
		self.addChild(p1Label)
		self.addChild(comLabel)
		for i in specialLabels{
			self.addChild(i.value)
		}

		//背景の設定
		if Cards.mode == .scom{
			backgroundColor = SKColor.init(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.5)
		}else{
			backgroundColor = SKColor.init(red: 0, green: 0.5, blue: 0, alpha: 0.1)
		}
		
		
		//画像の設定
		(pBPim,cBPim,card)=Images().setImages(frame_height: view.frame.height, frame_width: view.frame.width)
		
		self.addChild(pBPim)
		self.addChild(cBPim)
		for i in card{
			self.addChild(i)
		}
		
		
		if Cards.mode == .com || Cards.mode == .scom || Cards.mode == .pvp{
			//最初の手札を獲得(pの手札、cの手札、pの得点、cの得点)
			let pccards=Cards().setcard()
			
			//Aの得点の確認
			let (ppoint,cpoint,_,_)=Cards().calculatepoints()
			for (index,value) in Cards.pcards.enumerated(){
				if value.card<53{//トランプ限定
					if value.card%13 == 1 && ppoint.inA<22{
						Cards.pcards[index].point+=10
						tPointLabel[value.card-1].text=String(Cards.pcards[index].point)
						break	  //二枚目以降は更新しない
					}
					if value.card%13==1 && value.point>9{
						if ppoint.noA>21{
							Cards.pcards[index].point-=10
							tPointLabel[value.card-1].text=String(Cards.pcards[index].point)
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
			
			
			
			//各手札を表示
			for (index,value) in pccards.pcards.enumerated(){//プレイヤー側
				if value.0<53{//トランプ
					makePaintResevation(sound: 1, x: cwidth/2+cwidth*CGFloat(index), y: cheight/2, card: value.0)
					for i in Cards.pcards{//アリスがあるかの確認
						if i.card==57 || i.card==62 || i.card==63{
							Cards.pcards[index].point+=1
							tPointLabel[value.0-1].fontColor=SKColor.orange
						}
					}
				}else if value.0==54 || value.0==58 || value.0==59{//オリヴィエ
					Cards.pBP=3
					makeOlivieResevation(x: cwidth/2+cwidth*CGFloat(index), y: cheight/2, card: value.0, BPLabel: (pBP: "3", cBP: nil))
				}else{//その他の特殊カード
					var i:Int
					
					if value.0==60 || value.0==61{
						i=5
					}else if value.0==62 || value.0==63{
						i=7
					}else{
						i=value.0-53+3
						
					}
					
					makePaintResevation(sound: i, x: cwidth/2+cwidth*CGFloat(index), y: cheight/2, card: value.0)
				}//アリス側からの得点操作は不要（最初に一気に配るから）
			}
			
			//cpuの1枚目の表示
			if pccards.ccards[0].0<53{
				makePaintResevation(sound: 1, x: cwidth/2, y: frame.size.height-cheight/2, card: pccards.ccards[0].0)
			}else if pccards.ccards[0].0==54 || pccards.ccards[0].0==58 || pccards.ccards[0].0==59{//オリヴィエ
				Cards.cBP=3
				makeOlivieResevation(x: cwidth/2, y: frame.size.height-cheight/2, card: pccards.ccards[0].0, BPLabel: (pBP: nil, cBP: "3"))
			}else{
				var i:Int
				
				if pccards.ccards[0].0==60 || pccards.ccards[0].0==61{
					i=5
				}else if pccards.ccards[0].0==62 || pccards.ccards[0].0==63{
					i=7
				}else{
					i=pccards.ccards[0].0-53+3
					
				}
				
				makePaintResevation(sound: i, x: cwidth/2, y: frame.size.height-cheight/2, card: pccards.ccards[0].0)
				//アリスの処理は不要
			}
			
			//cpuの2枚目の表示
			makePaintResevation(sound: 1, x: cwidth/2+cwidth, y: frame.size.height-cheight/2, card: 0)
			
		}else{//ネット系
			let pcards:[(Int,Int)]=Cards.pcards
			let ccards:[(Int,Int)]=Cards.ccards
			
			if Cards.mode == .netp2{
				//1p（敵）の各手札を表示
				for (index,value) in pcards.enumerated(){
					makePaintResevation(sound: 1, x: cwidth/2+cwidth*CGFloat(index), y: self.frame.size.height-cheight/2, card: value.0)
				}
				
				//2pの1枚目は表,2枚目は裏向き
				makePaintResevation(sound: 1, x: cwidth/2, y: cheight/2, card: ccards[0].0)
				makePaintResevation(sound: 1, x: cwidth/2+cwidth, y: cheight/2, card: 0)
			}else{//netp1
				
				//各手札を表示
				for (index,value) in pcards.enumerated(){//プレイヤー側
					if value.0<53{//トランプ
						makePaintResevation(sound: 1, x: cwidth/2+cwidth*CGFloat(index), y: cheight/2, card: value.0)
						for i in Cards.pcards{//アリスがあるかの確認
							if i.card==57 || i.card==62 || i.card==63{
								Cards.pcards[index].point+=1
								tPointLabel[value.0-1].fontColor=SKColor.orange
							}
						}
					}else if value.0==54 || value.0==58 || value.0==59{//オリヴィエ
						Cards.pBP=3
						makeOlivieResevation(x: cwidth/2+cwidth*CGFloat(index), y: cheight/2, card: value.0, BPLabel: (pBP: "3", cBP: nil))
					}else{//その他の特殊カード
						var i:Int
						
						if value.0==60 || value.0==61{
							i=5
						}else if value.0==62 || value.0==63{
							i=7
						}else{
							i=value.0-53+3
							
						}
						
						makePaintResevation(sound: i, x: cwidth/2+cwidth*CGFloat(index), y: cheight/2, card: value.0)
					}//アリス側からの得点操作は不要（最初に一気に配るから）
				}
				
				//cpuの1枚目の表示
				if ccards[0].0<53{
					makePaintResevation(sound: 1, x: cwidth/2, y: frame.size.height-cheight/2, card: ccards[0].0)
				}else if ccards[0].0==54 || ccards[0].0==58 || ccards[0].0==59{//オリヴィエ
					Cards.cBP=3
					makeOlivieResevation(x: cwidth/2, y: frame.size.height-cheight/2, card: ccards[0].0, BPLabel: (pBP: nil, cBP: "3"))
				}else{
					var i:Int
					
					if ccards[0].0==60 || ccards[0].0==61{
						i=5
					}else if ccards[0].0==62 || ccards[0].0==63{
						i=7
					}else{
						i=ccards[0].0-53+3
						
					}
					
					makePaintResevation(sound: i, x: cwidth/2, y: frame.size.height-cheight/2, card: ccards[0].0)
					//アリスの処理は不要
				}
				
				//cpuの2枚目の表示
				makePaintResevation(sound: 1, x: cwidth/2+cwidth, y: frame.size.height-cheight/2, card: 0)
			}

			//Aの得点の確認→preparingSceneで行う
		}
		
		
		//各トランプの得点の値を設定（初期値設定のためこの位置（setcardより後））
		
		for i in Cards.cards{//初期値を設定
			if i.card<53{//トランプ限定
			tPointLabel[i.card-1].text=String(i.point)
			}
		}
		for i in Cards.pcards{
			if i.card<53{
			tPointLabel[i.card-1].text=String(i.point)
			}
		}
		for i in Cards.ccards{
			if i.card<53{
			tPointLabel[i.card-1].text=String(i.point)
			}
		}
		
		// ボタンを設定.
		Buttons().setButtons(frame_height: view.frame.height, frame_width: view.frame.width)

		GameScene.hitButton.addTarget(self, action: #selector(GameScene.onClickHitButton(_:)), for: .touchUpInside)
		GameScene.hitButton.addTarget(self, action: #selector(GameScene.touchDownHitButton(_:)), for: .touchDown) //一旦standボタンを押せないようにする
		GameScene.hitButton.addTarget(self, action: #selector(GameScene.enableButtons(_:)), for: .touchUpOutside)	//押せるように戻す
		GameScene.standButton.addTarget(self, action: #selector(GameScene.onClickStandButton(_:)), for: .touchUpInside)
		GameScene.standButton.addTarget(self, action: #selector(GameScene.touchDownStandButton(_:)), for: .touchDown)
		GameScene.standButton.addTarget(self, action: #selector(GameScene.enableButtons(_:)), for: .touchUpOutside)
		GameScene.resetButton.addTarget(self, action: #selector(GameScene.onClickResetButton(_:)), for: .touchUpInside)
		GameScene.resetButton.addTarget(self, action: #selector(GameScene.touchDownResetButton(_:)), for: .touchDown)
		GameScene.resetButton.addTarget(self, action: #selector(GameScene.enableButtons(_:)), for: .touchUpOutside)
		GameScene.titleButton.addTarget(self, action: #selector(GameScene.onClickTitleButton(_:)), for: .touchUpInside)
		GameScene.titleButton.addTarget(self, action: #selector(GameScene.touchDownTitleButton(_:)), for: .touchDown)
		GameScene.titleButton.addTarget(self, action: #selector(GameScene.enableButtons(_:)), for: .touchUpOutside)
		
		self.view!.addSubview(GameScene.hitButton)
		self.view!.addSubview(GameScene.standButton)
		self.view!.addSubview(GameScene.resetButton)
		self.view!.addSubview(GameScene.titleButton)
		
				
		//BJの判定
		let j=Cards().judge(0)
		if j==5{
			
			draw()
			
			//2枚目を表に向ける
			var ccards=Cards.ccards
			if ccards[1].card<53{
				if Cards.mode == .netp2{
					makeHideAndPaintResevation(sound: 1, x: cwidth/2+cwidth, y: cheight/2, card: ccards[1].card, hide: [0])
				}else{
					makeHideAndPaintResevation(sound: 1, x: cwidth/2+cwidth, y: frame.size.height-cheight/2, card: ccards[1].card, hide: [0])
				}
			}else{
				var i:Int
				if ccards[1].card==58 || ccards[1].card==59{
					i=4
				}else if ccards[1].card==60 || ccards[1].card==61{
					i=5
				}else if ccards[1].card==62 || ccards[1].card==63{
					i=7
				}else{
					i=ccards[1].card-53+3
					
				}
				
				if Cards.mode == .netp2{
					makeHideAndPaintResevation(sound: i, x: cwidth/2+cwidth, y: cheight/2, card: ccards[1].card, hide: [0])
				}else{
					makeHideAndPaintResevation(sound: 1, x: cwidth/2+cwidth, y: frame.size.height-cheight/2, card: ccards[1].card, hide: [0])
				}
			}
			
			pbjLabel.isHidden=false
			cbjLabel.isHidden=false
			ppLabel.isHidden=false
			cpLabel.isHidden=false
			
			Cards.state = .end
			Cards.pcards.removeAll()
			Cards.ccards.removeAll()
			Cards.cards.removeAll()
			if Cards.mode == .netp1{
				nets.sendData()
			}

		}else if j==3{
			
			if Cards.ccards[0].card==57 || Cards.ccards[0].card==62 || Cards.ccards[0].card==63 {//アリスの確認
				Cards.ccards[1].point+=1
				tPointLabel[Cards.ccards[1].card-1].fontColor=SKColor.orange
			}else if Cards.ccards[1].card==57 || Cards.ccards[1].card==62 || Cards.ccards[1].card==63{//アリスの確認
				Cards.ccards[0].point+=1
				tPointLabel[Cards.ccards[0].card-1].fontColor=SKColor.orange
			}
			
			//2枚目を表に向ける
			var ccards=Cards.ccards
			if ccards[1].card<53{
				if Cards.mode == .netp2{
					makeHideAndPaintResevation(sound: 1, x: cwidth/2+cwidth, y: cheight/2, card: ccards[1].card, hide: [0])
				}else{
					makeHideAndPaintResevation(sound: 1, x: cwidth/2+cwidth, y: frame.size.height-cheight/2, card: ccards[1].card, hide: [0])
				}
			}else{
				var i:Int
				if ccards[1].card==58 || ccards[1].card==59{
					i=4
				}else if ccards[1].card==60 || ccards[1].card==61{
					i=5
				}else if ccards[1].card==62 || ccards[1].card==63{
					i=7
				}else{
					i=ccards[1].card-53+3
					
				}

				if Cards.mode == .netp2{
					makeHideAndPaintResevation(sound: i, x: cwidth/2+cwidth, y: cheight/2, card: ccards[1].card, hide: [0])
				}else{
					makeHideAndPaintResevation(sound: 1, x: cwidth/2+cwidth, y: frame.size.height-cheight/2, card: ccards[1].card, hide: [0])
				}
			}
			
			pbjLabel.isHidden=false
			ppLabel.isHidden=false
			cpLabel.isHidden=false
			
			Cards.state = .end
			Cards.pcards.removeAll()
			Cards.ccards.removeAll()
			Cards.cards.removeAll()
			if Cards.mode == .netp1{
				nets.sendData()
			}
			
			pwin()
		}else if j==4{
			
			
			//2枚目を表に向ける
			var ccards=Cards.ccards
			if ccards[1].card<53{
				if Cards.mode == .netp2{
					makeHideAndPaintResevation(sound: 1, x: cwidth/2+cwidth, y: cheight/2, card: ccards[1].card, hide: [0])
				}else{
					makeHideAndPaintResevation(sound: 1, x: cwidth/2+cwidth, y: frame.size.height-cheight/2, card: ccards[1].card, hide: [0])
				}
			}else{
				var i:Int
				
				if ccards[1].card==58 || ccards[1].card==59{
					i=4
				}else if ccards[1].card==60 || ccards[1].card==61{
					i=5
				}else if ccards[1].card==62 || ccards[1].card==63{
					i=7
				}else{
					i=ccards[1].card-53+3
					
				}
				
				if Cards.mode == .netp2{
					makeHideAndPaintResevation(sound: i, x: cwidth/2+cwidth, y: cheight/2, card: ccards[1].card, hide: [0])
				}else{
					makeHideAndPaintResevation(sound: 1, x: cwidth/2+cwidth, y: frame.size.height-cheight/2, card: ccards[1].card, hide: [0])
				}
			}
			
			
			//得点表示
			ppLabel.isHidden=false
			cpLabel.isHidden=false
			cbjLabel.isHidden=false
			
			Cards.state = .end
			Cards.pcards.removeAll()
			Cards.ccards.removeAll()
			Cards.cards.removeAll()
			if Cards.mode == .netp1{
				nets.sendData()
			}

			plose()
		}
	}
	
	override func update(_ currentTime: CFTimeInterval) {
		
		
		let cheight = (view?.frame.height)!/3	//カードの縦の長さは画面サイズによって変わる
		let cwidth = cheight*2/3
		
		//トランプ得点ラベルの位置更新
		for i in 1...52{
			tPointLabel[i-1].position=CGPoint(x:card[i].position.x+cwidth/2-cheight*16/138,y:card[i].position.y+cheight/2-cheight*28/138)
		}
		//トランプ得点ラベルの得点更新
		for i in Cards.pcards{
			if i.card<53{ //Cards.cards.cardは1~57の値を取り、tPointLabelは[0]~[51]まである。
				tPointLabel[i.card-1].text=String(i.point)
			}
		}
		for i in Cards.ccards{
			if i.card<53{ //Cards.cards.cardは1~57の値を取り、tPointLabelは[0]~[51]まである。
				tPointLabel[i.card-1].text=String(i.point)
			}
		}
		
		//ラベルとカードをくっつける
		specialLabels["satanA"]!.position=CGPoint(x:card[53].position.x-cwidth/2+cheight*11/138,y:card[53].position.y-cheight/2+cheight*8/138)
		specialLabels["satanHP"]!.position=CGPoint(x:card[53].position.x+cwidth/2-cheight*11/138,y:card[53].position.y-cheight/2+cheight*8/138)
		specialLabels["olivieA"]!.position=CGPoint(x:card[54].position.x-cwidth/2+cheight*11/138,y:card[54].position.y-cheight/2+cheight*8/138)
		specialLabels["olivieHP"]!.position=CGPoint(x:card[54].position.x+cwidth/2-cheight*11/138,y:card[54].position.y-cheight/2+cheight*8/138)
		specialLabels["bahamutA"]!.position=CGPoint(x:card[55].position.x-cwidth/2+cheight*11/138,y:card[55].position.y-cheight/2+cheight*8/138)
		specialLabels["bahamutHP"]!.position=CGPoint(x:card[55].position.x+cwidth/2-cheight*11/138,y:card[55].position.y-cheight/2+cheight*8/138)
		specialLabels["zeusA"]!.position=CGPoint(x:card[56].position.x-cwidth/2+cheight*11/138,y:card[56].position.y-cheight/2+cheight*8/138)
		specialLabels["zeusHP"]!.position=CGPoint(x:card[56].position.x+cwidth/2-cheight*11/138,y:card[56].position.y-cheight/2+cheight*8/138)
		specialLabels["aliceA"]!.position=CGPoint(x:card[57].position.x-cwidth/2+cheight*11/138,y:card[57].position.y-cheight/2+cheight*8/138)
		specialLabels["aliceHP"]!.position=CGPoint(x:card[57].position.x+cwidth/2-cheight*11/138,y:card[57].position.y-cheight/2+cheight*8/138)
		
		//音の処理
		if GameScene.audioFinish==true {
			if resevation.count>0{
				GameScene.resetButton.isEnabled=false
				GameScene.titleButton.isEnabled=false
				GameScene.hitButton.isEnabled=false
				GameScene.standButton.isEnabled=false
				
				//カードを隠す処理（バハのため、先に隠してから表示）
				for i in resevation[0].hide{
					
					card[i].position=CGPoint(x:-1000,y:0)    //枠外に
					if i<53 && i>0{//トランプ表の得点も隠す
						tPointLabel[i-1].position=CGPoint(x:-1000,y:0)
					}
				}
				
				//カードの表示、移動
				if let cardnum=resevation[0].card{
					card[cardnum].position=CGPoint(x:resevation[0].x!,y:resevation[0].y!)
				}
				
				//音を鳴らす
				switch(resevation[0].sound){
				case 1 : playcard.currentTime=0
				playcard.play()
				GameScene.audioFinish=false
				case 2 : summon.currentTime=0
				summon.play()
				GameScene.audioFinish=false
				case 3 : satanIn.currentTime=0
				satanIn.play()
				GameScene.audioFinish=false
				case 4 : olivieIn.currentTime=0
				olivieIn.play()
				GameScene.audioFinish=false
				case 5 : bahamutIn.currentTime=0
				bahamutIn.play()
				GameScene.audioFinish=false
				case 6 : zeusIn.currentTime=0
				zeusIn.play()
				GameScene.audioFinish=false
				case 7 : aliceIn.currentTime=0
				aliceIn.play()
				GameScene.audioFinish=false
				case 8: breakcard.currentTime=0
				breakcard.play()
				GameScene.audioFinish=false
				default : break
				}
				
				//ppLabel,cpLabelの更新（String,String）
				ppLabel.text=resevation[0].pointLabel.pp
				cpLabel.text=resevation[0].pointLabel.cp
				
				//tPointLabelの更新[(どれ,String,UIColor)]（アリスを３枚め以降引いたときのみ）
				for i in resevation[0].tPointLabel{
					
					tPointLabel[i.index].text=i.value
					tPointLabel[i.index].fontColor=i.color	//(注)fontColor!=color
				}
				
				//pBP,cBPLabelの更新(String,String)
				if let pBP=resevation[0].BPLabel.pBP{
				pBPLabel.text="×"+pBP
				}
				if let cBP=resevation[0].BPLabel.cBP{
				cBPLabel.text="×"+cBP
				}
				
				resevation.removeFirst()
				
			}else{
				GameScene.resetButton.isEnabled=true
				GameScene.titleButton.isEnabled=true
				GameScene.hitButton.isEnabled=true
				GameScene.standButton.isEnabled=true
			}
		}
		
		//通信の処理
		if Cards.mode == .netp1 || Cards.mode == .netp2{
			if last == nil{
				last = currentTime
			}
			
			// 3秒おきに行う処理をかく。
			if last + 1 <= currentTime {
				queue.async {
					
					//				if self.sentfirst==true{    //初期手札を送る前の空データの受信防止
					//サーバーから山札、手札を獲得（1つずつ）
					if Cards.state != .end{
						self.nets.receiveData()
					}
					
					if Cards.state == .br{	  //breakを受信したら強制終了
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
					
					if Cards.mode == .netp1{
						let ccardsc=Cards.ccards.count
						
						if Cards.state == .judge{
							
							//最終判定(ループ外)
							let j=Cards().judge(1)
							if j==0{
								Cards.state = .end
								Cards.pcards.removeAll()
								Cards.cards.removeAll()
								Cards.ccards.removeAll()
								
								self.nets.sendData()	//サーバーをendに更新し、以後の受信を停止
								self.draw()
							}else if j==1{
								Cards.state = .end
								Cards.pcards.removeAll()
								Cards.cards.removeAll()
								Cards.ccards.removeAll()
								
								self.nets.sendData()	//サーバーをendに更新し、以後の受信を停止
								self.pwin()
							}else if j==2{
								Cards.state = .end
								Cards.pcards.removeAll()
								Cards.cards.removeAll()
								Cards.ccards.removeAll()
								
								self.nets.sendData()	//サーバーをendに更新し、以後の受信を停止
								self.plose()
							}
						}
						

						
						if ccardsc != self.fccardsc && (Cards.state == .p2turn||Cards.state == .judge){//更新を受信したとき
							self.playcard.currentTime=0
							self.playcard.play()
							
							let ccards:[(Int,Int)]=Cards.ccards
							
							//2p（敵）の引いた手札を表示
							self.makePaintResevation(sound: 1, x: cwidth/2+cwidth*CGFloat(ccardsc-1), y: self.frame.size.height-cheight/2, card: ccards[ccardsc-1].0)
							
							//敵の得点表示
							self.cpLabel.isHidden=false
							
							self.fccardsc=ccardsc
							//引いた直後にバストの判定(ループ内)
							let j=Cards().judge(1)
							if j==3{
								Cards.state = .end
								Cards.pcards.removeAll()
								Cards.cards.removeAll()
								Cards.ccards.removeAll()
								
								self.nets.sendData()	//サーバーをendに更新し、以後の受信を停止
								
								self.cpLabel.text! += " Bust!!!"
								self.pwin()
							}
							
						}
					}else if Cards.mode == .netp2{
						let pcardsc=Cards.pcards.count    //毎回更新
						if (pcardsc > self.fpcardsc) && (Cards.state == .p1turn||Cards.state == .p2turn){//更新されたら(startはまだ配った手札が来てない状態、end,breakは手札がからの状態、judgeでもエラー発生)
							
							self.playcard.currentTime=0
							self.playcard.play()
							
							let pcards:[(Int,Int)]=Cards.pcards
							
							//1p（敵）の各手札を表示
							
							self.card[pcards[pcardsc-1].0].position=CGPoint(x:cwidth/2+cwidth*CGFloat(pcardsc-1),y:self.frame.size.height-cheight/2)
							
							//敵の得点表示
							self.ppLabel.isHidden=false
							
							self.fpcardsc=pcardsc
							
							//敵のbustの判定
							let j=Cards().judge(1)
							if j==4{
								self.isPaused=true  //updateによる受信防止
								self.ppLabel.text! += " Bust!!!"
								self.plose()
								
								//2枚目を表に向ける
								var ccards=Cards.ccards
								self.makeHideAndPaintResevation(sound: 1, x: cwidth/2+cwidth, y: cheight/2, card: ccards[1].card, hide: [0])
								
								self.isPaused=false
								
								//配列から消す前に各トランプの得点を表示
								for i in Cards.pcards{
									if i.card<53{ //Cards.cards.cardは1~57の値を取り、tPointLabelは[0]~[51]まである。
										self.tPointLabel[i.card-1].position=CGPoint(x:self.card[i.card].position.x+cwidth/2-cheight*16/138,y:self.card[i.card].position.y+cheight/2-cheight*28/138)
										self.tPointLabel[i.card-1].text=String(i.point)
									}
								}
								for i in Cards.ccards{
									if i.card<53{ //Cards.cards.cardは1~57の値を取り、tPointLabelは[0]~[51]まである。
										self.tPointLabel[i.card-1].position=CGPoint(x:self.card[i.card].position.x+cwidth/2-cheight*16/138,y:self.card[i.card].position.y+cheight/2-cheight*28/138)
										self.tPointLabel[i.card-1].text=String(i.point)
									}
								}
								
								self.specialLabels["satanA"]!.position=CGPoint(x:self.card[53].position.x-cwidth/2+cheight*11/138,y:self.card[53].position.y-cheight/2+cheight*8/138)
								self.specialLabels["satanHP"]!.position=CGPoint(x:self.card[53].position.x+cwidth/2-cheight*11/138,y:self.card[53].position.y-cheight/2+cheight*8/138)
								self.specialLabels["olivieA"]!.position=CGPoint(x:self.card[54].position.x-cwidth/2+cheight*11/138,y:self.card[54].position.y-cheight/2+cheight*8/138)
								self.specialLabels["olivieHP"]!.position=CGPoint(x:self.card[54].position.x+cwidth/2-cheight*11/138,y:self.card[54].position.y-cheight/2+cheight*8/138)
								self.specialLabels["bahamutA"]!.position=CGPoint(x:self.card[55].position.x-cwidth/2+cheight*11/138,y:self.card[55].position.y-cheight/2+cheight*8/138)
								self.specialLabels["bahamutHP"]!.position=CGPoint(x:self.card[55].position.x+cwidth/2-cheight*11/138,y:self.card[55].position.y-cheight/2+cheight*8/138)
								self.specialLabels["zeusA"]!.position=CGPoint(x:self.card[56].position.x-cwidth/2+cheight*11/138,y:self.card[56].position.y-cheight/2+cheight*8/138)
								self.specialLabels["zeusHP"]!.position=CGPoint(x:self.card[56].position.x+cwidth/2-cheight*11/138,y:self.card[56].position.y-cheight/2+cheight*8/138)
								self.specialLabels["aliceA"]!.position=CGPoint(x:self.card[57].position.x-cwidth/2+cheight*11/138,y:self.card[57].position.y-cheight/2+cheight*8/138)
								self.specialLabels["aliceHP"]!.position=CGPoint(x:self.card[57].position.x+cwidth/2-cheight*11/138,y:self.card[57].position.y-cheight/2+cheight*8/138)
								
								Cards.state = .end
								Cards.pcards.removeAll()
								Cards.cards.removeAll()
								Cards.ccards.removeAll()
								self.nets.sendData()	//サーバーをendに更新し、以後の受信を停止
							}
						}
						if Cards.state == .p2turn && self.didchange==false{//こちらにターンが回ってきたとき
							
							GameScene.hitButton.isHidden=false
							GameScene.standButton.isHidden=false
							
							//2枚目を表に向ける
							var ccards=Cards.ccards
							self.makeHideAndPaintResevation(sound: 1, x: cwidth/2+cwidth, y: cheight/2, card: ccards[1].card, hide: [0])
							
							//得点を表示する
							self.cpLabel.isHidden=false
							self.centerLabel.text="あなたのターン"
							
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
		
		if Cards.mode == .com || Cards.mode == .scom {
			let ccards=Cards.ccards	  //バハによる除去前の敵の手札
			var (pcards,_)=Cards().hit()
			
			//Aの得点の確認
			let (ppoint,_,_,_)=Cards().calculatepoints()
			for (index,value) in Cards.pcards.enumerated(){
				if value.card<53{//トランプ限定
					if value.card%13 == 1 && ppoint.inA<22{
						Cards.pcards[index].point+=10
						tPointLabel[value.card-1].text=String(Cards.pcards[index].point)
						break	  //二枚目以降は更新しない
					}
					if value.card%13==1 && value.point>9{
						if ppoint.noA>21{
							Cards.pcards[index].point-=10
							tPointLabel[value.card-1].text=String(Cards.pcards[index].point)
							break //後に直すべきAはないはず
						}
					}
				}
			}
			
			//手札追加
			if pcards[2+hcounter].0<53{//引いたのがトランプのとき
				for i in Cards.pcards{//アリスの確認
					if i.card==57 || i.card==62 || i.card==63{
						Cards.pcards[2+hcounter].point+=1
						tPointLabel[Cards.pcards[2+hcounter].card-1].fontColor=SKColor.orange
					}
				}
				
				makePaintResevation(sound: 1, x: cwidth/2+cwidth*CGFloat(2+hcounter), y: cheight/2, card: pcards[2+hcounter].0)
			}else if pcards[2+hcounter].0==54 || pcards[2+hcounter].0==58 || pcards[2+hcounter].0==59 {//オリヴィエ
				Cards.pBP=3
				makeOlivieResevation(x: cwidth/2+cwidth*CGFloat(2+hcounter), y: cheight/2, card: pcards[2+hcounter].0, BPLabel: ("3",nil))
			}else if pcards[2+hcounter].0==57 || pcards[2+hcounter].0==62 || pcards[2+hcounter].0==63{//アリス
				var changeTPointLabels:[(index:Int,value:String,color:UIColor?)]=[]
				for (index,value) in Cards.pcards.enumerated(){
					if value.card<53{//トランプの得点を増やす
						Cards.pcards[index].point+=1
						changeTPointLabels.append((value.card-1,String(Cards.pcards[index].point),SKColor.orange))
					}else{
						//特殊カードの攻撃、体力を増やす
					}
				}
				makeAliceResevation(x: cwidth/2+cwidth*CGFloat(2+hcounter), y: cheight/2, card: pcards[2+hcounter].0, tPointLabel: changeTPointLabels)
			}else{
				var i:Int
				if pcards[2+hcounter].0==60 || pcards[2+hcounter].0==61{
					i=5
				}else{
					i=pcards[2+hcounter].0-53+3
					
				}
				makePaintResevation(sound: i, x: cwidth/2+cwidth*CGFloat(2+hcounter), y: cheight/2, card: pcards[2+hcounter].0)//特殊カードの表示
				if pcards[2+hcounter].0==55 || pcards[2+hcounter].0==60 || pcards[2+hcounter].0==61{//バハ
					hcounter = -2
					scounter = -2 //敵の手札も消える
					var remove=[0]
					for i in pcards{
						remove.append(i.0)
					}
					for i in ccards{
						remove.append(i.0)
					}
					
					//全カードの除去&バハを再び表示
					makeHideAndPaintResevation(sound: 8, x: cwidth/2, y: cheight/2, card: 55, hide: remove)//再表示は現状55にしておく
					Cards.pcards.removeAll()
					Cards.ccards.removeAll()
					Cards.pcards.append((55,10))
				}
			}

			
			
			//バストの判定
			var j=Cards().judge(1)
			
			while j==4{
				if Cards.pBP>0 {
					Cards.pBP -= 1	//--は抹消された...
					
					let removecard=Cards.pcards.last!.card	//消す前に保存
					Cards.pcards.removeLast()
					makeUseBPResevation(hide: [removecard], BPLabel: (String(Cards.pBP),nil)) //得点計算のためremoveLastの後
					hcounter-=1
					
					j=Cards().judge(1)
					continue
				}else{
					ppLabel.text! += " Bust!!!"
					plose()
					
					//2枚目を表に向ける
					var ccards=Cards.ccards
					if ccards.count>0{//バハで消えてないか確認
						if ccards[1].card<53{
							makeHideAndPaintResevation(sound: 1, x: cwidth/2+cwidth, y: frame.size.height-cheight/2, card: ccards[1].card, hide: [0])
						}else{
							var i:Int
							
							if ccards[1].card==58 || ccards[1].card==59{
								i=4
							}else if ccards[1].card==60 || ccards[1].card==61{
								i=5
							}else if ccards[1].card==62 || ccards[1].card==63{
								i=7
							}else{
								i=ccards[1].card-53+3
								
							}
							
							makeHideAndPaintResevation(sound: i, x: cwidth/2+cwidth, y: frame.size.height-cheight/2, card: ccards[1].card, hide: [0])
						}
					}
					//敵の得点を表示
					cpLabel.isHidden=false
					
					break
				}
			}
			
			hcounter+=1
			
		}else if Cards.mode == .pvp{
			if scounter==0{ //p1のターンで押されたとき
				let (pcards,_)=Cards().hit()
				
				//Aの得点の確認
				let (ppoint,_,_,_)=Cards().calculatepoints()
				for (index,value) in Cards.pcards.enumerated(){
					if value.card<53{//トランプ限定
						if value.card%13 == 1 && ppoint.inA<22{
							Cards.pcards[index].point+=10
							tPointLabel[value.card-1].text=String(Cards.pcards[index].point)
							break	  //二枚目以降は更新しない
						}
						if value.card%13==1 && value.point>9{
							if ppoint.noA>21{
								Cards.pcards[index].point-=10
								tPointLabel[value.card-1].text=String(Cards.pcards[index].point)
								break //後に直すべきAはないはず
							}
						}
					}
				}
				
				//p1の手札追加&得点の更新
				makePaintResevation(sound: 1, x: cwidth/2+cwidth*CGFloat(2+hcounter), y: cheight/2, card: pcards[2+hcounter].0)
				
				
				
				hcounter+=1
				
				//バストの判定
				let j=Cards().judge(1)
				if j==4{
					ppLabel.text! += " Bust!!!"
					plose()
					
					//2枚目を表に向ける
					var ccards=Cards.ccards
					if ccards[1].card<53{
						makeHideAndPaintResevation(sound: 1, x: cwidth/2+cwidth, y: frame.size.height-cheight/2, card: ccards[1].card, hide: [0])
					}else{
						var i:Int
						
						if ccards[1].card==58 || ccards[1].card==59{
							i=4
						}else if ccards[1].card==60 || ccards[1].card==61{
							i=5
						}else if ccards[1].card==62 || ccards[1].card==63{
							i=7
						}else{
							i=ccards[1].card-53+3
							
						}
						
						makeHideAndPaintResevation(sound: i, x: cwidth/2+cwidth, y: frame.size.height-cheight/2, card: ccards[1].card, hide: [0])
					}
					
					//得点を表示する
					cpLabel.isHidden=false
				}
			}else if scounter==1{	//p2のターン
				let (ccards,_)=Cards().stand() //カードを引く
				
				
				//Aの得点の確認
				let (_,cpoint,_,_)=Cards().calculatepoints()
				for (index,value) in Cards.ccards.enumerated(){
					if value.card<53{//トランプ限定
						if value.point==1 && cpoint.inA<22{
							Cards.ccards[index].point+=10
							tPointLabel[value.card-1].text=String(Cards.ccards[index].point)
							break	  //二枚目以降は更新しない
						}
						if value.card%13==1 && value.point>9 && cpoint.noA>21{
							Cards.ccards[index].point-=10
							tPointLabel[value.card-1].text=String(Cards.ccards[index].point)
							break //後に直すべきAはないはず
						}
					}
				}
				
				//手札追加&得点更新
				makePaintResevation(sound: 1, x: cwidth/2+cwidth*CGFloat(2+chcounter), y: frame.size.height-cheight/2, card: ccards[2+chcounter].0)
				
				
				
				//引いた直後にバストの判定(ループ内)
				let j=Cards().judge(1)
				if j==3{
					cpLabel.text! += " Bust!!!"
					pwin()
					
				}
				chcounter+=1
			}

		}else if Cards.mode == .netp1{
			repeat { //最新まで受信(受信防止しているが、後で更新時に前のデータを受信するとバグる）
				nets.receiveData()  //送信前に受信(stand時のみ)（押した瞬間に）
			}while net.isLatest==false
			
			let (pcards,_)=Cards().hit()
			
			//Aの得点の確認
			let (ppoint,_,_,_)=Cards().calculatepoints()
			for (index,value) in Cards.pcards.enumerated(){
				if value.card<53{//トランプ限定
					if value.card%13 == 1 && ppoint.inA<22{
						Cards.pcards[index].point+=10
						tPointLabel[value.card-1].text=String(Cards.pcards[index].point)
						break	  //二枚目以降は更新しない
					}
					if value.card%13==1 && value.point>9{
						if ppoint.noA>21{
							Cards.pcards[index].point-=10
							tPointLabel[value.card-1].text=String(Cards.pcards[index].point)
							break //後に直すべきAはないはず
						}
					}
				}
			}
			
			//p1の手札追加&得点の更新
			makePaintResevation(sound: 1, x: cwidth/2+cwidth*CGFloat(2+hcounter), y: cheight/2, card: pcards[2+hcounter].0)
			
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
					makeHideAndPaintResevation(sound: 1, x: cwidth/2+cwidth, y: frame.size.height-cheight/2, card: ccards[1].card, hide: [0])
				}else{
					
					var i:Int
					
					if ccards[1].card==58 || ccards[1].card==59{
						i=4
					}else if ccards[1].card==60 || ccards[1].card==61{
						i=5
					}else if ccards[1].card==63 || ccards[1].card==62{
						i=7
					}else{
						i=ccards[1].card-53+3
						
					}
					makeHideAndPaintResevation(sound: i, x: cwidth/2+cwidth, y: frame.size.height-cheight/2, card: ccards[1].card, hide: [0])
				}
				
				//得点を表示する
				cpLabel.isHidden=false
			}
		}else{//netp2
			repeat { //最新まで受信（こっちの状態を送信する直前のデータを受信した状態だとエラー）
				nets.receiveData()  //送信前に受信(stand時のみ)（押した瞬間に）
			}while net.isLatest==false
			
			let (ccards,_)=Cards().stand() //カードを引く
			
			//Aの得点の確認
			let (_,cpoint,_,_)=Cards().calculatepoints()
			for (index,value) in Cards.ccards.enumerated(){
				if value.card<53{//トランプ限定
					if value.point==1 && cpoint.inA<22{
						Cards.ccards[index].point+=10
						tPointLabel[value.card-1].text=String(Cards.ccards[index].point)
						break	  //二枚目以降は更新しない
					}
					if value.card%13==1 && value.point>9 && cpoint.noA>21{
						Cards.ccards[index].point-=10
						tPointLabel[value.card-1].text=String(Cards.ccards[index].point)
						break //後に直すべきAはないはず
					}
				}
			}
			
			//手札追加&得点更新
			makePaintResevation(sound: 1, x: cwidth/2+cwidth*CGFloat(2+chcounter), y: cheight/2, card: ccards[2+chcounter].0)
			
			nets.sendData()
			
			//引いた直後にバストの判定(ループ内)
			let j=Cards().judge(1)
			if j==3{
				
				cpLabel.text! += " Bust!!!"
				pwin()
				
			}
			
			chcounter+=1
			
		}
		
		self.isPaused=false
		
	}
	
	func onClickStandButton(_ sender : UIButton){
		self.isPaused=true  //updateによる受信防止
		
		let cheight = (view?.frame.height)!/3	//フィールドの1パネルの大きさは画面サイズによって変わる
		let cwidth = cheight*2/3
		
		if Cards.mode != .netp2{
			//2枚目を表に向ける
			var ccards=Cards.ccards
			if ccards.count>0{//バハで消えてないか確認
				if ccards[1].card<53{
					

					if Cards.ccards[0].card==57 || Cards.ccards[0].card==62 || Cards.ccards[0].card==63{//アリスの確認
						Cards.ccards[1].point+=1
						tPointLabel[ccards[1].card-1].fontColor=SKColor.orange
						tPointLabel[ccards[1].card-1].text=String(Cards.ccards[1].point)
					}
					makeHideAndPaintResevation(sound: 1, x: cwidth/2+cwidth, y: frame.size.height-cheight/2, card: ccards[1].card, hide: [0])
					
				}else{//特殊カード
					
					//まず裏を隠し、登場音とともに登場させる
					var i:Int
					
					if ccards[1].card==58 || ccards[1].card==59{
						i=4
					}else if ccards[1].card==60 || ccards[1].card==61{
						i=5
					}else if ccards[1].card==62 || ccards[1].card==63{
						i=7
					}else{
						i=ccards[1].card-53+3
						
					}
					
					makeHideAndPaintResevation(sound: i, x: cwidth/2+cwidth, y: frame.size.height-cheight/2, card: ccards[1].card, hide: [0])
					
					//各特殊能力の処理（登場音は済なので不要）
					if ccards[1].card==55 || ccards[1].0==60 || ccards[1].0==61{//バハ
						let pcards=Cards.pcards
						scounter = -1
						var remove:[Int]=[]
						for i in pcards{
							remove.append(i.card)
						}
						for i in ccards{
							remove.append(i.card)
						}
						
						makeHideAndPaintResevation(sound: 8, x: cwidth/2, y: frame.size.height-cheight/2, card: 55, hide: remove)
						Cards.pcards.removeAll()
						Cards.ccards.removeAll()
						Cards.ccards.append((55,10))
					}else if ccards[1].card==54  || ccards[1].0==58 || ccards[1].0==59{//オリヴィエ
						Cards.cBP=3
						cBPLabel.text="×3"
					}else if ccards[1].card==57 || ccards[1].card==62 || ccards[1].card==63{//アリス
						if ccards[0].card<53{//トランプの得点を増やす
							Cards.ccards[0].point+=1
							tPointLabel[ccards[0].card-1].fontColor=SKColor.orange
						}else{
							//特殊カードの攻撃、体力を増やす
						}
					}
					
				}
			}
			
			
			
			//得点を表示する
			cpLabel.isHidden=false
		}
		
		if Cards.mode == .com || Cards.mode == .scom {
			var j=Cards().judge(1)
			while j != 3{//バストしてない間
				//引く前に次に引くべきかを判定
				var (ppoint,cpoint,_,_)=Cards().calculatepoints()
				if cpoint.noA>16 && cpoint.noA>ppoint.noA{//17以上でcomが勝ってるとき
					break
				}else if cpoint.noA>16 && Cards.cBP==0{//17以上でBPがもうないとき
					break
				}
				
				let pcards=Cards.pcards
				var (ccards,_)=Cards().stand()
				
				//Aの得点の確認
				(_,cpoint,_,_)=Cards().calculatepoints()
				for (index,value) in Cards.ccards.enumerated(){
					if value.card<53{//トランプ限定
						if value.point==1 && cpoint.inA<22{
							Cards.ccards[index].point+=10
							tPointLabel[value.card-1].text=String(Cards.ccards[index].point)
							break	  //二枚目以降は更新しない
						}
						if value.card%13==1 && value.point>9 && cpoint.noA>21{
							Cards.ccards[index].point-=10
							tPointLabel[value.card-1].text=String(Cards.ccards[index].point)
							break //後に直すべきAはないはず
						}
					}
				}
				
				//手札追加&得点更新
				if ccards[2+scounter].0<53{
					for i in Cards.ccards{//アリスの確認
						if i.card==57 || i.card==62 || i.card==63{
							Cards.ccards[2+scounter].point+=1
							tPointLabel[Cards.ccards[2+scounter].card-1].fontColor=SKColor.orange
							
						}
					}
					
					makePaintResevation(sound: 1, x: cwidth/2+cwidth*CGFloat(2+scounter), y: frame.size.height-cheight/2, card: ccards[2+scounter].0)
					//アリスがある場合のtpointlabelの更新は？→即時
					
				}else if ccards[2+scounter].0==54 || ccards[2+scounter].0==58 || ccards[2+scounter].0==59{//オリヴィエ
					Cards.cBP=3
					makeOlivieResevation(x: cwidth/2+cwidth*CGFloat(2+scounter), y: frame.size.height-cheight/2, card: ccards[2+scounter].0, BPLabel: (nil,"3"))
				}else if ccards[2+scounter].0==57 || ccards[2+scounter].0==62 || ccards[2+scounter].0==63{//アリス
					
					var changeTPointLabels:[(index:Int,value:String,color:UIColor?)]=[]
					for (index,value) in Cards.ccards.enumerated(){
						if value.card<53{//トランプの得点を増やす
							Cards.ccards[index].point+=1
							changeTPointLabels.append((value.card-1,String(Cards.ccards[index].point),SKColor.orange))
						}else{
							//特殊カードの攻撃、体力を増やす
						}
					}
					makeAliceResevation(x: cwidth/2+cwidth*CGFloat(2+scounter), y: frame.size.height-cheight/2, card: ccards[2+scounter].0, tPointLabel: changeTPointLabels)
				}else{//その他の特殊カード
					var i:Int
					if ccards[2+scounter].0==60 || ccards[2+scounter].0==61{
						i=5
					}else{
						i=ccards[2+scounter].0-53+3
					}
					makePaintResevation(sound: i, x: cwidth/2+cwidth*CGFloat(2+scounter), y: frame.size.height-cheight/2, card: ccards[2+scounter].0)
					if ccards[2+scounter].0==55 || ccards[2+scounter].0==60 || ccards[2+scounter].0==61{//バハ
						scounter = -2
						var remove:[Int]=[]
						for i in pcards{
							remove.append(i.card)
						}
						for i in ccards{
							remove.append(i.0)
						}
						makeHideAndPaintResevation(sound: 8, x: cwidth/2, y: frame.size.height-cheight/2, card: 55, hide: remove)
						Cards.pcards.removeAll()
						Cards.ccards.removeAll()
						Cards.ccards.append((55,10))
						
					}
				}
				
				//引いた直後にバストの判定(ループ内)
				j=Cards().judge(1)
				while j==3{
					if Cards.cBP>0 && Cards.mode == .scom{//シャドウジャックのみ
						Cards.cBP -= 1	//--は抹消された...
						let removecard=Cards.ccards.last!.card//消す前に保存
						Cards.ccards.removeLast()
						
						makeUseBPResevation(hide: [removecard], BPLabel: (nil,String(Cards.cBP)))//得点計算のためremoveLastの後
						scounter-=1
						
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
		}else if Cards.mode == .pvp {
			if scounter==0{ //p2のターンへ移行
				
				scounter+=1
				
				centerLabel.text="P2のターン"
				
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

		}else if Cards.mode == .netp1 {
			repeat { //最新まで受信
				nets.receiveData()  //送信前に受信(stand時のみ)（押した瞬間に）
			}while net.isLatest==false
			
			centerLabel.text="相手のターン"
			
			Cards.state = .p2turn
			nets.sendData()
			
			GameScene.hitButton.isHidden=true
			GameScene.standButton.isHidden=true
			self.isPaused=false

		}else {//netp2
			repeat { //最新まで受信（こっちの状態を送信する直前のデータを受信した状態だとエラー）
				nets.receiveData()  //送信前に受信(stand時のみ)（押した瞬間に）
			}while net.isLatest==false
			Cards.state = .judge
			nets.sendData()
			Cards.state = .end	  //今後の受信を停止
			
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
		
		if Cards.mode == .pvp{
			centerLabel.text="P1 Win!"
		}else if Cards.mode == .netp2{
			centerLabel.text="You Lose..."
		}else {
			centerLabel.text = "You Win!"
		}
		endofthegame()
	}
	
	func plose(){
		
		GameScene.hitButton.isHidden=true
		GameScene.standButton.isHidden=true
		
		if Cards.mode == .pvp{
			centerLabel.text="P2 Win!"
		}else if Cards.mode == .netp2{
			centerLabel.text="You Win!"
		}else {
			centerLabel.text = "You Lose..."
		}
		endofthegame()
	}
	
	func draw(){  //引き分け！「描く」とは関係ない！
		
		GameScene.hitButton.isHidden=true
		GameScene.standButton.isHidden=true
		
		
		
		centerLabel.text = "Draw"
		
		endofthegame()
	}
	
	func endofthegame(){
		// リセット、タイトルボタンを表示.
		GameScene.resetButton.isHidden=false
		
		GameScene.titleButton.isHidden=false

	}
	
	func onClickResetButton(_ sender : UIButton){
		if Cards.mode == .pvp || Cards.mode == .com || Cards.mode == .scom{
			//クラス変数を初期化
			Cards.pcards.removeAll()
			Cards.cards.removeAll()
			Cards.ccards.removeAll()
		}
		//ボタンを隠す
		GameScene.resetButton.isHidden=true
		GameScene.titleButton.isHidden=true
		
		if Cards.mode == .pvp || Cards.mode == .com || Cards.mode == .scom{
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
		if Cards.mode == .pvp || Cards.mode == .com || Cards.mode == .scom{
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
	func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {//playしたクラスと同じクラスに入れる必要あり？
		GameScene.audioFinish=true
		print("呼び出し成功")
	}
	// デコード中にエラーが起きた時に呼ばれるメソッド
	func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?){
		print(error as Any)
	}
}



