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


enum results{//centerLabelへの受け渡し用
	case pWin,pLose,draw,wait,pBJ,cBJ,bothBJ
}
enum specialLabelNames{
	case satanA,satanHP,olivieA,olivieHP,bahamutA,bahamutHP,zeusA,zeusHP,aliceA,aliceHP,olivieA2,olivieHP2,bahamutA2,bahamutHP2
	,aliceA2,aliceHP2,olivieA3,olivieHP3,bahamutA3,bahamutHP3,aliceA3,aliceHP3,luciferA,luciferHP,luciferA2,luciferHP2,luciferA3,luciferHP3
}


class GameScene: Sounds{  //描写などの処理を主に行うクラス。音の再生終了の通知を受け取るためDelegateを実装。(SKSceneはSoundsで継承)
	//Buttons.swift,Labels.swift,Images.swiftでこのクラスを拡張している。

	
	var pScrollNode: ScrollNode!
	var cScrollNode: ScrollNode!
	var last:CFTimeInterval!
	let queue = DispatchQueue.main    //メインスレッド
	let nets = net()	//netクラスのインスタンス化
	var didchange = false   //攻守交代(netp2用)
	var comRoop = false	//(com,scom用)
	var showResult = results.wait //centerLabelに結果を表示する
	static var cheight: CGFloat!
	static var cwidth: CGFloat!
	static var frameHeight: CGFloat!
	static var frameWidth: CGFloat!
	
//	//カード
	static var backCard = Card(cardNum: 0)!
	
	//画像
	var pBPim = SKSpriteNode()
	var cBPim = SKSpriteNode()
	
	
	
	//ラベル
	var pBPLabel = SKLabelNode(fontNamed: "HiraginoSans-W6")//BP
	var cBPLabel = SKLabelNode(fontNamed: "HiraginoSans-W6")
	var ppLabel = SKLabelNode(fontNamed: "HiraginoSans-W6") //得点表示用のラベル
	var cpLabel = SKLabelNode(fontNamed: "HiraginoSans-W6")
	var pbjLabel = SKLabelNode(fontNamed: "HiraginoSans-W6") //bj表示用のラベル
	var cbjLabel = SKLabelNode(fontNamed: "HiraginoSans-W6")
	var centerLabel = SKLabelNode(fontNamed: "HiraginoSans-W6")	//ターンや最終結果を表示
	var p1Label = SKLabelNode(fontNamed: "HiraginoSans-W6")	//p1,comと表示
	var comLabel = SKLabelNode(fontNamed: "HiraginoSans-W6")


	//ボタンを生成
	var hitButton = UIButton()
	var standButton = UIButton()
	var resetButton = UIButton()
	var titleButton = UIButton()
	
