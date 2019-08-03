//
//  UITableView+Bond.swift
//  ExCast
//
//  Created by Tasuku Tozawa on 2019/08/03.
//  Copyright © 2019 Tasuku Tozawa. All rights reserved.
//

import UIKit

private var handle: UInt8 = 0;

protocol BondableTableView: AnyObject {
    associatedtype ContentType
    var contents: Array<ContentType> { get set }
}

extension BondableTableView where Self: UITableView {
    var contentsBond: ArrayBond<ContentType> {
        if let bond = objc_getAssociatedObject(self, &handle) {
            return bond as! ArrayBond<ContentType>
        }

        let bond = ArrayBond<ContentType>(insert: { [unowned self] tuples in
            DispatchQueue.main.async { [unowned self] in
                tuples.forEach { [unowned self] tuple in
                    self.contents.insert(tuple.1, at: tuple.0)
                }
                let indexPathes = tuples.map { IndexPath(item: $0.0, section: 0) }

                if tuples.count == 1 {
                    self.beginUpdates()
                    self.insertRows(at: indexPathes, with: .automatic)
                    self.endUpdates()
                }

                self.reloadData()
            }
            }, remove: { [unowned self] tuples in
                DispatchQueue.main.async { [unowned self] in
                    tuples.forEach { [unowned self] tuple in self.contents.remove(at: tuple.0) }
                    let indexPathes = tuples.map { IndexPath(item: $0.0, section: 0) }

                    if tuples.count == 1 {
                        self.beginUpdates()
                        self.deleteRows(at: indexPathes, with: .automatic)
                        self.endUpdates()
                    }
                }
            }, update: { [unowned self] tuples in
                DispatchQueue.main.async { [unowned self] in
                    tuples.forEach { [unowned self] tuple in self.contents[tuple.0] = tuple.1 }
                    self.reloadData()
                }
        })
        objc_setAssociatedObject(self, &handle, bond, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return bond
    }
}

