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
    let tweetCount = 100
    var tweetTexts = [TwitterSentimentClassifierInput]()
    var predictionResults = [String]()
    
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
        
        swifter.searchTweet(using: keyword, lang: "en", count: tweetCount, tweetMode: .extended) { (results, metadata) in
//            print(results)
            
            for tweet in results.array! {
                self.tweetTexts.append(TwitterSentimentClassifierInput(text: tweet["full_text"].string ?? ""))
            }
//            print(self.tweetTexts)
            self.classifyTweets()

        } failure: { (error) in
            print("Error: \(error)")
        }
    }
    
    func classifyTweets() {
        
        var sentimentCounter = 0
        
        do {
            let sentimentClassifer = try TwitterSentimentClassifier(configuration: MLModelConfiguration())
            let results = try sentimentClassifer.predictions(inputs: tweetTexts)
            
            for result in results {
                switch result.label {
                case "positive":
                    sentimentCounter += 1
                case "negative":
                    sentimentCounter -= 1
                default:
                    ()
                }
            }
            print(sentimentCounter)
            findMostCommonSentiment(sentimentCounter)
            
        } catch {
            print(error)
        }
    }
    
    func findMostCommonSentiment(_ sentimentCounter: Int) {
        
        switch sentimentCounter {
        case 20...tweetCount:
            emojiLabel.text = "🤩"
        case 10..<20:
            emojiLabel.text = "😃"
        case -10..<10:
            emojiLabel.text = "😐"
        case -20 ..< -10:
            emojiLabel.text = "☹️"
        default:
            emojiLabel.text = "😤"
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