	var scounter = 0	//pvpで、ターン確認用
	var fccardsc = 2	//p2の手札の数(更新前)
	var fpcardsc = 0	//p1の手札の数(更新前)
	static var audioFinish = true
	static var resevation:[(sound:SoundType, paint:[(x:CGFloat?, y:CGFloat?, card:Card?)], repaint:[(x:CGFloat, y:CGFloat, card:Card)], hide:[Card], pointLabels:(pp:String?,cp:String?), tPointLabels:[(card:Card, value:String, color:UIColor?)], BPLabels:(pBP:String?,cBP:String?))] = []	//音付き描写の予約（音のみの場合もあり）をタプルの配列で表現
	//tPointLabelの変更は現時点でアリス召喚、退場時のみ
	
	
	
	
	//resevationに代入する関数群
	static func makePaintResevation(sound:SoundType, x:CGFloat?, y:CGFloat?, card:Card?){//カード表示と持ち点のみ(トランプ、特殊カードを引いたとき用、持ち点は代入時の値を取得して代入)
		GameScene.resevation.append((sound,[(x,y,card)],[],[],Game().getpoints(),[],(nil,nil)))
	}
	static func makeAliceResevation(x:CGFloat?,y:CGFloat?,card:Card?,tPointLabel:[(card:Card,value:String,color:UIColor?)]){//カード表示と得点群のみ(アリス引いたとき用)
		var TPLabel = tPointLabel
		if TPLabel.count > 0{
		for i in 1...TPLabel.count{
			TPLabel[i-1].color = SKColor.orange
			}
		}
		GameScene.resevation.append((.aliceIn,[(x,y,card)],[],[],(nil,nil),[],(nil,nil)))
		GameScene.resevation.append((.debuffField,[],[],[],Game().getpoints(),TPLabel,(nil,nil)))
	}
	static func makeOlivieResevation(x:CGFloat?,y:CGFloat?,card:Card?,BPLabel:(pBP:String?,cBP:String?)){//カード表示と持ち点、BPのみ(オリヴィエ引いたとき用)
		GameScene.resevation.append((.olivieIn,[(x,y,card)],[],[],Game().getpoints(),[],(nil,nil)))
		GameScene.resevation.append((.BP3,[],[],[],(nil,nil),[],BPLabel))
	}
	static func makeLuciferCureResevation(){//バスト時に回復する用
		GameScene.resevation.append((.luciferEffect,[],[],[],(nil,nil),[],(nil,nil)))
		GameScene.resevation.append((.cure,[],[],[],Game().getpoints(),[],(nil,nil)))
	}
	static func makeHideAndPaintResevation(sound:SoundType,x:CGFloat?,y:CGFloat?,card:Card?,hide:[Card]){//カード表示と非表示、持ち点のみ(バハムートの効果｛→破壊音8｝、comの２枚目｛→カード音1or特殊カード音3~7｝用)
		
		GameScene.resevation.append((sound,[(x,y,card)],[],hide,Game().getpoints(),[],(nil,nil)))
	}
	static func makeUseBPResevation(hide:[Card],BPLabel:(pBP:String?,cBP:String?)){//カード非表示と、持ち点、BPのみ(bust回避用)
		GameScene.resevation.append((.extinction,[],[],hide,Game().getpoints(),[],BPLabel))
	}
	static func makeDaliceLastResevation(hide:[Card]){
		GameScene.resevation.append((sound: .daliceLast, paint: [], repaint: [], hide: [], pointLabels: Game().getpoints(), tPointLabels: [], BPLabels: (pBP: nil, cBP: nil)))
		
		if hide.count > 0 {
			GameScene.resevation.append((sound: .extinction, paint: [], repaint: [], hide: hide, pointLabels: Game().getpoints(), tPointLabels: [], BPLabels: (pBP: nil, cBP: nil)))
		}
		
		
	}
	
	
	override func didMove(to view: SKView) {//このシーンに移ったときに最初に実行される
		
		Game.firstDealed = false
		
		GameScene.resevation.append((sound: .none, paint:[], repaint:[], hide: [], pointLabels: (pp: nil, cp: nil), tPointLabels: [], BPLabels: (pBP: nil, cBP: nil)))
		
		Game.pBP = 2
		Game.cBP = 3
		
		Game.adjustPoints = (0, 0)
		
		/*音の設定*/
		setAllSounds()
		
		playcard.delegate = self//デリゲート先（通知先）に自分を設定する。
		summon.delegate = self
		satanIn.delegate = self
		olivieIn.delegate = self
		bahamutIn.delegate = self
		zeusIn.delegate = self
		aliceIn.delegate = self
		luciferIn.delegate = self
		luciferEffect.delegate = self
		bbIn.delegate = self
		daliceIn.delegate = self
		daliceLast.delegate = self
		breakcard.delegate = self
		BP3Sound.delegate = self
		cureSound.delegate = self
		debuffSound.delegate = self
		extinction.delegate = self
		
		
		/*描写物の設定*/
		GameScene.cheight = view.frame.height/3	//カードの縦の長さは画面サイズによって変わる。7+で138?
		GameScene.cwidth = GameScene.cheight*2/3
		GameScene.frameHeight = view.frame.height
		GameScene.frameWidth = view.frame.width
		
		//スクロールノード TODO:可変長に
		self.pScrollNode = ScrollNode(size: CGSize(width: GameScene.cwidth*10, height: GameScene.cheight) ,position: CGPoint(x:0, y:0) )
		self.cScrollNode = ScrollNode(size: CGSize(width: GameScene.cwidth*10, height: GameScene.cheight) ,position: CGPoint(x:0, y:view.frame.height - GameScene.cheight) )
		pScrollNode.zPosition = 0
		cScrollNode.zPosition = 0
		self.addChild(pScrollNode)
		self.addChild(cScrollNode)
		
		//ラベル
		setLabels()
		
		//背景
		if Game.mode == .scom{
			backgroundColor = SKColor.init(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.5)
		}else{
			backgroundColor = SKColor.init(red: 0, green: 0.5, blue: 0, alpha: 0.1)
		}
		
		
		//画像
		setImages()
		
		//配る
		if Game.mode == .com || Game.mode == .scom || Game.mode == .pvp{
			//最初の手札を獲得(pの手札、cの手札、pの得点、cの得点)
			Game().setCards()
			
			//Aの得点の確認
			checkA()
			
			//各手札を表示(hit内に移動)
			
		}else{//ネット系
			
			let pcards:[Card] = Game.pcards
			let ccards:[Card] = Game.ccards
			
			if Game.mode == .netp2{
				//1p（敵）の各手札を表示
				for (index,value) in pcards.enumerated(){
					GameScene.makePaintResevation(sound: .card, x: GameScene.cwidth/2+GameScene.cwidth*CGFloat(index), y: self.frame.size.height-GameScene.cheight/2, card: value)
				}
				
				//2pの1枚目は表,2枚目は裏向き
				GameScene.makePaintResevation(sound: .card, x: GameScene.cwidth/2, y: GameScene.cheight/2, card: ccards[0])
				GameScene.makePaintResevation(sound: .card, x: GameScene.cwidth/2+GameScene.cwidth, y: GameScene.cheight/2, card: GameScene.backCard)
			}else{//netp1
				
				//各手札を表示
				for (index,value) in pcards.enumerated(){//プレイヤー側
					GameScene.makePaintResevation(sound: .card, x: GameScene.cwidth/2+GameScene.cwidth*CGFloat(index), y: GameScene.cheight/2, card: value)
					
				}
				
				//cpuの1枚目の表示
				
				GameScene.makePaintResevation(sound: .card, x: GameScene.cwidth/2, y: frame.size.height-GameScene.cheight/2, card: ccards[0])
				
				
				//cpuの2枚目の表示
				GameScene.makePaintResevation(sound: .card, x: GameScene.cwidth/2+GameScene.cwidth, y: frame.size.height-GameScene.cheight/2, card: GameScene.backCard)
			}
			
			//Aの得点の確認→preparingSceneで行う
		}
		
		
		// ボタンを設定.
		setButtons(frame_height: view.frame.height, frame_width: view.frame.width)

		//BJの判定
		let j = Game().judge(0)
		if j == 5{//両方がbj
			
			showResult = .bothBJ
			
			draw()
			
			//2枚目を表に向ける
			var ccards = Game.ccards
			if ccards[1].cardNum < 53{
				if Game.mode == .netp2{
					GameScene.makeHideAndPaintResevation(sound: .card, x: GameScene.cwidth/2+GameScene.cwidth, y: GameScene.cheight/2, card: ccards[1], hide: [GameScene.backCard])
				}else{
					GameScene.makeHideAndPaintResevation(sound: .card, x: GameScene.cwidth/2+GameScene.cwidth, y: frame.size.height-GameScene.cheight/2, card: ccards[1], hide: [GameScene.backCard])
				}
			}else if let SC = ccards[1] as? SpecialCard{
				
				GameScene.resevation.append((sound: .none, paint: [], repaint: [], hide: [GameScene.backCard], pointLabels: Game().getpoints(), tPointLabels: [], BPLabels: (pBP: nil, cBP:nil)))
				
				if Game.mode == .netp2{
					SC.fanfare(cardPlace: .p1, index: 1)
					
				}else{
					SC.fanfare(cardPlace: .com, index: 1)
					
				}
			}
			if Game.mode == .netp2{
				for j in Game.pcards{//場にある分の効果を確認
					if let SC2 = j as? SpecialCard{
						SC2.drawEffect(drawPlayer: .p1)
					}
				}
				for j in Game.ccards{//場にある分の効果を確認
					if let SC2 = j as? SpecialCard{
						SC2.drawEffect(drawPlayer: .p1)
					}
				}
			}else{
				for j in Game.pcards{//場にある分の効果を確認
					if let SC2 = j as? SpecialCard{
						SC2.drawEffect(drawPlayer: .com)
					}
				}
				for j in Game.ccards{//場にある分の効果を確認
					if let SC2 = j as? SpecialCard{
						SC2.drawEffect(drawPlayer: .com)
					}
				}
			}
	
			Game.state = .end
			Game.pcards.removeAll()
			Game.ccards.removeAll()
			Game.deckCards.removeAll()
			if Game.mode == .netp1{
				nets.sendData()
			}
			
		}else if j == 3{//pがbj
			
			//2枚目を表に向ける
			var ccards = Game.ccards
			if ccards[1].cardNum < 53{
				
				
				if Game.mode == .netp2{
					GameScene.makeHideAndPaintResevation(sound: .card, x: GameScene.cwidth/2+GameScene.cwidth, y: GameScene.cheight/2, card: ccards[1], hide: [GameScene.backCard])
				}else{
					GameScene.makeHideAndPaintResevation(sound: .card, x: GameScene.cwidth/2+GameScene.cwidth, y: frame.size.height-GameScene.cheight/2, card: ccards[1], hide: [GameScene.backCard])
				}
			}else if let SC = ccards[1] as? SpecialCard{//2枚目が他の特殊カード
				
				GameScene.resevation.append((sound: .none, paint: [], repaint: [], hide: [GameScene.backCard], pointLabels: Game().getpoints(), tPointLabels: [], BPLabels: (pBP: nil, cBP:nil)))
				
				if Game.mode == .netp2{
					SC.fanfare(cardPlace: .p1, index: 1)
					
				}else{
					SC.fanfare(cardPlace: .com, index: 1)
					
				}
			}
			if Game.mode == .netp2{
				for j in Game.pcards{//場にある分の効果を確認
					if let SC2 = j as? SpecialCard{
						SC2.drawEffect(drawPlayer: .p1)
					}
				}
				for j in Game.ccards{//場にある分の効果を確認
					if let SC2 = j as? SpecialCard{
						SC2.drawEffect(drawPlayer: .p1)
					}
				}
			}else{
				for j in Game.pcards{//場にある分の効果を確認
					if let SC2 = j as? SpecialCard{
						SC2.drawEffect(drawPlayer: .com)
					}
				}
				for j in Game.ccards{//場にある分の効果を確認
					if let SC2 = j as? SpecialCard{
						SC2.drawEffect(drawPlayer: .com)
					}
				}
			}

			Game.state = .end
			Game.pcards.removeAll()
			Game.ccards.removeAll()
			Game.deckCards.removeAll()
			if Game.mode == .netp1{
				nets.sendData()
			}
			
			showResult = .pBJ
			pwin()
		}else if j == 4{
			//2枚目を表に向ける
			var ccards = Game.ccards
			if ccards[1].cardNum < 53{
				if Game.mode == .netp2{
					GameScene.makeHideAndPaintResevation(sound: .card, x: GameScene.cwidth/2+GameScene.cwidth, y: GameScene.cheight/2, card: ccards[1], hide: [GameScene.backCard])
				}else{
					GameScene.makeHideAndPaintResevation(sound: .card, x: GameScene.cwidth/2+GameScene.cwidth, y: frame.size.height-GameScene.cheight/2, card: ccards[1], hide: [GameScene.backCard])
				}
			}else if let SC = ccards[1] as? SpecialCard{//2枚目が他の特殊カード
			//				let i = getSpecialEnteringSoundType(card: ccards[1].card)
			
			GameScene.resevation.append((sound: .none, paint: [], repaint: [], hide: [GameScene.backCard], pointLabels: Game().getpoints(), tPointLabels: [], BPLabels: (pBP: nil, cBP:nil)))
			
			if Game.mode == .netp2{
				SC.fanfare(cardPlace: .p1, index: 1)
				
			}else{
				SC.fanfare(cardPlace: .com, index: 1)
				
			}
		}
			if Game.mode == .netp2{
				for j in Game.pcards{//場にある分の効果を確認
					if let SC2 = j as? SpecialCard{
						SC2.drawEffect(drawPlayer: .p1)
					}
				}
				for j in Game.ccards{//場にある分の効果を確認
					if let SC2 = j as? SpecialCard{
						SC2.drawEffect(drawPlayer: .p1)
					}
				}
			}else{
				for j in Game.pcards{//場にある分の効果を確認
					if let SC2 = j as? SpecialCard{
						SC2.drawEffect(drawPlayer: .com)
					}
				}
				for j in Game.ccards{//場にある分の効果を確認
					if let SC2 = j as? SpecialCard{
						SC2.drawEffect(drawPlayer: .com)
					}
				}
			}

			Game.state = .end
			Game.pcards.removeAll()
			Game.ccards.removeAll()
			Game.deckCards.removeAll()
			if Game.mode == .netp1{
				nets.sendData()
			}
			
			showResult = .cBJ
			plose()
		}
		
		Game.firstDealed = true	//バハの効果を解禁
	}
	
