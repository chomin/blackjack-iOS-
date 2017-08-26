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
	var breakcard : AVAudioPlayer! = nil
	
	
	func setAllSounds() {
		playcard=Sounds().setSound(fileName: "カード音")
		summon=Sounds().setSound(fileName: "カード召喚音")
		satanIn=Sounds().setSound(fileName: "絶望よ、来たれ")
		olivieIn=Sounds().setSound(fileName: "新たなる世界を求めて")
		bahamutIn=Sounds().setSound(fileName: "（バハ登場）")
		zeusIn=Sounds().setSound(fileName: "我こそ唯一にして無二たる神なり")
		aliceIn=Sounds().setSound(fileName: "不思議な世界、素敵な世界！")
		breakcard=Sounds().setSound(fileName: "破壊音")
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
