#if canImport(CarPlay)
import CarPlay
import UIKit

/// Compile-time seam for the held CarPlay portal.
///
/// This delegate is intentionally absent from the scene manifest and the app has no
/// CarPlay entitlement. It cannot be connected at runtime until those gates receive
/// a separate device receipt and approval.
final class ParkedCarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didConnect interfaceController: CPInterfaceController
    ) {
        let status = CPListItem(
            text: "DOJO portal parked",
            detailText: "Status only · no navigation or vehicle control"
        )
        let section = CPListSection(items: [status])
        let template = CPListTemplate(title: "DOJO · CarPlay", sections: [section])
        interfaceController.setRootTemplate(template, animated: false, completion: nil)
    }
}
#endif
