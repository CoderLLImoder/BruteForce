import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var button: UIButton!
    
    var isBlack: Bool = false {
        didSet {
            if isBlack {
                self.view.backgroundColor = .black
            } else {
                self.view.backgroundColor = .white
            }
        }
    }
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var stopButton: UIButton!
    
    @IBAction func onBut(_ sender: Any) {
        isBlack.toggle()
    }
    
    private var queue = DispatchQueue(label: "BrutForce", attributes: [.concurrent])
    private var workItem: DispatchWorkItem?
    private var brutForceIsActive = false;
    
    @IBAction func stop(_ sender: Any) {
        if (self.brutForceIsActive) {
            workItem?.cancel()
        }
    }
    
    @IBAction func start(_ sender: Any) {
        if (self.brutForceIsActive) {
            return
        }
        
        let password = self.text.text ?? "1111"
            
        DispatchQueue.main.async {
            self.indicator.startAnimating()
        }
        
        workItem = DispatchWorkItem {
            self.brutForceIsActive = true
            self.bruteForce(passwordToUnlock: password)
            self.brutForceIsActive = false
            DispatchQueue.main.sync {
                self.indicator.stopAnimating()
                self.text.isSecureTextEntry = false
            }
        }
        
        queue.async(execute: workItem!)
    }
    
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var text: UITextField!
    
    @IBAction func inputText(_ sender: Any) {
    }
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // Do any additional setup after loading the view.
    }
    
    func showBrutforceWork(_ password: String) {
        
        DispatchQueue.main.async {
            self.label.text = password
        }
    }
    
    func bruteForce(passwordToUnlock: String) {
        let ALLOWED_CHARACTERS:   [String] = String().printable.map { String($0) }

        var password: String = ""

        // Will strangely ends at 0000 instead of ~~~
        while password != passwordToUnlock { // Increase MAXIMUM_PASSWORD_SIZE value for more
            if workItem?.isCancelled == true {
                showBrutforceWork("Password wasn't hacked =(")
                return
            }
            password = generateBruteForce(password, fromArray: ALLOWED_CHARACTERS)
//             Your stuff here
            print(password)
            showBrutforceWork(password)
            // Your stuff here
        }
        
        print(password)
    }
}



extension String {
    var digits:      String { return "0123456789" }
    var lowercase:   String { return "abcdefghijklmnopqrstuvwxyz" }
    var uppercase:   String { return "ABCDEFGHIJKLMNOPQRSTUVWXYZ" }
    var punctuation: String { return "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~" }
    var letters:     String { return lowercase + uppercase }
    var printable:   String { return digits + letters + punctuation }



    mutating func replace(at index: Int, with character: Character) {
        var stringArray = Array(self)
        stringArray[index] = character
        self = String(stringArray)
    }
}

func indexOf(character: Character, _ array: [String]) -> Int {
    return array.firstIndex(of: String(character))!
}

func characterAt(index: Int, _ array: [String]) -> Character {
    return index < array.count ? Character(array[index])
                               : Character("")
}

func generateBruteForce(_ string: String, fromArray array: [String]) -> String {
    var str: String = string

    if str.count <= 0 {
        str.append(characterAt(index: 0, array))
    }
    else {
        str.replace(at: str.count - 1,
                    with: characterAt(index: (indexOf(character: str.last!, array) + 1) % array.count, array))

        if indexOf(character: str.last!, array) == 0 {
            str = String(generateBruteForce(String(str.dropLast()), fromArray: array)) + String(str.last!)
        }
    }

    return str
}

