// Copyright (c) 2017, arconsis IT-Solutions GmbH
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation
// and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
// ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
// The views and conclusions contained in the software and documentation are those
// of the authors and should not be interpreted as representing official policies,
// either expressed or implied, of the FreeBSD Project.

import UIKit

class ContainerViewController: UIViewController {

    lazy var startButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(start))
    }()
    
    lazy var resetButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(reset))
    }()
    
    let resetInfo = "... select the X to stop."
    let startInfo = "Select play button to start ..."
    
    @IBOutlet weak var squareView: SquareView!
    var fancyAnimator: FancyAnimator?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Dynamics Demo"
        navigationItem.prompt = startInfo
        navigationItem.rightBarButtonItem = startButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fancyAnimator = FancyAnimator(containerView: view, animatedView: squareView)
    }
    
    @objc
    private func start() {
        navigationItem.setRightBarButton(resetButtonItem, animated: true)
        navigationItem.prompt = resetInfo
        fancyAnimator?.start()
    }
    
    @objc
    private func reset() {
        navigationItem.setRightBarButton(startButtonItem, animated: true)
        navigationItem.prompt = startInfo
        fancyAnimator?.reset()
    }
}

extension ContainerViewController {
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
