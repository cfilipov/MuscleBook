/*
 Muscle Book
 Copyright (C) 2016  Cristian Filipov

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */


import UIKit
import Eureka
import Kingfisher
import SafariServices

class ExerciseInstructionsViewController : FormViewController {

    let exercise: Exercise

    lazy var imageView: AnimatedImageView = {
        let view = AnimatedImageView()
        view.frame = CGRect(x: 0, y: 15, width: 120, height: 120)
        view.contentMode = .ScaleAspectFit
        view.autoresizingMask = .FlexibleWidth
        return view
    }()

    lazy var imageViewContainer: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 130))
        view.autoresizingMask = .FlexibleWidth
        view.addSubview(self.imageView)
        return view
    }()

    init(exercise: Exercise) {
        self.exercise = exercise
        super.init(style: .Grouped)
        hidesBottomBarWhenPushed = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Instructions"

        tableView?.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0)

        form

        +++ Section() {
            $0.footer = HeaderFooterView<UIView>(HeaderFooterProvider.Callback({ () -> UIView in
                return self.imageViewContainer
            }))
        }

        <<< LabelRow() {
            $0.title = "Name"
            $0.value = exercise.name
        }

        +++ Section()

        if let instructions = exercise.instructions {
            for i in instructions {
                form.last! <<< TextAreaRow() {
                    $0.value = i
                    $0.textAreaHeight = .Dynamic(initialTextViewHeight: 20)
                    $0.disabled = true
                }
            }
        }
        
        form +++ Section() <<< PushViewControllerRow() {
            $0.title = "More Details"
            $0.controller = { SFSafariViewController(URL: NSURL(string: self.exercise.link)!) }
        }

        if let gif = exercise.gif, url = NSURL(string: gif) {
            imageView.kf_setImageWithURL(url)
        }
    }

    private func load(URL: NSURL, callback: NSData -> Void) {
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        let request = NSMutableURLRequest(URL: URL)
        request.HTTPMethod = "GET"
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let error = error {
                Alert(message: error.localizedDescription)
                return
            }
            guard let data = data else { return }
            callback(data)
        }
        task.resume()
    }
    
}

