
import UIKit

class ProViewController: UIViewController {
    
    @IBOutlet weak var purchaseButton: UIButton!
    @IBOutlet weak var purchaseView: UIView!
    @IBOutlet weak var purchaseLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        purchaseButton.layer.cornerRadius = 15
    }
    
    @IBAction func dismissButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
}

extension ProViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "proCell", for: indexPath)
        return cell
    }
}
