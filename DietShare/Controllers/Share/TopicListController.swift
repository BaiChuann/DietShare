//
//  TopicListController.swift
//  DietShare
//
//  Created by ZiyangMou on 11/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
// swiftlint:disable implicitly_unwrapped_optional weak_delegate force_unwrapping

import Foundation
import UIKit

class TopicListController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var nextButton: UIBarButtonItem!

    var selectedTopicID: [String] = []

    private var topicModel: TopicsModelManager<Topic> = TopicsModelManager<Topic>()

    private var topicList: [PublishTopic] = []
    private var filteredTopicList: [PublishTopic] = []
    private var isSearching = false

    private var selectedNumber: Int = 0
    private let maximumSelection: Int = 5

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
        nextButton.title = "Next(\(selectedNumber)/\(maximumSelection))"
        nextButton.style = .plain
        nextButton.target = self
        nextButton.action = #selector(goBackToPublisher(_:))
        nextButton.tintColor = UIColor.black
    }

    private func loadTopicList() {
        //topicList = topicModel.getAllTopics().map { toPublishTopic(topic: $0) }
        topicList = [PublishTopic(id: "1", name: "1", popularity: "1111"),
        PublishTopic(id: "2", name: "2", popularity: "1111"),
        PublishTopic(id: "3", name: "3", popularity: "1111"),
        PublishTopic(id: "4", name: "4", popularity: "1111"),
        PublishTopic(id: "5", name: "5", popularity: "1111"),
        PublishTopic(id: "6", name: "6", popularity: "1111"),
        PublishTopic(id: "7", name: "7", popularity: "1111"),
        PublishTopic(id: "8", name: "8", popularity: "1111"),
        PublishTopic(id: "9", name: "9", popularity: "1111"),
        PublishTopic(id: "10", name: "10", popularity: "1111"),
        PublishTopic(id: "11", name: "11", popularity: "1111"),
        PublishTopic(id: "12", name: "12", popularity: "1111"),
        PublishTopic(id: "13", name: "13", popularity: "1111"),
        PublishTopic(id: "14", name: "14", popularity: "1111"),
        PublishTopic(id: "15", name: "15", popularity: "1111"),
        PublishTopic(id: "16", name: "16", popularity: "1111")]
        let selectedTopics = topicList.filter { selectedTopicID.contains($0.id) }
        selectedNumber = selectedTopics.count
        selectedTopics.reversed().forEach { topic in
            _ = topic.select()
            topicList.remove(at: topicList.index(of: topic)!)
            topicList.insert(topic, at: 0)
        }
    }

    @objc private func goBackToPublisher(_ sender: UIBarButtonItem) {
        let sending = topicList.filter { $0.isHighlighted }.map { (id: $0.id, name: $0.name) }
        delegate?.sendTopics(topics: sending)
        navigationController?.popViewController(animated: true)
    }

    private func toPublishTopic(topic: Topic) -> PublishTopic {
        let id = topic.getID()
        let name = topic.getName()
        let popularity = String(topic.getPopularity())
        return PublishTopic(id: id, name: name, popularity: popularity)
    }

    private func updateNextButton() {
        nextButton.title = "Next(\(selectedNumber)/\(maximumSelection))"
    }
}

// Extension for table view
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

        let topic = isSearching ? filteredTopicList[indexPath.item] : topicList[indexPath.item]

        if topic.isHighlighted {
           topicCell.highlight()
        } else {
            topicCell.unHightlight()
        }

        let name = topic.name
        let popularity = topic.popularity
        topicCell.setLabelText(name: name, popularity: popularity)

        return topicCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let selected = isSearching ?
            filteredTopicList[indexPath.item] :
            topicList[indexPath.item]

        guard selectedNumber < maximumSelection || selected.isHighlighted else {
            self.tableView.reloadData()
            return
        }
        selectedNumber += selected.select()
        updateNextButton()
        self.tableView.reloadData()
    }
}

// Extension for search bar
extension TopicListController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchText == "" {
            isSearching = false
            view.endEditing(true)
        } else {
            isSearching = true
            filteredTopicList = topicList.filter {
                filterText(pattern: searchText, original: $0.name)
            }
        }
        tableView.reloadData()
    }

    private func filterText(pattern: String, original: String) -> Bool {
        guard pattern.count <= original.count else {
            return false
        }
        let lowerPattern = pattern.lowercased()
        let lowerOriginal = original.lowercased()
        return lowerOriginal.range(of: lowerPattern) != nil
    }
}

private class PublishTopic: Equatable {
    private(set) var id: String
    private(set) var name: String
    private(set) var popularity: String
    private(set) var isHighlighted: Bool

    static func == (lhs: PublishTopic, rhs: PublishTopic) -> Bool {
        return lhs.id == rhs.id
    }

    init(id: String, name: String, popularity: String) {
        self.id = id
        self.name = name
        self.popularity = popularity
        self.isHighlighted = false
    }

    func select() -> Int {
        isHighlighted = !isHighlighted
        return isHighlighted ? 1 : -1
    }
}
