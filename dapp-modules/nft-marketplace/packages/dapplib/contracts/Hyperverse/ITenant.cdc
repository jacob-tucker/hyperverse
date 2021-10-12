import HyperverseService from "./HyperverseService.cdc"

pub contract interface ITenant {

    pub resource interface ITenantID {
        pub let id: UInt64
    }

    pub resource interface ITenantAuth {
        pub let id: UInt64
    }

    pub resource Tenant: ITenantID, ITenantAuth {
        pub let id: UInt64

        pub let authNFT: Capability<&HyperverseService.AuthNFT>
    }

}