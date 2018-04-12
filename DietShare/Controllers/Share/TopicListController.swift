//
//  TopicListController.swift
//  DietShare
//
//  Created by ZiyangMou on 11/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
// swiftlint:disable implicity_unwrapped_optional weak_delegate

import Foundation
import UIKit

class TopicListController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    private var topicModel: TopicsModelManager<Topic> = TopicsModelManager<Topic>()

    private var topicList: [PublishTopic] = []
    private var filteredTopicList: [PublishTopic] = []
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
        //topicList = topicModel.getAllTopics().map { toPublishTopic(topic: $0) }
        topicList = [PublishTopic(id: "1", name: "11", image: UIImage(named: "vegi-life")!, popularity: "1111"),
        PublishTopic(id: "2", name: "11111", image: UIImage(named: "vegi-life")!, popularity: "1111"),
        PublishTopic(id: "3", name: "121", image: UIImage(named: "vegi-life")!, popularity: "1111"),
        PublishTopic(id: "4", name: "112222", image: UIImage(named: "vegi-life")!, popularity: "1111")]
    }

    @objc private func goBackToPublisher(_ sender: UIBarButtonItem) {
        let sending = topicList.filter { $0.isHighlighted }.map { (id: $0.id, name: $0.name) }
        delegate?.sendTopics(topics: sending)
        navigationController?.popViewController(animated: true)
    }

    private func toPublishTopic(topic: Topic) -> PublishTopic {
        let id = topic.getID()
        let name = topic.getName()
        let image = topic.getImageAsUIImage()
        let popularity = String(topic.getPopularity())
        return PublishTopic(id: id, name: name, image: image, popularity: popularity)
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
        let image = topic.image
        let popularity = topic.popularity
        topicCell.setLabelText(name: name, image: image, popularity: popularity)

        return topicCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let selected = isSearching ?
            filteredTopicList[indexPath.item] :
            topicList[indexPath.item]

        selected.select()
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

private class PublishTopic {

    private(set) var id: String
    private(set) var name: String
    private(set) var image: UIImage
    private(set) var popularity: String
    private(set) var isHighlighted: Bool

    init(id: String, name: String, image: UIImage, popularity: String) {
        self.id = id
        self.name = name
        self.image = image
        self.popularity = popularity
        self.isHighlighted = false
    }

    func select() {
        isHighlighted = !isHighlighted
    }
}
