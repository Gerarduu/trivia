//
//  ViewController.swift
//  trivia
//
//  Created by Gerard Riera Puig on 20/09/2019.
//  Copyright © 2019 Gerard Riera Puig. All rights reserved.
//

import UIKit
import CoreData

struct Player {
    
   var name: String = ""
   var score: Int = 0
}

class ViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var player1NameText: UILabel!
    @IBOutlet weak var player1ScoreText: UILabel!
    @IBOutlet weak var player2NameText: UILabel!
    @IBOutlet weak var player2ScoreText: UILabel!
    @IBOutlet weak var actualPlayerText: UILabel!
    @IBOutlet weak var questionText: UILabel!
    @IBOutlet var answerBtns: [UIButton]!

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var player1 = Player(name: "Gerard", score: 0)
    var player2 = Player(name: "Iván", score: 0)
    
    var questions: Array<Dictionary<String, Any>>? = nil
    
    var managedObjectContext: NSManagedObjectContext? = nil
    
    var correctAnswer: String = ""
    
    var turn = 0;
    
    var previousNumbers: Array<Int> = []
    
    func randomNumber() -> Int {
        
        var randomInt = Int.random(in: 0...3)
        
        while previousNumbers.contains(randomInt) {
            
            randomInt = Int.random(in: 0...3)
        }
        
        previousNumbers.append(randomInt)
        
        print("random int: \(randomInt), previous numbers: \(previousNumbers)")
        
        return randomInt
    }
    
    func setCoreData() {
        
        managedObjectContext = appDelegate.persistentContainer.viewContext
        
        let context = self.fetchedResultsController.managedObjectContext
        
        let newGame = Game(context: context)
        
        newGame.player1Stats = player1.name + " " + String(player1.score)
        newGame.player2Stats = player2.name + " " + String(player2.score)
        
        newGame.date = Date()
        
        do {
            
            try context.save()
        } catch {
        
            let nserror = error as NSError
            
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    func endGame () {
        
        if player1.score > player2.score {
            
            showAlert(inTitle: player1.name+" wins!" , inMessage: player1.name+" obliterates his rival with a score of \(player1.score) points. Congratulations! 🥳", inFunction: {
                self.getData()
            })
            
        } else if player2.score > player1.score {
            
            showAlert(inTitle: player2.name+" wins!" , inMessage: "With a score of \(player2.score) points. Congratulations! 🥳", inFunction: {
                self.getData()
            })
        } else {
            
            showAlert(inTitle: "It's a draw!" , inMessage: "Both players scored \(player1.score) points! 😐" , inFunction: {
                self.getData()
            })
        }
        
        turn = 0
        player1.score = 0
        player2.score = 0
        
        setCoreData()
    }
    
    func setUp () {
        
        player1ScoreText.text = String(self.player1.score)
        player2ScoreText.text = String(self.player2.score)
        
        print("turn: \(turn+1)")
        
        if self.turn > 19 {
            
            endGame()
            
        } else {
            
            self.questionText.text = ""
            
            for button in answerBtns {
                
                button.setTitle("", for: .normal)
            }
            
            if self.turn % 2 == 0 {
                
                actualPlayerText.text = self.player1.name + "'s turn"
            } else {
                
                actualPlayerText.text = self.player2.name + "'s turn"
            }
            
            self.questionText.text = self.questions![self.turn]["question"] as? String
            
            answerBtns![randomNumber()].setTitle(self.questions![self.turn]["correct_answer"] as? String, for: .normal)
            self.correctAnswer = (self.questions![self.turn]["correct_answer"] as? String)!
            
            let wrongAnswers = self.questions![self.turn]["incorrect_answers"] as? Array<String>
            
            for answer in wrongAnswers! {
                
                answerBtns![randomNumber()].setTitle(answer, for: .normal)
            }
            
            for button in answerBtns {
                
                if button.titleLabel!.text == nil {
                    
                    button.isHidden = true
                } else {
                    
                    button.isHidden = false
                }
                
                button.addTarget(self, action: #selector(handleTap(inButton: )), for: UIControl.Event.touchUpInside)
            }
            
            previousNumbers.removeAll()
            turn+=1
        }
    }
    
    @objc func handleTap (inButton: UIButton) {
        
        if inButton.titleLabel!.text! == self.correctAnswer {
            
            showAlert(inTitle: "Congratulations!", inMessage: "You got the correct answer!", inFunction: {
                
                for button in self.answerBtns {
                    
                    button.titleLabel!.text = nil
                }
                
                if self.turn % 2 != 0 {
                    
                    self.player1.score+=1
                } else {
                    
                    self.player2.score+=1
                }
                
                self.setUp()
            })
            
        } else {
            
            showAlert(inTitle: "Uh Oh!", inMessage: "You got a wrong answer...", inFunction: {
                
                for button in self.answerBtns {
                    
                    button.titleLabel!.text = nil
                }

                self.setUp()
            })
        }
    }
    
    func getData() {
        
        NetworkManager.downloadData { jsonData in
            guard let jData = jsonData else { return }
        
            do {
                
                if let json = try JSONSerialization.jsonObject(with: jData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any] {
                    
                    if let questionsTemp = json["results"] as? Array<Dictionary<String, Any>> {
                        
                        self.questions = questionsTemp
                        self.setUp()
                    }
                }
            
            } catch let jError {
                
                print("Error Parsing JSON: \(jError)")
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        player1NameText.text = self.player1.name
        player2NameText.text = self.player2.name
        self.navigationController?.navigationItem.backBarButtonItem?.isEnabled = false;
        
        setUpScreen()
        getData()
    }
    
    override open var shouldAutorotate: Bool {
        return false
    }
    
    func setUpScreen() {
        
        questionText.font = UIFont.boldSystemFont(ofSize: 18.0)
        actualPlayerText.font = UIFont.boldSystemFont(ofSize: 18.0)
        player1NameText.font = UIFont.boldSystemFont(ofSize: 15.0)
        player2NameText.font = UIFont.boldSystemFont(ofSize: 15.0)
        player1ScoreText.font = UIFont.boldSystemFont(ofSize: 15.0)
        player2ScoreText.font = UIFont.boldSystemFont(ofSize: 15.0)
        
        for button in answerBtns {
            
            button.layer.cornerRadius = 10
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
        }
    }
    
    func showAlert(inTitle: String, inMessage: String, inFunction: @escaping () -> ()) {
        
        let alert = UIAlertController(title: inTitle, message: inMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                
                inFunction()
                print("default")
            case .cancel:
                
                print("cancel")
            case .destructive:
                
                print("destructive")
            @unknown default:
                
                print("fatal error")
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    var fetchedResultsController: NSFetchedResultsController<Game> {
        
        if _fetchedResultsController != nil {
            
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Game> = Game.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        
        aFetchedResultsController.delegate = self
        
        _fetchedResultsController = aFetchedResultsController
        
        do {
            
            try _fetchedResultsController!.performFetch()
        } catch {
            
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    
    var _fetchedResultsController: NSFetchedResultsController<Game>? = nil
}
