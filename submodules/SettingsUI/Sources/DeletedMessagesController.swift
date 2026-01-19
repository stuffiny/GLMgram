import Foundation
import UIKit
import Display
import SwiftSignalKit
import TelegramCore
import Postbox
import TelegramPresentationData
import ItemListUI
import AccountContext

// MARK: - Entry Definition

private enum DeletedMessagesSection: Int32 {
    case settings
}

private enum DeletedMessagesEntry: ItemListNodeEntry {
    case enableToggle(PresentationTheme, String, Bool)
    case archiveMediaToggle(PresentationTheme, String, Bool)
    case settingsInfo(PresentationTheme, String)
    
    var section: ItemListSectionId {
        return DeletedMessagesSection.settings.rawValue
    }
    
    var stableId: Int32 {
        switch self {
        case .enableToggle:
            return 0
        case .archiveMediaToggle:
            return 1
        case .settingsInfo:
            return 2
        }
    }
    
    static func ==(lhs: DeletedMessagesEntry, rhs: DeletedMessagesEntry) -> Bool {
        switch lhs {
        case let .enableToggle(lhsTheme, lhsText, lhsValue):
            if case let .enableToggle(rhsTheme, rhsText, rhsValue) = rhs,
               lhsTheme === rhsTheme, lhsText == rhsText, lhsValue == rhsValue {
                return true
            }
            return false
        case let .archiveMediaToggle(lhsTheme, lhsText, lhsValue):
            if case let .archiveMediaToggle(rhsTheme, rhsText, rhsValue) = rhs,
               lhsTheme === rhsTheme, lhsText == rhsText, lhsValue == rhsValue {
                return true
            }
            return false
        case let .settingsInfo(lhsTheme, lhsText):
            if case let .settingsInfo(rhsTheme, rhsText) = rhs, lhsTheme === rhsTheme, lhsText == rhsText {
                return true
            }
            return false
        }
    }
    
    static func <(lhs: DeletedMessagesEntry, rhs: DeletedMessagesEntry) -> Bool {
        return lhs.stableId < rhs.stableId
    }
    
    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let arguments = arguments as! DeletedMessagesControllerArguments
        switch self {
        case let .enableToggle(_, text, value):
            return ItemListSwitchItem(
                presentationData: presentationData,
                title: text,
                value: value,
                sectionId: self.section,
                style: .blocks,
                updated: { value in
                    arguments.toggleEnabled(value)
                }
            )
        case let .archiveMediaToggle(_, text, value):
            return ItemListSwitchItem(
                presentationData: presentationData,
                title: text,
                value: value,
                sectionId: self.section,
                style: .blocks,
                updated: { value in
                    arguments.toggleArchiveMedia(value)
                }
            )
        case let .settingsInfo(_, text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
        }
    }
}

// MARK: - Arguments

private final class DeletedMessagesControllerArguments {
    let toggleEnabled: (Bool) -> Void
    let toggleArchiveMedia: (Bool) -> Void
    
    init(
        toggleEnabled: @escaping (Bool) -> Void,
        toggleArchiveMedia: @escaping (Bool) -> Void
    ) {
        self.toggleEnabled = toggleEnabled
        self.toggleArchiveMedia = toggleArchiveMedia
    }
}

// MARK: - State

private struct DeletedMessagesControllerState: Equatable {
    var isEnabled: Bool
    var archiveMedia: Bool
    
    static func ==(lhs: DeletedMessagesControllerState, rhs: DeletedMessagesControllerState) -> Bool {
        return lhs.isEnabled == rhs.isEnabled &&
               lhs.archiveMedia == rhs.archiveMedia
    }
}

// MARK: - Entries builder

private func deletedMessagesControllerEntries(
    presentationData: PresentationData,
    state: DeletedMessagesControllerState
) -> [DeletedMessagesEntry] {
    var entries: [DeletedMessagesEntry] = []
    
    entries.append(.enableToggle(presentationData.theme, "Сохранять удалённые сообщения", state.isEnabled))
    entries.append(.archiveMediaToggle(presentationData.theme, "Архивировать медиа", state.archiveMedia))
    entries.append(.settingsInfo(presentationData.theme, "Когда включено, сообщения, удалённые другими пользователями, будут сохраняться локально. Рядом со временем сообщения появится иконка корзины."))
    
    return entries
}

// MARK: - Controller

public func deletedMessagesController(context: AccountContext) -> ViewController {
    let initialState = DeletedMessagesControllerState(
        isEnabled: AntiDeleteManager.shared.isEnabled,
        archiveMedia: AntiDeleteManager.shared.archiveMedia
    )
    
    let statePromise = ValuePromise(initialState, ignoreRepeated: true)
    let stateValue = Atomic(value: initialState)
    let updateState: ((DeletedMessagesControllerState) -> DeletedMessagesControllerState) -> Void = { f in
        statePromise.set(stateValue.modify { f($0) })
    }
    
    let arguments = DeletedMessagesControllerArguments(
        toggleEnabled: { value in
            AntiDeleteManager.shared.isEnabled = value
            updateState { state in
                var state = state
                state.isEnabled = value
                return state
            }
        },
        toggleArchiveMedia: { value in
            AntiDeleteManager.shared.archiveMedia = value
            updateState { state in
                var state = state
                state.archiveMedia = value
                return state
            }
        }
    )
    
    let signal = combineLatest(
        context.sharedContext.presentationData,
        statePromise.get()
    )
    |> map { presentationData, state -> (ItemListControllerState, (ItemListNodeState, Any)) in
        let entries = deletedMessagesControllerEntries(presentationData: presentationData, state: state)
        
        let controllerState = ItemListControllerState(
            presentationData: ItemListPresentationData(presentationData),
            title: .text("Удалённые сообщения"),
            leftNavigationButton: nil,
            rightNavigationButton: nil,
            backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back),
            animateChanges: false
        )
        
        let listState = ItemListNodeState(
            presentationData: ItemListPresentationData(presentationData),
            entries: entries,
            style: .blocks,
            animateChanges: false
        )
        
        return (controllerState, (listState, arguments))
    }
    
    let controller = ItemListController(context: context, state: signal)
    return controller
}
