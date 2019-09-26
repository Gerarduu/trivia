import UIKit

class LoginViewController: UIViewController {
    
    var turn:Int  = 0;
    var player1Name:String = ""
    var player2Name:String = ""
    
    @IBOutlet weak var playerNameDesc: UILabel!
    @IBOutlet weak var playerNameText: UITextField!
    @IBOutlet weak var nextBtn: UIButton!
    @IBAction func scoresBtnPressed(_ sender: Any) {
        
        playerNameText.resignFirstResponder()
        performSegue(withIdentifier: "scoresViewController", sender: nil)
    }
    
    @IBAction func nextBtnPressed(_ sender: Any) {
        
        if playerNameText.text == "" {
            
            let alert = UIAlertController(title: "A name must be written", message: "Please, provide a name for the player", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            
            if turn == 0 {
                
                player1Name = playerNameText.text!
                playerNameDesc.text = "Player 2 Name"
                playerNameText.text = ""
                turn+=1
                
            } else {
                
                player2Name = playerNameText.text!
                playerNameDesc.text = "Player 1 Name"
                playerNameText.text = ""
                turn=0
                
                playerNameText.resignFirstResponder()
                performSegue(withIdentifier: "triviaViewController", sender: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "triviaViewController" {
            
            if let triviaViewController = segue.destination as? ViewController {
                
                triviaViewController.player1.name = player1Name
                triviaViewController.player2.name = player2Name
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextBtn.layer.cornerRadius = 5
        
        //Hide keyboard when tapping outside
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    
    @objc func dismissKeyboard() {
    
        view.endEditing(true)
    }
}
