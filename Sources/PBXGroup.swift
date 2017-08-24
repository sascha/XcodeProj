import Foundation
import Unbox

public class PBXGroup: PBXObject, Hashable {

    // MARK: - Attributes

    /// Element children.
    public var children: [String]

    /// Element name.
    public var name: String?

    /// Element path.
    public var path: String?

    /// Element source tree.
    public var sourceTree: PBXSourceTree

    // MARK: - Init

    /// Initializes the group with its attributes.
    ///
    /// - Parameters:
    ///   - reference: element reference.
    ///   - children: group children.
    ///   - sourceTree: group source tree.
    ///   - name: group name.
    ///   - path: group path.
    public init(reference: String,
                children: [String],
                sourceTree: PBXSourceTree,
                name: String? = nil,
                path: String? = nil) {
        self.children = children
        self.name = name
        self.sourceTree = sourceTree
        self.path = path
        super.init(reference: reference)
    }

    public static func == (lhs: PBXGroup,
                           rhs: PBXGroup) -> Bool {
        return lhs.reference == rhs.reference &&
            lhs.children == rhs.children &&
            lhs.name == rhs.name &&
            lhs.sourceTree == rhs.sourceTree &&
            lhs.path == rhs.path
    }

    public override init(reference: String, dictionary: [String: Any]) throws {
        let unboxer = Unboxer(dictionary: dictionary)
        self.children = try unboxer.unbox(key: "children")
        self.name = unboxer.unbox(key: "name")
        self.sourceTree = try unboxer.unbox(key: "sourceTree")
        self.path = unboxer.unbox(key: "path")
        try super.init(reference: reference, dictionary: dictionary)
    }
}

// MARK: - PBXGroup Extension (PlistSerializable)

extension PBXGroup: PlistSerializable {

    func plistKeyAndValue(proj: PBXProj) -> (key: CommentedString, value: PlistValue) {
        var dictionary: [CommentedString: PlistValue] = [:]
        dictionary["isa"] = .string(CommentedString(PBXGroup.isa))
        dictionary["children"] = .array(children.map({ (fileReference) -> PlistValue in
            let comment = name(reference: fileReference, proj: proj)
            return .string(CommentedString(fileReference, comment: comment))
        }))
        if let name = name {
            dictionary["name"] = .string(CommentedString(name))
        }
        if let path = path {
            dictionary["path"] = .string(CommentedString(path))
        }
        dictionary["sourceTree"] = sourceTree.plist()
        return (key: CommentedString(self.reference,
                                                 comment: self.name ?? self.path),
                value: .dictionary(dictionary))
    }

    fileprivate func name(reference: String, proj: PBXProj) -> String? {
        let group = proj.groups.filter({ $0.reference == reference }).first
        let variantGroup = proj.variantGroups.filter({ $0.reference == reference }).first
        let file = proj.fileReferences.filter({ $0.reference == reference }).first
        if let group = group {
            return group.name ?? group.path
        } else if let variantGroup = variantGroup {
            return variantGroup.name
        } else if let file = file {
            return file.name ?? file.path
        }
        return nil
    }

}
