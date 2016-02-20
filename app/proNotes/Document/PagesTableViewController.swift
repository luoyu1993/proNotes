//
//  PagesTableViewController.swift
//  proNotes
//
//  Created by Leo Thomas on 28/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class PagesTableViewController: UIViewController, DocumentInstanceDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
   
   weak static var sharedInstance: PagesTableViewController?
   
   private let defaultMargin: CGFloat = 10
   
   @IBOutlet weak var tableView: UITableView!
   @IBOutlet weak var scrollView: UIScrollView!
   @IBOutlet weak var tableViewWidth: NSLayoutConstraint!
   
   var document: Document? {
      get {
         return DocumentInstance.sharedInstance.document
      }
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      tableView.panGestureRecognizer.minimumNumberOfTouches = 2
      setUpTableView()
      loadTableView()
   }
   
   override func viewWillAppear(animated: Bool) {
      super.viewWillAppear(animated)
      DocumentInstance.sharedInstance.addDelegate(self)
   }
   
   override func viewDidAppear(animated: Bool) {
      super.viewDidAppear(animated)
      setUpScrollView()
   }
   
   override func viewWillDisappear(animated: Bool) {
      super.viewWillDisappear(animated)
      DocumentInstance.sharedInstance.removeDelegate(self)
   }
   
   func loadTableView() {
      tableView.reloadData()
      tableView.setNeedsLayout()
      tableView.layoutIfNeeded()
      tableView.reloadData()
      layoutTableView()
      layoutDidChange()
   }
   
   func setUpScrollView() {
      let minZoomScale = scrollView.bounds.width / tableView.bounds.width * 0.9
      scrollView.minimumZoomScale = minZoomScale
      scrollView.maximumZoomScale = minZoomScale * 5
      scrollView.zoomScale = minZoomScale
      scrollView.panGestureRecognizer.minimumNumberOfTouches = 2
      scrollView.deactivateDelaysContentTouches()
      scrollView.showsVerticalScrollIndicator = false
      UIView.animateWithDuration(standardAnimationDuration, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 5, options: .CurveEaseInOut, animations: {
         () -> Void in
         self.scrollView.alpha = 1
         }, completion: nil)
   }
   
   func setUpTableView() {
      tableViewWidth?.constant = (document?.getMaxWidth() ?? 0) + 2 * defaultMargin
      tableView.deactivateDelaysContentTouches()
      
      view.layoutSubviews()
   }
   
   override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
   }
   
   func scroll(down: Bool) {
      tableView.setContentOffset(CGPoint(x: 0, y: tableView.contentOffset.y + 75 * (down ? 1 : -1)), animated: true)
   }
   
   // MARK: - Screen Rotation
   
   override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
      layoutDidChange()
   }
   
   override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
      coordinator.animateAlongsideTransition({
         (context) -> Void in
         self.layoutDidChange()
         }) {
            (context) -> Void in
      }
   }
   
   override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
      
   }
   
   // MARK: - Page Handling
   
   func showPage(pageNumber: Int) {
      if pageNumber < tableView.numberOfRowsInSection(0) {
         let indexPath = NSIndexPath(forRow: pageNumber, inSection: 0)
         DocumentInstance.sharedInstance.currentPage = document?[pageNumber]
         tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
      }
   }
   
   func currentPageView() -> PageView? {
      if let indexPaths = tableView.indexPathsForVisibleRows {
         for indexPath in indexPaths {
            if let cell = tableView.cellForRowAtIndexPath(indexPath) as? PageTableViewCell {
               return cell.pageView
            }
         }
      }
      
      return nil
   }
   
   func swapPagePositions(firstIndex: Int, secondIndex: Int) {
      let pagesCount = document?.pages.count ?? 0
      if firstIndex != secondIndex && firstIndex >= 0 && secondIndex >= 0 && firstIndex < pagesCount && secondIndex < pagesCount {
         tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: firstIndex, inSection: 0), NSIndexPath(forRow: secondIndex, inSection: 0)], withRowAnimation: .Automatic)
      } else {
         print("Swap Layerpositions failed with firstIndex:\(firstIndex) and secondIndex\(secondIndex) and pagesCount \(pagesCount)")
      }
   }
   
   // MARK: - Table view data source
   
   func numberOfSectionsInTableView(tableView: UITableView) -> Int {
      return 1
   }
   
   func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return document?.getNumberOfPages() ?? 0
   }
   
   func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
      let pageHeight = (document?[indexPath.row]?.size.height ?? 0)
      return pageHeight + 2 * defaultMargin
   }
   
   func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCellWithIdentifier(PageTableViewCell.identifier, forIndexPath: indexPath) as! PageTableViewCell
      
      cell.layer.setUpDefaultShaddow()
      
      if let currentPage = document?[indexPath.row] {
         cell.widthConstraint?.constant = currentPage.size.width
         cell.heightConstraint?.constant = currentPage.size.height
         cell.pageView.page = currentPage
         cell.pageView.setUpLayer()
         cell.tableView = tableView
      }
      
      cell.layoutIfNeeded()
      
      return cell
      
   }
   
   func layoutTableView() {
      
      let size = scrollView.bounds.size
      var centredFrame = tableView.frame
      
      centredFrame.origin.x = centredFrame.size.width < size.width ? (size.width - centredFrame.size.width) / 2 : 0
      
      centredFrame.origin.y = centredFrame.size.height < size.height ? (size.height - centredFrame.size.height) / 2 : 0
      
      tableView.frame = centredFrame
      updateTableViewHeight()
   }
   
   func updateTableViewHeight() {
      var frame = tableView.frame
      frame.size.height = max(scrollView.bounds.height, scrollView.contentSize.height)
      tableView.frame = frame
      scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: tableView.bounds.height)
   }
   
   func layoutDidChange() {
      layoutTableView()
      var frame = tableView.frame
      frame.origin = CGPoint(x: frame.origin.x, y: 0)
      tableView.frame = frame
   }
   
   // MARK: - UIScrollViewDelegate
   
   func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
      return tableView
   }
   
   func scrollViewDidZoom(scrollView: UIScrollView) {
      layoutDidChange()
   }
   
   func scrollViewDidScroll(scrollView: UIScrollView) {
      // only update tableview height if scrollview is'nt bouncing
      if !(scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.bounds.height
         && scrollView.contentSize.height > scrollView.bounds.height) && !(scrollView.contentOffset.y < 0) {
            updateTableViewHeight()
      }
      // disable vertical scrolling for ZoomingScrollView
      if (self.scrollView.contentOffset.y != 0) {
         self.scrollView.contentOffset = CGPoint(x: self.scrollView.contentOffset.x, y: 0);
      }
   }
   
   // MARK: - DocumentSynchronizerDelegate
   
   func didAddPage(index: NSInteger) {
      if index < tableView.numberOfRowsInSection(0) {
         let indexPath = NSIndexPath(forRow: index, inSection: 0)
         tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
      } else {
         tableView.reloadData()
      }
   }
   
}