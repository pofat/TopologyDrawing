//
//  ViewController.swift
//  TopologyMusicNode
//
//  Created by Pofat Tseng on 2018/3/14.
//  Copyright © 2018年 Pofat. All rights reserved.
//

import UIKit
import SwiftGraph

class ViewController: UIViewController {
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var calculateButton: UIButton!
    @IBOutlet weak var topologyButton: UIButton!
    @IBOutlet weak var nodeContainerView: TopologyView!
    
    var didAddStartAndEndNode = false
    var containerSize: CGSize = CGSize.zero
    
    enum State {
        case noTopology, notCalculated, calculated
    }
    
    var state: State = .noTopology {
        didSet {
            updateUI()
        }
    }
    
    let topology = Topology()
    var answer: [Node]? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerSize = nodeContainerView.frame.size
        
        if !didAddStartAndEndNode {
            let hSpacing = (containerSize.width - 8 * 2 - 60 * 7)/6
            
            let start = CircleView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
            start.setValue(text: "Start")
            start.tag = 499
            start.backgroundColor = .red
            start.frame.origin = CGPoint(x: 8, y: containerSize.height/2 - 30)
            nodeContainerView.addSubview(start)
            
            let end = CircleView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
            end.setValue(text: "End")
            end.tag = 515
            end.backgroundColor = .orange
            end.frame.origin = CGPoint(x: containerSize.width - 8 - 60, y: containerSize.height/2 - 30)
            nodeContainerView.addSubview(end)
            
            for i in 0...14 {
                let internalNode = CircleView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
                internalNode.tag = 500 + i
                internalNode.backgroundColor = .blue
                internalNode.isHidden = true
                let horizontalOffset = 8 + CGFloat(i/3 + 1) * (hSpacing + 60)
                if i % 3 == 0 {
                    internalNode.frame.origin = CGPoint(x: horizontalOffset, y: 8)
                } else if i % 3 == 1 {
                    internalNode.frame.origin = CGPoint(x: horizontalOffset, y: containerSize.height / 2 - 30)
                } else {
                    internalNode.frame.origin = CGPoint(x: horizontalOffset, y: containerSize.height - 60 - 8)
                }
                nodeContainerView.addSubview(internalNode)
            }
            
            didAddStartAndEndNode = true
        }
    }
    
    @IBAction func topologyClick() {
        topologyButton.isEnabled = false
        state = .noTopology
        DispatchQueue.global().async {
            // 去掉下行註解可以在生成 topology 時會任意地從可選的地方選擇 parent / children
            //self.topology.generateNewTopology { [unowned self] in
            // 下行只會在相隔的層數以內（此為隔 2 層)選擇 parent / children
            self.topology.generateNewTopology(randomLevelUpperBound: 2) { [unowned self] in
                print("new topology completed")
                DispatchQueue.main.async {
                    self.state = .notCalculated
                    self.nodeContainerView.topology = self.topology
                    self.topologyButton.isEnabled = true
                }
            }
        }
    }
    
    
    @IBAction func calculateMinimumPath() {

//        calcByDFS()
        calcByDijkstra()
        
        state = .calculated
    }
    
    // Using my DFS method
    func calcByDFS() {
        let allPossiblePaths = topology.graph!.findAllPathsByDFS(from: topology.start) { node in
            return node == topology.end
        }
        
        var minSum = Int.max
        var minIndex = -1
        var result: [Node] = []
        for index in 0 ..< allPossiblePaths.count {
            let edges = allPossiblePaths[index]
            let path = edgesToVertices(edges: edges, graph: topology.graph!)
            var sum = 0
            path.forEach {
                sum += $0.value
            }
            minSum = min(sum, minSum)
            if minSum == sum {
                minIndex = index
                result = path
            }
        }
        
        
        
        print("min value: \(minSum) at \(minIndex)-th path")
        answer = result
        nodeContainerView.answer = answer
    }
    
    // Using Dijkstra's algorithm
    func calcByDijkstra() {
        let (distances, pathDict) = topology.graph!.dijkstra(root: topology.start, startDistance: 0)
        let nameDistance: [Node: Int?] = distanceArrayToVertexDict(distances: distances, graph: topology.graph!)
        
        if let distance = nameDistance[topology.end], let minValue = distance {
            print("min value:\(minValue)")
            let path: [WeightedEdge<Int>] = pathDictToPath(from: topology.graph!.indexOfVertex(topology.start)!, to: topology.graph!.indexOfVertex(topology.end)!, pathDict: pathDict)
            let nodes: [Node] = edgesToVertices(edges: path, graph: topology.graph!)
            answer = nodes
            nodeContainerView.answer = answer
        } else {
            answer = []
            nodeContainerView.answer = answer
        }
        
        
        
    }
    
    @IBAction func play() {
        guard let answer = answer else {
            print("no result")
            return
        }
        
        print("minimum path is : \(answer.map { $0.id })")
        let notes = answer.filter { $0.position == .intermediate }.map { $0.value }
        print("will play: \(notes)")
        playNotes(from: notes)
    }

    func updateUI() {
        
        nodeContainerView.state = state
        
        switch state {
        case .noTopology:
            playButton.isEnabled = false
            calculateButton.isEnabled = false
            // hide all internal nodes
            for i in 0...14 {
                let tag = 500 + i
                if let viewIndex = nodeContainerView.subviews.index(where: {
                    $0.tag == tag
                }) {
                    let view = nodeContainerView.subviews[viewIndex]
                    view.isHidden = true
                    view.backgroundColor = .blue
                }
            }
        case .notCalculated:
            playButton.isEnabled = false
            calculateButton.isEnabled = true
            
            for n in topology.visibleInternalNodes() {
                let tag = n.id + 500
                if let viewIndex = nodeContainerView.subviews.index(where: {
                    $0.tag == tag
                }) {
                    let view = nodeContainerView.subviews[viewIndex]
                    view.isHidden = false
                    
                    if let cView = view as? CircleView {
                        cView.setValue(text: String(n.value))
                    }
                }
            }
        case .calculated:
            calculateButton.isEnabled = true
            if let answer = answer, !answer.isEmpty {
                playButton.isEnabled = true
                
                for n in answer {
                    let tag = n.id + 500
                    if let viewIndex = nodeContainerView.subviews.index(where: {
                        $0.tag == tag
                    }), n.position == .intermediate {
                        let view = nodeContainerView.subviews[viewIndex]
                        view.backgroundColor = .red
                    }
                }
                
            } else {
                
                let alert = UIAlertController(title: "計算失敗", message: "沒有發現可以從起點走到終點的路徑", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                present(alert, animated: true, completion: nil)
                
                playButton.isEnabled = false
            }
        }
    }
}

