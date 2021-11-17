import IHyperverseComposable from "../Hyperverse/IHyperverseComposable.cdc"
import IHyperverseModule from "../Hyperverse/IHyperverseModule.cdc"
import HyperverseModule from "../Hyperverse/HyperverseModule.cdc"
import SimpleNFT from "./SimpleNFT.cdc"
import HyperverseAuth from "../Hyperverse/HyperverseAuth.cdc"

pub contract Rewards: IHyperverseModule, IHyperverseComposable {

    /**************************************** METADATA ****************************************/

    access(contract) let metadata: HyperverseModule.ModuleMetadata
    pub fun getMetadata(): HyperverseModule.ModuleMetadata {
        return self.metadata
    }

    /**************************************** TENANT ****************************************/

    pub event TenantCreated(id: String)
    access(contract) var clientTenants: {Address: String}
    pub fun getClientTenantID(account: Address): String? {
        return self.clientTenants[account]
    }
    access(contract) var tenants: @{String: IHyperverseComposable.Tenant}
    pub fun getTenant(id: String): &Tenant{IHyperverseComposable.ITenant, IState} {
        let ref = &self.tenants[id] as auth &IHyperverseComposable.Tenant
        return ref as! &Tenant
    }
    access(contract) var aliases: {String: String}
    pub fun addAlias(auth: &HyperverseAuth.Auth, new: String) {
        let original = auth.owner!.address.toString()
                        .concat(".")
                        .concat(self.getType().identifier)

        self.aliases[new] = original
    }

    pub resource interface IState {
       access(contract) var recipients: {Address: Bool}
       access(contract) fun addRecipient(recipient: Address)
       pub let numForReward: Int
    }
    
    pub resource Tenant: IHyperverseComposable.ITenant, IState {
        pub let tenantID: String
        pub var holder: Address

        pub var recipients: {Address: Bool}
        pub fun addRecipient(recipient: Address) {
            self.recipients[recipient] = true
        }
        pub let numForReward: Int

        init(_tenantID: String, _holder: Address, _numForReward: Int) {
            self.tenantID = _tenantID
            self.holder = _holder
            self.recipients = {}
            self.numForReward = _numForReward
        }
    }

    // Modules
    // String : the identifier of the contract
    // UInt64 : The incremented # (from 0) for that account. For example, you want your
    // 2nd Tenant from SimpleNFT, it'd be `1`.
    pub fun instance(auth: &HyperverseAuth.Auth, numForReward: Int) {
        pre {
            self.clientTenants[auth.owner!.address] == nil: "This account already have a Tenant from this contract."
        }

        var STenantID: String = auth.owner!.address.toString()
                                .concat(".")
                                .concat(self.getType().identifier)
        
        /* Dependencies */
        if SimpleNFT.getClientTenantID(account: auth.owner!.address) == nil {
            SimpleNFT.instance(auth: auth)                   
        }
        SimpleNFT.addAlias(auth: auth, new: STenantID)

        self.tenants[STenantID] <-! create Tenant(_tenantID: STenantID, _holder: auth.owner!.address, _numForReward: numForReward)
        self.addAlias(auth: auth, new: STenantID)

        self.clientTenants[auth.owner!.address] = STenantID
        emit TenantCreated(id: STenantID)
    }

    /**************************************** PACKAGE ****************************************/

    pub let PackageStoragePath: StoragePath
    pub let PackagePrivatePath: PrivatePath
    pub let PackagePublicPath: PublicPath

    pub resource interface PackagePublic {
       pub fun SimpleNFTPackagePublic(): &SimpleNFT.Package{SimpleNFT.PackagePublic}

       access(contract) fun getMinterInContract(tenantID: String): &SimpleNFT.NFTMinter
    }

    // We don't need aliases in this Package
    pub resource Package: PackagePublic {
        pub let dependencies: {String: Capability<auth &IHyperverseComposable.Package>}
        pub fun SimpleNFTPackagePublic(): &SimpleNFT.Package{SimpleNFT.PackagePublic} {
            let package = self.dependencies[SimpleNFT.getType().identifier]!.borrow()!
            let ref: &SimpleNFT.Package = package as! &SimpleNFT.Package
            return ref
        }

        access(contract) fun getMinterInContract(tenantID: String): &SimpleNFT.NFTMinter {
            let package = self.dependencies[SimpleNFT.getType().identifier]!.borrow()!
            let ref: &SimpleNFT.Package = package as! &SimpleNFT.Package
            return ref.borrowMinter(tenantID: tenantID)
        }

        init(_auth: &HyperverseAuth.Auth) {
            self.dependencies = {}
            self.dependencies[SimpleNFT.getType().identifier] = _auth.getPackage(packageName: SimpleNFT.getType().identifier)
        }
    }

    pub fun getPackage(auth: &HyperverseAuth.Auth): @Package {
        return <- create Package(_auth: auth)
    }

    /**************************************** FUNCTIONALITY ****************************************/

    pub event RewardsInitialized()

    pub fun giveReward(tenantID: String, minterPackage: &Package{PackagePublic}, recipientPackage: &Package{PackagePublic}) {
        let TenantState = self.getTenant(id: tenantID)
        if TenantState.recipients[recipientPackage.owner!.address] == true {
            panic("This recipient has already received a reward!")
        }
        // Proof that we need alias at the contract level so we can do that here wait nvm LUL
        let nftCollection = recipientPackage.SimpleNFTPackagePublic().borrowCollectionPublic(tenantID: tenantID)
        let ids = nftCollection.getIDs()
        if ids.length >= TenantState.numForReward {
            let nftMinter = minterPackage.getMinterInContract(tenantID: tenantID)
            nftCollection.deposit(token: <- nftMinter.mintNFT(metadata: {"name": "Super Legendary Reward"}))
            TenantState.addRecipient(recipient: recipientPackage.owner!.address)
        } else {
            panic("Sorry! This account needs more NFTs to get a Reward!")
        }
    }
    
    init() {
        self.clientTenants = {}
        self.tenants <- {}
        self.aliases = {}

        self.PackageStoragePath = /storage/RewardsPackage
        self.PackagePrivatePath = /private/RewardsPackage
        self.PackagePublicPath = /public/RewardsPackage

        self.metadata = HyperverseModule.ModuleMetadata(
            _title: "Rewards", 
            _authors: [HyperverseModule.Author(_address: 0x26a365de6d6237cd, _externalURI: "https://www.decentology.com/")], 
            _version: "0.0.1", 
            _publishedAt: getCurrentBlock().timestamp,
            _externalURI: "",
            _secondaryModules: [{(Address(0x26a365de6d6237cd)): "SimpleNFT"}]
        )

        emit RewardsInitialized()
    }
}