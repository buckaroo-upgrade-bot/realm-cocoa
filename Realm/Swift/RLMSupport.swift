////////////////////////////////////////////////////////////////////////////
//
// Copyright 2014 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

import Realm

extension RLMRealm {
    @nonobjc public class func schemaVersion(at url: URL, usingEncryptionKey key: Data? = nil) throws -> UInt64 {
        var error: NSError?
        let version = __schemaVersion(at: url, encryptionKey: key, error: &error)
        guard version != RLMNotVersioned else { throw error! }
        return version
    }

#if swift(>=3.2)
    @nonobjc public func resolve<Confined>(reference: RLMThreadSafeReference<Confined>) -> Confined? {
        return __resolve(reference as! RLMThreadSafeReference<RLMThreadConfined>) as! Confined?
    }
#else
    @nonobjc public func resolve<Confined: RLMThreadConfined>(reference: RLMThreadSafeReference<Confined>) -> Confined? {
        return __resolve(reference as! RLMThreadSafeReference<RLMThreadConfined>) as! Confined?
    }
#endif
}

extension RLMObject {
    // Swift query convenience functions
    public class func objects(where predicateFormat: String, _ args: CVarArg...) -> RLMResults<RLMObject> {
        return objects(with: NSPredicate(format: predicateFormat, arguments: getVaList(args)))
    }

    public class func objects(in realm: RLMRealm,
                              where predicateFormat: String,
                              _ args: CVarArg...) -> RLMResults<RLMObject> {
        return objects(in: realm, with: NSPredicate(format: predicateFormat, arguments: getVaList(args)))
    }
}

public struct RLMIterator<T>: IteratorProtocol {
    private var iteratorBase: NSFastEnumerationIterator

    internal init(collection: RLMCollection) {
        iteratorBase = NSFastEnumerationIterator(collection)
    }

    public mutating func next() -> T? {
        return iteratorBase.next() as! T?
    }
}

// Sequence conformance for RLMArray and RLMResults is provided by RLMCollection's
// `makeIterator()` implementation.
extension RLMArray: Sequence {}
extension RLMResults: Sequence {}

extension RLMCollection {
    // Support Sequence-style enumeration
    public func makeIterator() -> RLMIterator<RLMObject> {
        return RLMIterator(collection: self)
    }
}

extension RLMCollection {
    // Swift query convenience functions
    public func indexOfObject(where predicateFormat: String, _ args: CVarArg...) -> UInt {
        return indexOfObject(with: NSPredicate(format: predicateFormat, arguments: getVaList(args)))
    }

    public func objects(where predicateFormat: String, _ args: CVarArg...) -> RLMResults<RLMObject> {
        return objects(with: NSPredicate(format: predicateFormat, arguments: getVaList(args)))
    }
}

extension RLMSyncPermissionResults {
    @nonobjc open func addNotificationBlock(_ block: @escaping RLMPermissionStatusBlock) -> RLMNotificationToken {
        return __addNotificationBlock(block)
    }
}

#if swift(>=3.1)
// Collection conformance for RLMSyncPermissionResults.
extension RLMSyncPermissionResults: RandomAccessCollection {
    public subscript(index: Int) -> RLMSyncPermission {
        return object(at: index)
    }

    public func index(after i: Int) -> Int {
        return i + 1
    }

    public var startIndex: Int {
        return 0
    }

    public var endIndex: Int {
        return count
    }
}
#else
extension RLMSyncPermissionResults {
    /// Return the first permission value in the results, or `nil` if
    /// the results are empty.
    public var first: RLMSyncPermission? {
        return count > 0 ? object(at: 0) : nil
    }

    /// Return the last permission value in the results, or `nil` if
    /// the results are empty.
    public var last: RLMSyncPermission? {
        return count > 0 ? object(at: count - 1) : nil
    }
}

extension RLMSyncPermissionResults: Sequence {
    public struct Iterator: IteratorProtocol {
        private let iteratorBase: NSFastEnumerationIterator

        fileprivate init(results: RLMSyncPermissionResults) {
            iteratorBase = NSFastEnumerationIterator(results)
        }

        public func next() -> RLMSyncPermission? {
            return iteratorBase.next() as! RLMSyncPermission?
        }
    }

    public func makeIterator() -> RLMSyncPermissionResults.Iterator {
        return Iterator(results: self)
    }
}
#endif
