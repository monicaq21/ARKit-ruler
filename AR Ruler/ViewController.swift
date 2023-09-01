//
//  ViewController.swift
//  AR Ruler
//
//  Created by Monica Qiu on 8/31/23.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // help debug
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // on third tap, clear the dots
        if dotNodes.count >= 2 {
            for dotNode in dotNodes {
                dotNode.removeFromParentNode()
            }
            textNode.removeFromParentNode()
            dotNodes = [SCNNode]()
            textNode = SCNNode()
            return
        }
        
        guard let touchPoint = touches.first?.location(in: sceneView) else { return }
        
//        let hitTestResults = sceneView.raycastQuery(from: touchPoint, allowing: .estimatedPlane, alignment: .horizontal) xxx
        let hitTestResults = sceneView.hitTest(touchPoint, types: .featurePoint)
        
        if let hitTestResult = hitTestResults.first {
            addDot(at: hitTestResult)
        }
        
    }
    
    private func addDot(at result: ARHitTestResult) {
        let dotGeometry = SCNSphere(radius: 0.005)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        dotGeometry.materials = [material]
        
        let dotNode = SCNNode(geometry: dotGeometry)
        dotNode.position = SCNVector3(
            result.worldTransform.columns.3.x,
            result.worldTransform.columns.3.y,
            result.worldTransform.columns.3.z
        )
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        dotNodes.append(dotNode)
        if dotNodes.count >= 2 {
            calculate()
        }
    }
    
    private func calculate() {
        assert(dotNodes.count >= 2)
        let start = dotNodes[0]
        let end = dotNodes[1]
        
        let dist_x = start.position.x - end.position.x
        let dist_y = start.position.y - end.position.y
        let dist_z = start.position.z - end.position.z
        
        let distance = sqrt(pow(dist_x, 2) + pow(dist_y, 2) + pow(dist_z, 2))
        
        updateText(text: "\(distance)", atPosition: end.position)
    }
    
    private func updateText(text: String, atPosition position: SCNVector3) {
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.blue
        
        let textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(position.x, position.y, position.z)
        textNode.scale = SCNVector3(0.01, 0.01, 0.01) // reduces text size to 1% of original size
        
        self.textNode = textNode
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

}
