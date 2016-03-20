//
//  PagesOverviewTableViewController.swift
//  proNotes
//
//  Created by Leo Thomas on 28/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class PagesOverviewTableViewController: UITableViewController, DocumentInstanceDelegate, ReordableTableViewDelegate {

    var document: Document? {
        get {
            return DocumentInstance.sharedInstance.document
        }
    }

    weak var pagesOverViewDelegate: PagesOverviewTableViewCellDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        (tableView as? ReordableTableView)?.reordableDelegate = self
    }


    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        DocumentInstance.sharedInstance.addDelegate(self)
        tableView.reloadData()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        DocumentInstance.sharedInstance.removeDelegate(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - ReordableTableViewDelegate

    func didSwapElements(firstIndex: Int, secondIndex: Int) {
        document?.swapPagePositions(firstIndex, secondIndex: secondIndex)
        PagesTableViewController.sharedInstance?.swapPagePositions(firstIndex, secondIndex: secondIndex)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return document?.getNumberOfPages() ?? 0
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(PagesOverviewTableViewCell.identifier, forIndexPath: indexPath) as! PagesOverviewTableViewCell

        cell.numberLabel.text = String(indexPath.row + 1)
        cell.index = indexPath.row
        cell.delegate = pagesOverViewDelegate
        if let page = document?[indexPath.row] {
            let thumbSize = page.size.sizeToFit(CGSize(width: 100, height: 100))
            cell.pageThumbViewHeightConstraint.constant = thumbSize.height
            cell.pageThumbViewWidthConstraint.constant = thumbSize.width
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                let image = page.previewImage
                dispatch_async(dispatch_get_main_queue(), {
                    cell.pageThumbView.setBackgroundImage(image, forState: .Normal)
                });
            });
        }
        
        cell.layoutIfNeeded()
        return cell
    }

    // MARK: - DocumentSynchronizerDelegate

    func didAddPage(index: Int) {
        if index < tableView.numberOfRowsInSection(0) {
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else {
            tableView.reloadData()
        }
    }
    
    func didUpdatePage(index: Int) {
        document?.pages[index].removePreviewImage()
        if index < tableView.numberOfRowsInSection(0) {
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }

}
