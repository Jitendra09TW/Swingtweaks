//
//  Layout.swift
//  YMPartner
//
//  Created by Kauntey Suryawanshi on 12/04/21.
//

import UIKit

class Layout {
    private let v: UIView
    // OtherView is nil because size constraints dont need it
    private let otherView: UIView?
    public init(_ v: UIView, _ otherView: UIView? = nil) {
        self.v = v
        self.v.translatesAutoresizingMaskIntoConstraints = false
        self.otherView = otherView ?? v.superview
    }

    var constraints = [NSLayoutConstraint]()
    @discardableResult func top(_ i: CGFloat = 0) -> Self {
        constraints.append(v.topAnchor.constraint(equalTo: otherView!.topAnchor, constant: i))
        return self
    }

    @discardableResult func right(_ i: CGFloat = 0) -> Self {
        constraints.append(v.rightAnchor.constraint(equalTo: otherView!.rightAnchor, constant: i))
        return self
    }

    @discardableResult func bottom(_ i: CGFloat = 0) -> Self {
        constraints.append(v.bottomAnchor.constraint(equalTo: otherView!.bottomAnchor, constant: i))
        return self
    }

    @discardableResult func left(_ i: CGFloat = 0) -> Self {
        constraints.append(v.leftAnchor.constraint(equalTo: otherView!.leftAnchor, constant: i))
        return self
    }

    @discardableResult func trailing(_ i: CGFloat = 0) -> Self {
        constraints.append(v.trailingAnchor.constraint(equalTo: otherView!.trailingAnchor, constant: i))
        return self
    }

    @discardableResult func leading(_ i: CGFloat = 0) -> Self {
        constraints.append(v.leadingAnchor.constraint(equalTo: otherView!.leadingAnchor, constant: i))
        return self
    }

    @discardableResult func width(_ i: CGFloat = 0) -> Self {
        constraints.append(v.widthAnchor.constraint(equalToConstant: i))
        return self
    }

    @discardableResult func centerX(_ i: CGFloat = 0) -> Self {
        constraints.append(v.centerXAnchor.constraint(equalTo: otherView!.centerXAnchor, constant: i))
        return self
    }

    @discardableResult func centerY(_ i: CGFloat = 0) -> Self {
        constraints.append(v.centerYAnchor.constraint(equalTo: otherView!.centerYAnchor, constant: i))
        return self
    }

    @discardableResult func center() -> Self {
        self.centerX(0).centerY(0)
    }

    @discardableResult func height(_ i: CGFloat) -> Self {
        constraints.append(v.heightAnchor.constraint(equalToConstant: i))
        return self
    }

    @discardableResult func size(_ i: CGFloat) -> Self {
        self.width(i).height(i)
        return self
    }

    /// Other view can be superview
    @discardableResult func equalViews(_ i: CGFloat = 0) -> Self {
        self.top(i).right(-i).bottom(-i).left(i)
    }
}

extension UIView {
    func applyConstraints(layout: Layout) {
        assert(translatesAutoresizingMaskIntoConstraints == false)
        NSLayoutConstraint.activate(layout.constraints)
    }

    func applyConstraints(layout: (Layout) -> Layout) {
        applyConstraints(layout: layout(Layout(self)))
    }

    func addSubview(_ v: UIView, layout: (Layout) -> Layout) {
        addSubview(v)
        let edges = layout(Layout(v))
        NSLayoutConstraint.activate(edges.constraints)
    }

    func addSubview(_ v: UIView, handler: () -> Layout) {
        addSubview(v)
        let edges = handler()
        NSLayoutConstraint.activate(edges.constraints)
    }
}
