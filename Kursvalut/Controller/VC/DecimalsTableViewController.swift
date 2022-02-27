
import UIKit

class DecimalsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)

        let section = indexPath.section
        let numberOfRows = tableView.numberOfRows(inSection: section)

        for row in 0..<numberOfRows {
            guard let cell = tableView.cellForRow(at: IndexPath(row: row, section: section)) else { return }
            cell.accessoryType = row == indexPath.row ? .checkmark : .none
        }
    }
}
