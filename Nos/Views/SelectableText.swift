//
//  SelectableText.swift
//  Planetary
//
//  Created by Martin Dutra on 20/9/22.
//  Copyright © 2022 Verse Communications Inc. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

/// A ViewRepresentable that wraps a UILabel meant to be used in place of Text when selection word by word is desired.
///
/// SwiftUI's Text cannot be configured to be selected in a word by word basis, just the whole text, wrapping up a
/// UILabel achieves this. Also, this is configured to use a monospaced font as the intended use at the moment is
/// when showing a Source Message.
struct SelectableText: UIViewRepresentable {

    var attributedText: AttributedString

    init(_ attributedText: AttributedString) {
        self.attributedText = attributedText
    }
    
    init(_ string: String) {
        self.attributedText = AttributedString(string)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        attributedText.setAttributes(AttributeContainer([
            .font: UIFont.clarity,
            .foregroundColor: UIColor.primaryTxt,
            .paragraphStyle: paragraphStyle
        ]))
    }

    private var font = UIFont.preferredFont(forTextStyle: .body)
    private var insets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.attributedText = NSAttributedString(attributedText)
        view.dataDetectorTypes = .link
        view.isUserInteractionEnabled = true
        view.isEditable = false
        view.isSelectable = true
        view.tintColor = .accent
        view.textContainerInset = insets
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = NSAttributedString(attributedText)
    }
}

struct SelectableText_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable line_length
        let string = """
        {
            "key": "%6Ic4dzY/mBxVXdSNwSIyQ1TqBp+FKsY+tLnumBPdxaA=.sha256",
            "value": {
                "previous": "%d8Iyl2ZVHwdyiAAeIvbDCVXVeLXPYajI7IRHgC0/rf4=.sha256",
                "author": "@8Y7zrkRdt1HxkueXjdwIU4fbYkjapDztCHgjNjiCn/M=.ed25519",
                "sequence": 31,
                "timestamp": 1549386935492,
                "hash": "sha256",
                "content": {
                    "type": "vote",
                    "channel": "ssb-server",
                    "vote": {
                        "link": "%OoBqCtaYm6ayBQqCVlHi66vsWfvaK5+t98aqsXlRyZU=.sha256",
                        "value": 1,
                        "expression": "Like"
                    }
                },
                "signature": "8caUJ2gqJ4DOnfD2gDFpyWbseUeNMhzX/tr8j2IR7xSG3GcyDG8GCAyrv7YkOTu2PnEM6fdLb1jNrit+YVYlDg==.sig.ed25519"
            },
            "timestamp": 1546962907954.0059
        }
        """
        // swiftlint:enable line_length
        SelectableText(AttributedString(string))
        .previewLayout(.sizeThatFits)
    }
}
