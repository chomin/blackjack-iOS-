//
//  Sounds.swift
//  newblackjack
//
//  Created by Kohei Nakai on 2017/08/24.
//  Copyright © 2017年 NakaiKohei. All rights reserved.
//


import SpriteKit
import AVFoundation

class Sounds: SKScene, AVAudioPlayerDelegate{//通知を受け取るためAVAudioPlayerDelegateを、更にエラー回避のためSKScene(これは多重継承ではないらしい)
	//効果音を生成
	var playcard : AVAudioPlayer! = nil  // 再生するサウンドのインスタンス
	var summon : AVAudioPlayer! = nil
	var satanIn : AVAudioPlayer! = nil
	var olivieIn : AVAudioPlayer! = nil
	var bahamutIn : AVAudioPlayer! = nil
	var zeusIn : AVAudioPlayer! = nil
	var aliceIn : AVAudioPlayer! = nil
	var luciferIn : AVAudioPlayer! = nil
	var luciferEffect : AVAudioPlayer! = nil
	var breakcard : AVAudioPlayer! = nil
	var BP3Sound : AVAudioPlayer! = nil
	var cureSound : AVAudioPlayer! = nil
	var debuffSound : AVAudioPlayer! = nil
	
	func setAllSounds() {
		playcard=Sounds().setSound(fileName: "カード音")	//トランプ
		summon=Sounds().setSound(fileName: "カード+召喚音")	//特殊カード？
		satanIn=Sounds().setSound(fileName: "絶望よ、来たれ")
		olivieIn=Sounds().setSound(fileName: "新たなる世界を求めて")
		bahamutIn=Sounds().setSound(fileName: "（バハ登場）")
		zeusIn=Sounds().setSound(fileName: "我こそ唯一にして無二たる神なり")
		aliceIn=Sounds().setSound(fileName: "不思議な世界、素敵な世界！")
		luciferIn = Sounds().setSound(fileName: "世界の調和こそが、私の望みだ")
		luciferEffect = Sounds().setSound(fileName: "神の慈悲だ")
		breakcard=Sounds().setSound(fileName: "破壊音")
		BP3Sound = Sounds().setSound(fileName: "BP3音")
		cureSound = Sounds().setSound(fileName: "回復音")
		debuffSound = Sounds().setSound(fileName: "場のデバフ")
	}
	
	func setSound(fileName:String) -> AVAudioPlayer!{//効果音を設定する関数
		var sound:AVAudioPlayer!
		
		// サウンドファイルのパスを生成
		let Path = Bundle.main.path(forResource: fileName, ofType: "mp3")!    //m4aは不可
		let soundURL:URL = URL(fileURLWithPath: Path)
		// AVAudioPlayerのインスタンスを作成
		do {
			sound = try AVAudioPlayer(contentsOf: soundURL, fileTypeHint:nil)
		} catch {
			print("AVAudioPlayerインスタンス作成失敗")
		}
		// バッファに保持していつでも再生できるようにする
		sound.prepareToPlay()
		
		return sound
	}
}
