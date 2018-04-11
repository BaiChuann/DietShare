//
//  TopicListController.swift
//  DietShare
//
//  Created by ZiyangMou on 11/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import UIKit

class TopicListController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    private var topicList: [String] = []
    private var filteredTopicList: [String] = []
    private var topicSelectingDict: [String: Bool] = [:]
    private var isSearching = false
    
    private let publishTopicCellIdentifier = "PublishTopicCell"
    private let searchBarPlaceHolder = "Search your topics here ..."

    weak var delegate: TopicSenderDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTable()
        setUpSearchBar()
        setUpUI()
        loadTopicList()
    }

    private func setUpTable() {
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func setUpSearchBar() {
        searchBar.delegate = self
        searchBar.autocapitalizationType = .none
        searchBar.placeholder = searchBarPlaceHolder
    }

    private func setUpUI() {
        let nextButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(goBackToPublisher(_:)))
        nextButton.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = nextButton
    }

    private func loadTopicList() {
        topicList = ["1", "2", "3", "4", "5", "6", "7", "11", "12", "15", "22", "100", "101", "1000"]
        topicList.forEach { topicSelectingDict[$0] = false }
    }

    @objc private func goBackToPublisher(_ sender: UIBarButtonItem) {
        let sendingTopics = topicSelectingDict.filter { $0.value }.map { $0.key }
        delegate?.sendTopics(topics: sendingTopics)
        navigationController?.popViewController(animated: true)
    }
}

extension TopicListController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredTopicList.count
        }
        return topicList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: publishTopicCellIdentifier,
                                                 for: indexPath)
        guard let topicCell = cell as? PublishTopicCell else {
            return cell
        }

        let labelText = isSearching ?
            filteredTopicList[indexPath.item] :
            topicList[indexPath.item]

        if topicSelectingDict[labelText] == true {
            topicCell.highlight()
        } else {
            topicCell.unHightlight()
        }

        topicCell.setLabelText(text: labelText)
        return topicCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let selected = isSearching ?
            filteredTopicList[indexPath.item] :
            topicList[indexPath.item]

        topicSelectingDict[selected] = !(topicSelectingDict[selected]!)
        self.tableView.reloadData()
    }
}

extension TopicListController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchText == "" {
            isSearching = false
            view.endEditing(true)
        } else {
            isSearching = true
            filteredTopicList = topicList.filter {
                filterText(pattern: searchText, original: $0)
            }
        }
        tableView.reloadData()
    }

    func filterText(pattern: String, original: String) -> Bool {
        guard pattern.count <= original.count else {
            return false
        }
        let lowerPattern = pattern.lowercased()
        let lowerOriginal = original.lowercased()
        return lowerOriginal.range(of: lowerPattern) != nil
    }
}
