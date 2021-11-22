import IHyperverseComposable from "./IHyperverseComposable.cdc"

pub contract HyperverseAuth {
    pub var totalAuths: UInt64

    pub let AuthStoragePath: StoragePath
    pub let AuthPrivatePath: PrivatePath
    pub let AuthPublicPath: PublicPath

    pub resource interface IAuth {
        pub let id: UInt64
    }
    pub resource Auth: IAuth {
        pub let id: UInt64

        // String : A.{Address of Contract}.{Contract Name}
        // From getType().identifier on a contract
        pub var bundles: {String: Capability<auth &IHyperverseComposable.Bundle>}
        pub fun getBundle(bundleName: String): auth &IHyperverseComposable.Bundle {
            return self.bundles[bundleName]!.borrow()!
        }
        pub fun addBundle(bundleName: String, bundle: Capability<auth &IHyperverseComposable.Bundle>) {
            pre {
                bundle.borrow() != nil: "This is an incorrect capability."
            }
            self.bundles[bundleName] = bundle
        }

        init() {
            self.id = HyperverseAuth.totalAuths
            HyperverseAuth.totalAuths = HyperverseAuth.totalAuths + 1
            self.bundles = {}
        }
    }

    pub fun createAuth(): @Auth {
        return <- create Auth()
    }

    init () {
        self.totalAuths = 0
        self.AuthStoragePath = /storage/AuthStoragePath
        self.AuthPrivatePath = /private/AuthPrivatePath
        self.AuthPublicPath = /public/AuthPublicPath
    }
}