//
//  SignatureScreen.swift
//  Invoice
//
//  Invoice/Signature: landscape signing pad (eraser / undo / redo). The app is
//  portrait-only, so the landscape layout is drawn rotated a quarter turn, as in
//  the design. "Done" stores a PNG in `Document.signatureImage`.
//

import SwiftUI
import Factory

struct SignatureScreen: View {
    @InjectedObject(\.documentEditor) private var editor: DocumentEditor
    @Injected(\.app) private var app

    @State private var strokes: [[CGPoint]] = []
    @State private var redoStack: [[CGPoint]] = []
    @State private var currentStroke: [CGPoint] = []
    /// The stored signature was erased (so it is neither drawn nor kept).
    @State private var clearedExisting = false

    private var existingImage: UIImage? {
        guard !clearedExisting, let data = editor.document.signatureImage else { return nil }
        return UIImage(data: data)
    }

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            landscape(width: size.height, height: size.width)
                .frame(width: size.height, height: size.width)
                .rotationEffect(.degrees(90))
                .frame(width: size.width, height: size.height)
        }
        .ignoresSafeArea()
        .statusBarHidden(true)
        .trackScreen(.documentSignature)
    }

    // MARK: - Landscape layout

    private func landscape(width: CGFloat, height: CGFloat) -> some View {
        VStack(spacing: 0) {
            toolbar
                .frame(height: 60)
                .background(Color(R.color.colorFFFFFF))

            pad
                .frame(width: width * 603 / 852, height: max(height - 125, 160))
                .padding(.top, 20)

            Spacer(minLength: 0)
        }
        .frame(width: width, height: height)
        .background(Color(R.color.colorF4F4F6))
    }

    private var toolbar: some View {
        HStack(spacing: 0) {
            Button(R.stringLocalizable.common_cancel()) { app.navi.pop() }
                .font(.body.weight(.medium))
                .foregroundStyle(Color(R.color.color6B6B78))
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 45) {
                Button(action: eraseAll) {
                    Image(R.image.ic_document_eraser)
                        .frame(width: 24, height: 24)
                }
                Button(action: undo) {
                    Image(R.image.ic_document_redo)
                        .renderingMode(.template)
                        .scaleEffect(x: -1, y: 1)
                        .foregroundStyle(strokes.isEmpty ? Color(R.color.color8E8E93) : Color(R.color.color151515))
                }
                .disabled(strokes.isEmpty)
                Button(action: redo) {
                    Image(R.image.ic_document_redo)
                        .renderingMode(.template)
                        .foregroundStyle(redoStack.isEmpty ? Color(R.color.color8E8E93) : Color(R.color.color151515))
                }
                .disabled(redoStack.isEmpty)
            }
            .buttonStyle(.plain)

            Button(action: save) {
                Text(R.stringLocalizable.common_done())
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color(R.color.colorFFFFFF))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color(R.color.color111118)))
                    .buttonElevation()
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, 28)
    }

    private var pad: some View {
        GeometryReader { proxy in
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(R.color.colorFFFFFF))
                if let existingImage, strokes.isEmpty, currentStroke.isEmpty {
                    Image(uiImage: existingImage)
                        .resizable()
                        .scaledToFit()
                        .padding(24)
                }
                Canvas { context, _ in
                    for stroke in strokes + [currentStroke] {
                        context.stroke(Self.path(for: stroke), with: .color(Color(R.color.color111118)),
                                       style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                    }
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { value in currentStroke.append(value.location) }
                    .onEnded { _ in
                        if !currentStroke.isEmpty {
                            strokes.append(currentStroke)
                            redoStack.removeAll()
                        }
                        currentStroke = []
                    }
            )
        }
    }

    // MARK: - Actions

    private func eraseAll() {
        strokes.removeAll()
        redoStack.removeAll()
        currentStroke = []
        clearedExisting = true
    }

    private func undo() {
        guard let last = strokes.popLast() else { return }
        redoStack.append(last)
    }

    private func redo() {
        guard let last = redoStack.popLast() else { return }
        strokes.append(last)
    }

    private func save() {
        if !strokes.isEmpty {
            editor.document.signatureImage = renderSignature()
            editor.document.signedDate = Date()
        } else if clearedExisting {
            editor.document.signatureImage = nil
            editor.document.signedDate = nil
        }
        app.navi.pop()
    }

    /// Transparent PNG of the strokes, cropped to the drawn area.
    private func renderSignature() -> Data? {
        let points = strokes.flatMap { $0 }
        guard let minX = points.map(\.x).min(), let maxX = points.map(\.x).max(),
              let minY = points.map(\.y).min(), let maxY = points.map(\.y).max() else { return nil }
        let inset: CGFloat = 4
        let bounds = CGRect(x: minX - inset, y: minY - inset,
                            width: max(maxX - minX, 1) + inset * 2, height: max(maxY - minY, 1) + inset * 2)
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        let image = UIGraphicsImageRenderer(size: bounds.size, format: format).image { context in
            let cg = context.cgContext
            cg.translateBy(x: -bounds.minX, y: -bounds.minY)
            cg.setStrokeColor(UIColor(Color(R.color.color111118)).cgColor)
            cg.setLineWidth(2.5)
            cg.setLineCap(.round)
            cg.setLineJoin(.round)
            for stroke in strokes {
                cg.addPath(Self.path(for: stroke).cgPath)
                cg.strokePath()
            }
        }
        return image.pngData()
    }

    /// Smooth path through the touch points (quadratic curves between midpoints).
    private static func path(for points: [CGPoint]) -> Path {
        var path = Path()
        guard let first = points.first else { return path }
        path.move(to: first)
        if points.count == 1 {
            path.addLine(to: CGPoint(x: first.x + 0.1, y: first.y + 0.1))
            return path
        }
        for index in 1..<points.count {
            let previous = points[index - 1]
            let current = points[index]
            let mid = CGPoint(x: (previous.x + current.x) / 2, y: (previous.y + current.y) / 2)
            path.addQuadCurve(to: mid, control: previous)
        }
        path.addLine(to: points[points.count - 1])
        return path
    }
}
