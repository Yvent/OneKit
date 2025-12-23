//
//  ActivityView.swift
//  OneKit
//
//  Created by zyw on 2025/12/23.
//

import UIKit
import SwiftUI

struct ActivityView: UIViewControllerRepresentable {

    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        controller.popoverPresentationController?.sourceView = UIApplication.shared.windows.first?.rootViewController?.view
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityView>) {}

}
