//
//  ViewController.swift
//  SwiftChart
//
//  Created by Nimol on 1/8/24.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
    }
    @IBAction func lineView(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "LineChartViewController")
        navigationController?.pushViewController(vc! , animated: true )
    }
    
    @IBAction func barView(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "BarChartViewController")
        navigationController?.pushViewController(vc!, animated: true )
    }
    

}
