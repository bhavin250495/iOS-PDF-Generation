//
//  ViewController.swift
//  pdfCreator
//
//  Created by Jayesh Sharma on 21/10/18.
//  Copyright © 2018 HobbyDev. All rights reserved.
//

import UIKit
//Using quicklook to view pdf
import QuickLook
//
class ViewController: UIViewController {
    
    @IBOutlet weak var collectionVIew: UICollectionView!
    var quickLookController:QLPreviewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionVIew.delegate = self
        collectionVIew.dataSource = self
        let  flow = UICollectionViewFlowLayout.init()
        flow.minimumLineSpacing = 0
        flow.minimumInteritemSpacing = 0
        self.collectionVIew.collectionViewLayout = flow
        self.collectionVIew.layoutIfNeeded()
        
        //Generate PDF
        genPDF()
        
        //Initialize Quicklook
        intializeQuicklook()
        //Show PDF in QuickLook
        viewPDF()
        
        //TODO:  delete is commented because viewing take few minutes to show
        //Delete Temp File
        //deleteTempPDFFile(fileName: "Test")
    }
    
    
    
    func genPDF(){
        //collection view bound indicate pdf page
        let pageDimensions = collectionVIew.bounds
        let pageSize = pageDimensions.size
        
        //conllection view content size indecate size of whole pdf which we will need
        let totalSize = collectionVIew.contentSize
        
        //Get pdf pages
        let numOfPagesHorizontal = Int(ceil(totalSize.width/pageSize.width))
        let numOfPagesVertically = Int(ceil(totalSize.height/pageSize.height))
        
        let fileName = "Test"
        
        //Create file in tmp directory as we dont need to store file permanantly which will consume space
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName).appendingPathExtension("pdf")
        
        //Create context to write pdf in
        UIGraphicsBeginPDFContextToFile(fileURL.path, pageDimensions, nil)
        
        //original collection view offset
        let savedContextOffset = collectionVIew.contentOffset
        let savedCOntextInset = collectionVIew.contentInset
        
        //make sure we start from 0,0 pixel of collection
        collectionVIew.contentInset = UIEdgeInsets.zero
        
        //Start creating pdf
        if let context = UIGraphicsGetCurrentContext(){
            //loop over horizontal pdf pages
            for indexHor in 0..<numOfPagesHorizontal {
                //nested loop over vertical pdf pages
                for indexVer in 0..<numOfPagesVertically {
                    //Create new pdf page
                    UIGraphicsBeginPDFPage()
                    //Create offset to render data from collection view
                    let offsetHorizontal = CGFloat.init(indexHor) * pageSize.width
                    let offsetVertical = CGFloat.init(indexVer) * pageSize.height
                    
                    //set new offset to collection view to render
                    collectionVIew.contentOffset = CGPoint.init(x: offsetHorizontal, y: offsetVertical)
                    context.translateBy(x: -offsetHorizontal, y: -offsetVertical)
                    
                    //Finally take data from collection view at that offset and place it on context new page
                    collectionVIew.layer.render(in: context)
                }
            }
            //End context once all pdf pages are rendered
            UIGraphicsEndPDFContext()
        }
        
        //reset collecton view offsets
        collectionVIew.contentInset = savedCOntextInset
        collectionVIew.contentOffset = savedContextOffset
        
        
        
    }
    
    func deleteTempPDFFile(fileName:String) {
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName).appendingPathExtension("pdf")
        try! FileManager.default.removeItem(at: fileURL)
    }
    
}
extension ViewController:UICollectionViewDelegate,
UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: (self.view.bounds.width/3)-10, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionVIew.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        if let label =  cell.viewWithTag(2) as? UILabel {
            label.text = UUID.init().uuidString
        }
        return cell
    }
}

//MARK: PDF viewer
extension ViewController {
    func intializeQuicklook(){
        quickLookController = QLPreviewController.init()
        self.quickLookController.dataSource = self
    }
    func viewPDF() {
        DispatchQueue.main.async {
            self.present(self.quickLookController, animated: true, completion: nil)
        }
        
    }
}
extension ViewController:QLPreviewControllerDataSource{
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("Test").appendingPathExtension("pdf")
        return fileURL as QLPreviewItem
        
    }
    
    
    
}

