//
//  SpeechViewController.swift
//  Anliven
//
//  Created by Chirag Desai on 7/29/17.
//  Copyright © 2017 Chirag Desai. All rights reserved.
//

import UIKit
import AVFoundation

class SpeechViewController: UIViewController,AVSpeechSynthesizerDelegate{
    
    let speechSynthesizer = AVSpeechSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation
     
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func startStory() {
        let speechUtterance = AVSpeechUtterance(string: "Hello")
        speechSynthesizer.speak(speechUtterance)
        
    }
    

}
