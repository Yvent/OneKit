//
//  UIView+ExtensionsTests.swift
//  OneKit
//
//  Created by zyw on 2025/12/30.
//

import Testing
@testable import OneKitCore
#if canImport(UIKit)
import UIKit
#endif

#if canImport(UIKit)

@Suite("UIView Extensions Tests")
@MainActor
struct UIViewExtensionsTests {

    // MARK: - View Hierarchy Tests

    /// Test addSubviews adds multiple subviews
    /// 测试批量添加子视图
    @Test("addSubviews should add all views as subviews")
    func addSubviewsTest() async throws {
        let parentView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let child1 = UIView()
        let child2 = UIView()
        let child3 = UIView()

        parentView.addSubviews([child1, child2, child3])

        #expect(parentView.subviews.count == 3, "Should have 3 subviews")
        #expect(parentView.subviews.contains(child1), "Should contain child1")
        #expect(parentView.subviews.contains(child2), "Should contain child2")
        #expect(parentView.subviews.contains(child3), "Should contain child3")
    }

    /// Test addSubviews with empty array
    /// 测试添加空数组
    @Test("addSubviews with empty array should not add any views")
    func addSubviewsEmptyTest() async throws {
        let parentView = UIView()
        parentView.addSubviews([])

        #expect(parentView.subviews.isEmpty, "Should have no subviews")
    }

    /// Test setSubviewsHidden sets hidden state correctly
    /// 测试批量设置隐藏状态
    @Test("setSubviewsHidden should set isHidden correctly")
    func setSubviewsHiddenTest() async throws {
        let view1 = UIView()
        let view2 = UIView()
        let view3 = UIView()

        view1.isHidden = false
        view2.isHidden = false
        view3.isHidden = false

        UIView().setSubviewsHidden([view1, view2, view3], isHidden: true)

        #expect(view1.isHidden == true, "view1 should be hidden")
        #expect(view2.isHidden == true, "view2 should be hidden")
        #expect(view3.isHidden == true, "view3 should be hidden")
    }

    /// Test setSubviewsHidden can show views
    /// 测试批量显示视图
    @Test("setSubviewsHidden should show views when isHidden is false")
    func setSubviewsVisibleTest() async throws {
        let view1 = UIView()
        let view2 = UIView()

        view1.isHidden = true
        view2.isHidden = true

        UIView().setSubviewsHidden([view1, view2], isHidden: false)

        #expect(view1.isHidden == false, "view1 should be visible")
        #expect(view2.isHidden == false, "view2 should be visible")
    }

    /// Test setSubviewsHidden with empty array
    /// 测试设置空数组
    @Test("setSubviewsHidden with empty array should not crash")
    func setSubviewsHiddenEmptyTest() async throws {
        UIView().setSubviewsHidden([], isHidden: true)
        // Should not crash / 不应该崩溃
    }

    // MARK: - Corner Radius Tests

    /// Test layoutCornerRadius with all corners
    /// 测试设置所有圆角
    @Test("layoutCornerRadius with radiusAll should round all corners")
    func layoutCornerRadiusAllTest() async throws {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.backgroundColor = .blue

        view.layoutCornerRadius(type: .radiusAll, cornerRadius: 10)

        #expect(view.layer.mask != nil, "Should have a mask layer")
        #expect(view.layer.masksToBounds == true, "Should have masksToBounds set")
    }

    /// Test layoutCornerRadius with top corners
    /// 测试设置上圆角
    @Test("layoutCornerRadius with radiusTop should round top corners")
    func layoutCornerRadiusTopTest() async throws {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.layoutCornerRadius(type: .radiusTop, cornerRadius: 15)

        #expect(view.layer.mask != nil, "Should have a mask layer")
    }

    /// Test layoutCornerRadius with single corner
    /// 测试设置单个圆角
    @Test("layoutCornerRadius with single corner should work")
    func layoutCornerRadiusSingleCornerTest() async throws {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.layoutCornerRadius(type: .radiusTopleft, cornerRadius: 20)

        #expect(view.layer.mask != nil, "Should have a mask layer")
    }

    /// Test layoutCornerRadius with zero radius
    /// 测试零圆角半径
    @Test("layoutCornerRadius with zero radius should work")
    func layoutCornerRadiusZeroTest() async throws {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.layoutCornerRadius(type: .radiusAll, cornerRadius: 0)

        #expect(view.layer.mask != nil, "Should have a mask layer even with zero radius")
    }