	override func update(_ currentTime: CFTimeInterval) {
		
		self.pScrollNode.update(currentTime: currentTime)
		self.cScrollNode.update(currentTime: currentTime)
		
		let cheight = (view?.frame.height)!/3	//カードの縦の長さは画面サイズによって変わる
		
		//トランプ得点、特殊カードラベルの位置更新
		for i in Game.pcards{
			i.update()
		}
		for i in Game.ccards{
			i.update()
		}
		
		
		//音の処理
		if GameScene.audioFinish == true {
			if GameScene.resevation.count > 0{
				resetButton.isEnabled = false
				titleButton.isEnabled = false
				hitButton.isEnabled = false
				standButton.isEnabled = false
				
				//カードを隠す処理（バハのため、先に隠してから表示）
				for i in GameScene.resevation[0].hide{
					
					i.image.position = CGPoint(x:0,y:10000)    //枠外に
					i.update()	//手札から外れると自動更新されなくなるので
				}
				
				//カードの表示、移動
				for i in GameScene.resevation[0].paint{
					let paintCard = i.card!
					
					if i.y! > (view?.frame.height)!/2{
						//カード
						self.cScrollNode.contentNode.addChild(paintCard.image)
						//得点ラベル
						if let SC = paintCard as? SpecialCard{
							self.cScrollNode.contentNode.addChild(SC.hpLabel)
							self.cScrollNode.contentNode.addChild(SC.attackLabel)
						}else if let trump = paintCard as? Trump{
							self.cScrollNode.contentNode.addChild(trump.pointLabel)
						}
					}else{
						//カード
						self.pScrollNode.contentNode.addChild(paintCard.image)
						//得点ラベル
						if let SC = paintCard as? SpecialCard{
							self.pScrollNode.contentNode.addChild(SC.hpLabel)
							self.pScrollNode.contentNode.addChild(SC.attackLabel)
						}else if let trump = paintCard as? Trump{
							self.pScrollNode.contentNode.addChild(trump.pointLabel)
						}
					}
					
					paintCard.image.position = CGPoint(x:i.x!, y:cheight/2)
					paintCard.update()
				}
				
				//カードの移動
				for i in GameScene.resevation[0].repaint{
					i.card.image.position = CGPoint(x:i.x, y:cheight/2)
					//トランプ得点、特殊カードラベルの位置更新(移動後。バハ→ダリスで消えることがあるので)
					i.card.update()
				}
				
				
				
				//音を鳴らす
				switch(GameScene.resevation[0].sound){
				case .card : playcard.currentTime=0
				playcard.play()
				GameScene.audioFinish=false
				case .cardAndSummon : summon.currentTime=0
				summon.play()
				GameScene.audioFinish=false
				case .satanIn : satanIn.currentTime=0
				satanIn.play()
				GameScene.audioFinish=false
				case .olivieIn : olivieIn.currentTime=0
				olivieIn.play()
				GameScene.audioFinish=false
				case .bahamutIn : bahamutIn.currentTime=0
				bahamutIn.play()
				GameScene.audioFinish=false
				case .zeusIn : zeusIn.currentTime=0
				zeusIn.play()
				GameScene.audioFinish=false
				case .aliceIn : aliceIn.currentTime=0
				aliceIn.play()
				GameScene.audioFinish=false
				case .luciferIn : luciferIn.currentTime=0
				luciferIn.play()
				GameScene.audioFinish=false
				case .bbIn : bbIn.currentTime=0
				bbIn.play()
				GameScene.audioFinish=false
				case .daliceIn : daliceIn.currentTime=0
				daliceIn.play()
				GameScene.audioFinish=false
				case .daliceLast : daliceLast.currentTime=0
				daliceLast.play()
				GameScene.audioFinish=false
				case .luciferEffect : luciferEffect.currentTime=0
				luciferEffect.play()
				GameScene.audioFinish=false
				case .br: breakcard.currentTime=0
				breakcard.play()
				GameScene.audioFinish=false
				case .BP3 : BP3Sound.currentTime=0
				BP3Sound.play()
				GameScene.audioFinish=false
				case .cure : cureSound.currentTime=0
				cureSound.play()
				GameScene.audioFinish=false
				case .debuffField : debuffSound.currentTime=0
				debuffSound.play()
				GameScene.audioFinish=false
				case .extinction: extinction.currentTime=0
				extinction.play()
				GameScene.audioFinish=false
					
				default : print("該当の音が作られていません:\(GameScene.resevation[0].sound)")
				//audioPlayerDidFinishPlayingが呼び出されないのでここで解除
				resetButton.isEnabled = true
				titleButton.isEnabled = true
				hitButton.isEnabled = true
				standButton.isEnabled = true
					
				}
				
				//ppLabel,cpLabelの更新（String?,String?）
				if let pp = GameScene.resevation[0].pointLabels.pp{
					ppLabel.text = pp
				}
				if let cp = GameScene.resevation[0].pointLabels.cp{
					cpLabel.text = cp
				}
				
				
				//tPointLabelの更新[(どれ,String,UIColor)]（アリスを３枚め以降引いたときのみ）
				for i in GameScene.resevation[0].tPointLabels{//（今は重複するので不要だが,Aのタイミングも合わせるときに使う？）
					if let trump = i.card as? Trump{//トランプ
						trump.pointLabel.text = i.value
						trump.pointLabel.fontColor = i.color	//(注)fontColor != color

					}
				}
				
				//pBP,cBPLabelの更新(String,String)
				if let pBP=GameScene.resevation[0].BPLabels.pBP{
					pBPLabel.text="×"+pBP
				}
				if let cBP=GameScene.resevation[0].BPLabels.cBP{
					cBPLabel.text="×"+cBP
				}
				
				GameScene.resevation.removeFirst()
				
			}else{
				//最終結果の表示
				if showResult == .pWin || showResult == .pBJ{
					if Game.mode == .pvp{
						centerLabel.text = "P1 Win!"
					}else if Game.mode == .netp2{
						centerLabel.text = "You Lose..."
					}else {
						centerLabel.text = "You Win!"
					}
					
					if showResult == .pBJ {
						pbjLabel.isHidden = false
						ppLabel.isHidden = false
						cpLabel.isHidden = false
					}
					
					showResult = .wait
				}else if showResult == .pLose || showResult == .cBJ{
					if Game.mode == .pvp{
						centerLabel.text = "P2 Win!"
					}else if Game.mode == .netp2{
						centerLabel.text = "You Win!"
					}else {
						centerLabel.text = "You Lose..."
					}
					
					if showResult == .cBJ {
						cbjLabel.isHidden = false
						ppLabel.isHidden = false
						cpLabel.isHidden = false
					}
					
					showResult = .wait
				}else if showResult == .draw || showResult == .bothBJ{
					centerLabel.text = "Draw"
					
					if showResult == .bothBJ {
						pbjLabel.isHidden = false
						cbjLabel.isHidden = false
						ppLabel.isHidden = false
						cpLabel.isHidden = false
					}
					
					showResult = .wait
				}
			}
		}
		
		
		
		//通信の処理
		if Game.mode == .netp1 || Game.mode == .netp2{
			if last == nil{
				last = currentTime
			}
			
			// 3秒おきに行う処理をかく。
			if last + 1 <= currentTime {
				queue.async {

					//サーバーから山札、手札を獲得（1つずつ）
					if Game.state != .end{
						self.nets.receiveData()
					}
					
					if Game.state == .br{	  //breakを受信したら強制終了
						self.hitButton.isHidden=true
						self.standButton.isHidden=true
						self.resetButton.isHidden=true
						self.titleButton.isHidden=true
						
						let gameScene = LaunchScene(size: self.view!.bounds.size) // create your new scene
						let transition = SKTransition.fade(withDuration: 1.0) // create type of transition (you can check in documentation for more transtions)
						gameScene.scaleMode = SKSceneScaleMode.fill
						self.view!.presentScene(gameScene, transition: transition) //LaunchSceneに移動
					}
					
					self.hitButton.isEnabled=true
					self.standButton.isEnabled=true
					self.resetButton.isEnabled=true
					self.titleButton.isEnabled=true
					
					if Game.mode == .netp1{
						let ccardsc=Game.ccards.count
						
						if Game.state == .judge{
							
							//最終判定(ループ外)
							let j=Game().judge(1)
							if j==0{
								Game.state = .end
								Game.pcards.removeAll()
								Game.deckCards.removeAll()
								Game.ccards.removeAll()
								
								self.nets.sendData()	//サーバーをendに更新し、以後の受信を停止
								self.draw()
							}else if j==1{
								Game.state = .end
								Game.pcards.removeAll()
								Game.deckCards.removeAll()
								Game.ccards.removeAll()
								
								self.nets.sendData()	//サーバーをendに更新し、以後の受信を停止
								self.pwin()
							}else if j==2{
								Game.state = .end
								Game.pcards.removeAll()
								Game.deckCards.removeAll()
								Game.ccards.removeAll()
								
								self.nets.sendData()	//サーバーをendに更新し、以後の受信を停止
								self.plose()
							}
						}
						
						
						
						if ccardsc != self.fccardsc && (Game.state == .p2turn||Game.state == .judge){//更新を受信したとき
							self.playcard.currentTime = 0
							self.playcard.play()
							
							let ccards:[Card] = Game.ccards
							
							//2p（敵）の引いた手札を表示
							GameScene.makePaintResevation(sound: .card, x: GameScene.cwidth/2+GameScene.cwidth*CGFloat(ccardsc-1), y: self.frame.size.height-GameScene.cheight/2, card: ccards[ccardsc-1])
							
							//敵の得点表示
							self.cpLabel.isHidden = false
							
							self.fccardsc = ccardsc
							//引いた直後にバストの判定(ループ内)
							let j = Game().judge(1)
							if j == 3{
								
								//ルシフェル探し(todo)
//								for i in Game.ccards{
//
//								}
								
								Game.state = .end
								Game.pcards.removeAll()
								Game.deckCards.removeAll()
								Game.ccards.removeAll()
								
								self.nets.sendData()	//サーバーをendに更新し、以後の受信を停止
								
								self.pwin()
							}
							
						}
					}else if Game.mode == .netp2{
						let pcardsc = Game.pcards.count    //毎回更新
						if (pcardsc > self.fpcardsc) && (Game.state == .p1turn||Game.state == .p2turn){//更新されたら(startはまだ配った手札が来てない状態、end,breakは手札がからの状態、judgeでもエラー発生)
							
							let pcards:[Card] = Game.pcards
							
							//敵が引いたカードを表示
							GameScene.makePaintResevation(sound: .card, x: GameScene.cwidth/2+GameScene.cwidth*CGFloat(pcardsc-1), y: self.frame.size.height-GameScene.cheight/2, card: pcards[pcardsc-1])
							
							
							//敵の得点表示????????
							self.ppLabel.isHidden=false
							
							self.fpcardsc = pcardsc
							
							//敵のbustの判定
							let j = Game().judge(1)
							if j == 4{
								self.isPaused = true  //updateによる受信防止
								self.plose()
								
								//2枚目を表に向ける
								var ccards = Game.ccards
								GameScene.makeHideAndPaintResevation(sound: .card, x: GameScene.cwidth/2+GameScene.cwidth, y: cheight/2, card: ccards[1], hide: [GameScene.backCard])
								
								self.isPaused = false
								
								//配列から消す前に各トランプの得点を表示:TODO??

								
								Game.state = .end
								Game.pcards.removeAll()
								Game.deckCards.removeAll()
								Game.ccards.removeAll()
								self.nets.sendData()	//サーバーをendに更新し、以後の受信を停止
							}
						}
						if Game.state == .p2turn && !self.didchange{//こちらにターンが回ってきたとき
							
							self.hitButton.isHidden = false
							self.standButton.isHidden = false
							
							//2枚目を表に向ける
							var ccards = Game.ccards
							GameScene.makeHideAndPaintResevation(sound: .card, x: GameScene.cwidth/2+GameScene.cwidth, y: cheight/2, card: ccards[1], hide: [GameScene.backCard])
							
							//得点を表示する
							self.cpLabel.isHidden = false
							self.centerLabel.text = "あなたのターン"
							
							self.didchange = true
						}
					}
					self.last = currentTime
				}
			}//if last + 1 <= currentTime
		}
	}
	
