import IHyperverseComposable from "./IHyperverseComposable.cdc"

pub contract HyperverseAuth {
    pub var totalAuths: UInt64

    pub let AuthStoragePath: StoragePath
    pub resource Auth {
        pub let id: UInt64

        // String : A.{Address of Contract}.{Contract Name}
        // From getType().identifier on a contract
        pub var packages: {String: Capability<auth &IHyperverseComposable.Package>}
        pub fun addPackage(packageName: String, packageRef: Capability<auth &IHyperverseComposable.Package>) {
            pre {
                packageRef.borrow() != nil: "This is an incorrect capability."
            }
            self.packages[packageName] = packageRef
        }

        init() {
            self.id = HyperverseAuth.totalAuths
            HyperverseAuth.totalAuths = HyperverseAuth.totalAuths + (1 as UInt64)
            self.packages = {}
        }
    }

    pub fun createAuth(): @Auth {
        return <- create Auth()
    }

    init () {
        self.totalAuths = 0
        self.AuthStoragePath = /storage/AuthStoragePath
    }
}