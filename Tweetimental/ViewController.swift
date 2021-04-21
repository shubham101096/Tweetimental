//
//  ViewController.swift
//  Tweetimental
//
//  Created by Shubham Mishra on 17/04/21.
//

import UIKit
import SwifteriOS
import CoreML

class ViewController: UIViewController {

    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var textView: UITextField!
    @IBOutlet weak var predictButton: UIButton!

    var swifter: Swifter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.layer.cornerRadius = textView.layer.frame.height/4
        predictButton.layer.cornerRadius = predictButton.layer.frame.height/4

         if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
            let xml = FileManager.default.contents(atPath: path),
        let secrets = try? PropertyListDecoder().decode(Secrets.self, from: xml) {
            swifter = Swifter(consumerKey: secrets.consumerKey, consumerSecret: secrets.consumerSecret)
         } else {
            fatalError("Could not load secrets")
         }
//        swifter?.searchTweet(using: "@Apple", lang: "en", count: 100, tweetMode: .extended) { (results, metadata) in
//            print(results)
//        } failure: { (error) in
//            print("Error: \(error)")
//        }
        
        do {
            let sentimentClassifer = try TwitterSentimentClassifier(configuration: MLModelConfiguration())
            let result = try sentimentClassifer.prediction(text: "@Apple is best")
            print(result.label)
        } catch {
            print(error)
        }
        
    

    }

    @IBAction func predictTapped(_ sender: UIButton) {
    }
    
}