	func pwin(){
		
		hitButton.isHidden = true
		standButton.isHidden = true
		
		if showResult == .wait {
			showResult = .pWin
		}
		
		endofthegame()
	}
	
	func plose(){
		hitButton.isHidden = true
		standButton.isHidden = true
		
		if showResult == .wait {
			showResult = .pLose
		}
		
		endofthegame()
	}
	
	func draw(){  //引き分け！「描く」とは関係ない！
		
		hitButton.isHidden = true
		standButton.isHidden = true
		
		if showResult == .wait {
			showResult = .draw
		}
		
		endofthegame()
	}
	
	func endofthegame(){
		// リセット、タイトルボタンを表示.
		resetButton.isHidden = false
		titleButton.isHidden = false
	}
	
	func getSpecialEnteringSoundType(card:Int) -> SoundType{
		
		guard card > 52 else {
			print("特殊カードではありません")
			return .none
		}
		
		switch card {
		case 53:
			return .satanIn
		case 54,58,59:
			return .olivieIn
		case 55,60,61:
			return .bahamutIn
		case 56:
			return .zeusIn
		case 57,62,63:
			return .aliceIn
		case 64,65,66:
			return .luciferIn
		default:
			print("未定義の特殊カードです")
			return .none
		}
	}
	
	func checkA(){
		//Aの得点の確認
		let (ppoint,cpoint,_,_) = Game().calculatepoints()
		for (index,value) in Game.pcards.enumerated(){
			if let trump = value as? Trump{//トランプ限定
				if trump.initialPoint == 1 && ppoint.inA<22{
					Game.pcards[index].point+=10
					
					GameScene.resevation.append((sound: .none, paint: [], repaint: [], hide: [], pointLabels: Game().getpoints(), tPointLabels: [(card: Game.pcards[index], value: String(Game.pcards[index].point), color:.orange)], BPLabels: (pBP: nil, cBP: nil)))

					break	  //二枚目以降は更新しない
				}
				if trump.initialPoint == 1 && value.point>9{
					if ppoint.noA>21{
						Game.pcards[index].point -= 10
						GameScene.resevation.append((sound: .none, paint: [], repaint: [], hide: [], pointLabels: Game().getpoints(), tPointLabels: [(card: Game.pcards[index], value: String(Game.pcards[index].point), color:.white)], BPLabels: (pBP: nil, cBP: nil)))

						break //後に直すべきAはないはず
					}
				}
			}
		}
		for (index,value) in Game.ccards.enumerated(){
			if let trump = value as? Trump{//トランプ限定
				if trump.initialPoint == 1 && cpoint.inA<22{
					Game.ccards[index].point += 10
					GameScene.resevation.append((sound: .none, paint: [], repaint: [], hide: [], pointLabels: Game().getpoints(), tPointLabels: [(card: Game.ccards[index], value: String(Game.ccards[index].point), color:.orange)], BPLabels: (pBP: nil, cBP: nil)))
					break	  //二枚目以降は更新しない
				}
				if trump.initialPoint == 1 && value.point > 9 && cpoint.noA > 21{
					Game.ccards[index].point -= 10
					GameScene.resevation.append((sound: .none, paint: [], repaint: [], hide: [], pointLabels: Game().getpoints(), tPointLabels: [(card: Game.ccards[index], value: String(Game.ccards[index].point), color:.white)], BPLabels: (pBP: nil, cBP: nil)))
					break //後に直すべきAはないはず
				}
			}
		}
	}
	
	
	//再生終了時の呼び出しメソッド
	func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {//playしたクラスと同じクラスに入れる必要あり？
		GameScene.audioFinish = true
		
		if GameScene.resevation.count == 0{
			resetButton.isEnabled = true
			titleButton.isEnabled = true
			hitButton.isEnabled = true
			standButton.isEnabled = true
		}
	}
	// デコード中にエラーが起きた時に呼ばれるメソッド
	func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?){
		print(error as Any)
	}
}