    /// Test all RadiusType cases
    /// 测试所有圆角类型
    @Test("All RadiusType cases should work without crashing")
    func allRadiusTypesTest() async throws {
        let types: [RadiusType] = [
            .radiusAll,
            .radiusTop,
            .radiusLeft,
            .radiusBottom,
            .radiusRight,
            .radiusTopleft,
            .radiusTopright,
            .radiusBottomleft,
            .radiusBottomright
        ]

        for type in types {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            view.layoutCornerRadius(type: type, cornerRadius: 5)
            #expect(view.layer.mask != nil, "RadiusType \(type) should create mask")
        }
    }

    /// Test RadiusType rectCorners computed property
    /// 测试 RadiusType 的 rectCorners 计算属性
    @Test("RadiusType rectCorners should return correct corners")
    func radiusTypeRectCornersTest() async throws {
        #expect(RadiusType.radiusAll.rectCorners == .allCorners)
        #expect(RadiusType.radiusTop.rectCorners == [.topLeft, .topRight])
        #expect(RadiusType.radiusLeft.rectCorners == [.topLeft, .bottomLeft])
        #expect(RadiusType.radiusBottom.rectCorners == [.bottomLeft, .bottomRight])
        #expect(RadiusType.radiusRight.rectCorners == [.topRight, .bottomRight])
        #expect(RadiusType.radiusTopleft.rectCorners == .topLeft)
        #expect(RadiusType.radiusTopright.rectCorners == .topRight)
        #expect(RadiusType.radiusBottomleft.rectCorners == .bottomLeft)
        #expect(RadiusType.radiusBottomright.rectCorners == .bottomRight)
    }

    // MARK: - Image Conversion Tests

    /// Test toImage converts view to image
    /// 测试视图转图片
    @Test("toImage should return UIImage")
    func toImageTest() async throws {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.backgroundColor = .red

        let image = view.toImage()

        #expect(image != nil, "Should return an image")
        #expect(image?.size.width == 100, "Image width should match view width")
        #expect(image?.size.height == 100, "Image height should match view height")
    }

    /// Test toImage with transparent view
    /// 测试透明视图转图片
    @Test("toImage should handle transparent views")
    func toImageTransparentTest() async throws {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        view.backgroundColor = .clear

        let image = view.toImage()

        #expect(image != nil, "Should return an image for transparent view")
    }

    /// Test toImage with zero-sized view
    /// 测试零尺寸视图转图片
    @Test("toImage should handle zero-sized views")
    func toImageZeroSizeTest() async throws {
        let view = UIView(frame: .zero)

        let image = view.toImage()

        #expect(image != nil, "Should return an image even for zero-sized view")
    }

    /// Test toImage with complex view hierarchy
    /// 测试复杂视图层级转图片
    @Test("toImage should capture view hierarchy")
    func toImageComplexViewTest() async throws {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        containerView.backgroundColor = .white

        let subview1 = UIView(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
        subview1.backgroundColor = .red

        let subview2 = UIView(frame: CGRect(x: 50, y: 50, width: 40, height: 40))
        subview2.backgroundColor = .blue

        containerView.addSubview(subview1)
        containerView.addSubview(subview2)

        let image = containerView.toImage()

        #expect(image != nil, "Should capture complex view hierarchy")
        #expect(image?.size.width == 100, "Image should match container width")
        #expect(image?.size.height == 100, "Image should match container height")
    }

    /// Test toImage with rounded corners
    /// 测试带圆角的视图转图片
    @Test("toImage should preserve corner radius")
    func toImageWithCornerRadiusTest() async throws {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.backgroundColor = .green
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true

        let image = view.toImage()

        #expect(image != nil, "Should return an image with corner radius")
    }

    /// Test toImage after applying layoutCornerRadius
    /// 测试应用圆角后转图片
    @Test("toImage after layoutCornerRadius should work")
    func toImageAfterLayoutCornerRadiusTest() async throws {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.backgroundColor = .purple
        view.layoutCornerRadius(type: .radiusAll, cornerRadius: 15)

        let image = view.toImage()

        #expect(image != nil, "Should return an image after applying corner radius")
    }
}

#endif
