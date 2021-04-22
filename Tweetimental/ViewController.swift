//
//  ViewController.swift
//  Tweetimental
//
//  Created by Shubham Mishra on 17/04/21.
//

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var predictButton: UIButton!

    var swifter: Swifter!
    var tweetTexts = [String]()
    var predictionResults = [String]()
    var sentimentCounter = ["positive":0, "neutral":0, "negative":0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.layer.cornerRadius = textField.layer.frame.height/4
        predictButton.layer.cornerRadius = predictButton.layer.frame.height/4
        textField.delegate = self
        predictButton.isEnabled = false
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

         if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
            let xml = FileManager.default.contents(atPath: path),
        let secrets = try? PropertyListDecoder().decode(Secrets.self, from: xml) {
            swifter = Swifter(consumerKey: secrets.consumerKey, consumerSecret: secrets.consumerSecret)
         } else {
            fatalError("Could not load secrets")
         }
    }
    
    func makePrediction(keyword: String) {
        
        tweetTexts.removeAll()
        predictionResults.removeAll()
        
        swifter.searchTweet(using: keyword, lang: "en", count: 100, tweetMode: .extended) { (results, metadata) in
//            print(results)
            
            for tweet in results.array! {
                self.tweetTexts.append(tweet["full_text"].string ?? "")
            }
//            print(self.tweetTexts)
            self.classifyTweets()

        } failure: { (error) in
            print("Error: \(error)")
        }
    }
    
    func classifyTweets() {
        sentimentCounter["positive"]! = 0
        sentimentCounter["neutral"]! = 0
        sentimentCounter["negative"]! = 0
        
        do {
            let sentimentClassifer = try TwitterSentimentClassifier(configuration: MLModelConfiguration())
            for text in tweetTexts {
                let result = try sentimentClassifer.prediction(text: text)
                sentimentCounter[result.label]! += 1
            }
            print(sentimentCounter)
            findMostCommonSentiment()
            
        } catch {
            print(error)
        }
    }
    
    func findMostCommonSentiment() {
        let pos = sentimentCounter["positive"]!
        let neu = sentimentCounter["neutral"]!
        let neg = sentimentCounter["negative"]!
        
        if pos>neu && pos>neg {
            emojiLabel.text = "😁"
        } else if neg>pos && neg>neu {
            emojiLabel.text = "☹️"
        } else {
            emojiLabel.text = "😐"
        }
    }
    
    @IBAction func predictTapped(_ sender: UIButton) {
        makePrediction(keyword: textField.text!)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        predictButton.isEnabled = textField.text! == "" ? false : true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text! == "" {
            return false
        }
        makePrediction(keyword: textField.text!)
        return true
    }
}

