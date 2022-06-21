//
//  SearchViewController.swift
//  UICollectionView_Extandable
//
//  Created by Jmy on 2021/05/20.
//

import SnapKit
import Then
import UIKit

final class SearchViewController: UIViewController {
    // MARK: - Variables

    private var searches: [Search] = [
        Search(
            isExpand: false,
            title: "인기 검색",
            terms: ["캠핑", "가방", "고양이", "건전지", "오미자"]
        ),
        Search(
            isExpand: false,
            title: "최근 검색",
            terms: ["충전기", "강아지", "개구리", "두꺼비", "아이유"]
        ),
        Search(
            isExpand: false,
            title: "연관 검색",
            terms: ["보충제", "고구마", "헬스장", "런닝머신", "다이어트"]
        ),
    ]

    // MARK: - Views

    private lazy var collectionView = BaseCollectionView(layout: flowLayout()).then {
        $0.dataSource = self
        $0.delegate = self
        $0.prefetchDataSource = self
        $0.isPrefetchingEnabled = true
        $0.register(SearchTitleCell.self)
        $0.register(SearchTermCell.self)
    }

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        flowLayout.invalidateLayout()
    }

    // MARK: - Methods

    private func setupViews() {
        view.addSubview(collectionView)

        collectionView.snp.makeConstraints {
            $0.top.left.right.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalToSuperview()
        }
    }

    private func removeAllCells() {
        for section in 0 ..< collectionView.numberOfSections {
            section.description.log()

            let indexPath = IndexPath(item: 0, section: section)
            removeCell(indexPath: indexPath)
        }
    }

    private func removeCell(indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? SearchTitleCell {
            cell.removeFromSuperview()
        }
        indexPath.description.log()
    }
}

// MARK: - UICollectionViewDataSource

extension SearchViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return searches.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let search = searches[section]

        if search.isExpand {
            return search.terms.count + 1
        } else {
            return 1
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let search = searches[indexPath.section]

        switch indexPath.item {
        case 0:
            let cell: SearchTitleCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.bind(search: search)
            return cell
        default:
            let cell: SearchTermCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.bind(
                rank: indexPath.item,
                term: search.terms[indexPath.item - 1]
            )
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegate

extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.item {
        case 0:
            removeCell(indexPath: indexPath)

            searches[indexPath.section].isExpand.toggle()

            let sections = IndexSet(integer: indexPath.section)
            collectionView.reloadSections(sections)
        default:
            searches[indexPath.section].terms[indexPath.item - 1].log()
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        indexPath.description.log()
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        indexPath.description.log()
    }
}

// MARK: - UICollectionViewDataSourcePrefetching

extension SearchViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.description.log()
    }

    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        indexPaths.description.log()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.item {
        case 0:
            return itemSize(width: collectionView, height: SearchTitleCell.itemHeight)
        default:
            return itemSize(width: collectionView, height: SearchTermCell.itemHeight)
        }
    }
}

// MARK: - FlowLayoutMetric

extension SearchViewController: FlowLayoutMetric {
    var numberOfItemForRow: CGFloat {
        1
    }

    var sectionInset: UIEdgeInsets {
        .uniform(size: 0)
    }

    var minimumLineSpacing: CGFloat {
        1
    }

    var minimumInteritemSpacing: CGFloat {
        0
    }
}
