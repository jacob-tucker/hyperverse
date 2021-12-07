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

        init() {
            self.id = HyperverseAuth.totalAuths
            HyperverseAuth.totalAuths = HyperverseAuth.totalAuths + 1
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