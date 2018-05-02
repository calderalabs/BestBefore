//
//  NewItemFormViewController.swift
//  BestBefore
//
//  Created by Eugenio Depalo on 02/05/2018.
//  Copyright © 2018 Caldera Labs. All rights reserved.
//

import UIKit
import Eureka

class NewItemFormViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section("Details")
            <<< TextRow(){ row in
                row.title = "Name"
                row.placeholder = "Enter product name here"
            }
            <<< DateRow(){ row in
                row.title = "Expiration Date"
                row.value = Date(timeIntervalSinceReferenceDate: 0)
            }
            <<< ImageRow(){ row in
                row.title = "Photo"
                row.sourceTypes = [.Camera]
            }
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

}
