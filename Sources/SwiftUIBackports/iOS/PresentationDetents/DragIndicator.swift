import SwiftUI

#if os(iOS)
@available(iOS, deprecated: 16)
public extension Backport where Wrapped: View {

    /// Sets the visibility of the drag indicator on top of a sheet.
    ///
    /// You can show a drag indicator when it isn't apparent that a
    /// sheet can resize or when the sheet can't dismiss interactively.
    ///
    ///     struct ContentView: View {
    ///         @State private var showSettings = false
    ///
    ///         var body: some View {
    ///             Button("View Settings") {
    ///                 showSettings = true
    ///             }
    ///             .sheet(isPresented: $showSettings) {
    ///                 SettingsView()
    ///                     .presentationDetents:([.medium, .large])
    ///                     .presentationDragIndicator(.visible)
    ///             }
    ///         }
    ///     }
    ///
    /// - Parameter visibility: The preferred visibility of the drag indicator.
    @ViewBuilder
    func presentationDragIndicator(_ visibility: Backport<Any>.Visibility) -> some View {
        if #available(iOS 16, *) {
            #if swift(>=5.7)
            content.presentationDragIndicator(visibility.map)
            #else
            content
            #endif
        } else if #available(iOS 15, *) {
            content.background(Backport<Any>.Representable(visibility: visibility))
        } else {
            content
        }
    }

}

@available(iOS 15, *)
private extension Backport where Wrapped == Any {
    struct Representable: UIViewControllerRepresentable {
        let visibility: Backport<Any>.Visibility

        func makeUIViewController(context: Context) -> Backport.Representable.Controller {
            Controller(visibility: visibility)
        }

        func updateUIViewController(_ controller: Backport.Representable.Controller, context: Context) {
            controller.update(visibility: visibility)
        }
    }
}

@available(iOS 15, *)
private extension Backport.Representable {
    final class Controller: UIViewController {

        var visibility: Backport<Any>.Visibility

        init(visibility: Backport<Any>.Visibility) {
            self.visibility = visibility
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func willMove(toParent parent: UIViewController?) {
            super.willMove(toParent: parent)
            update(visibility: visibility)
        }

        func update(visibility: Backport<Any>.Visibility) {
            self.visibility = visibility

            if let controller = parent?.sheetPresentationController {
                controller.animateChanges {
                    controller.prefersGrabberVisible = visibility == .visible
                    controller.prefersScrollingExpandsWhenScrolledToEdge = true
                }
            }
        }

    }
}
#endif
