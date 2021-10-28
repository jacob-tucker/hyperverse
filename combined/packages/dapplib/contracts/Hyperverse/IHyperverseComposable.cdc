pub contract interface IHyperverseComposable {

    pub event TenantCreated(id: String)

    access(contract) var clientTenants: {Address: [String]}
    pub fun getClientTenants(account: Address): [String]

    pub resource interface ITenant {
        pub var holder: Address
    }

    pub resource Tenant: ITenant {
        pub var holder: Address
    }

    pub resource Package {
        pub fun setup(tenantID: String)
        // `instance` takes in a tenantID that represents the `uuid`
        // of a Package.
    }
}
