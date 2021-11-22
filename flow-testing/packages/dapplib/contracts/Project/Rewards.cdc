import IHyperverseComposable from "../Hyperverse/IHyperverseComposable.cdc"
import HyperverseModule from "../Hyperverse/HyperverseModule.cdc"
import SimpleNFT from "./SimpleNFT.cdc"
import HyperverseAuth from "../Hyperverse/HyperverseAuth.cdc"
import Registry from "../Hyperverse/Registry.cdc"

pub contract Rewards: IHyperverseComposable {

    /**************************************** TENANT ****************************************/

    pub event TenantCreated(tenant: Address)
    
    access(contract) var tenants: @{Address: IHyperverseComposable.Tenant}
    access(contract) fun getTenant(tenant: Address): &Tenant {
        let ref = &self.tenants[tenant] as auth &IHyperverseComposable.Tenant
        return ref as! &Tenant
    }
    pub fun tenantExists(tenant: Address): Bool {
        return self.tenants[tenant] != nil
    }
    
    pub resource Tenant: IHyperverseComposable.ITenant {
        pub var holder: Address

        pub(set) var recipients: {Address: Bool}
        pub let numForReward: Int

        init(_holder: Address, _numForReward: Int) {
            self.holder = _holder
            self.recipients = {}
            self.numForReward = _numForReward
        }
    }

    pub fun createTenant(auth: &HyperverseAuth.Auth, numForReward: Int) {
        let tenant = auth.owner!.address
        
        /* Dependencies */
        if !SimpleNFT.tenantExists(tenant: tenant) {
            SimpleNFT.createTenant(auth: auth)                   
        }

        self.tenants[tenant] <-! create Tenant(_holder: tenant, _numForReward: numForReward)

        emit TenantCreated(tenant: tenant)
    }

    /**************************************** BUNDLE ****************************************/

    pub let BundleStoragePath: StoragePath
    pub let BundlePrivatePath: PrivatePath
    pub let BundlePublicPath: PublicPath

    pub resource interface PublicBundle {
       access(contract) fun getMinterInContract(tenant: Address): &SimpleNFT.NFTMinter
    }

    // We don't need aliases in this Bundle
    pub resource Bundle: PublicBundle {
        pub let auth: Capability<&HyperverseAuth.Auth>

        access(contract) fun getMinterInContract(tenant: Address): &SimpleNFT.NFTMinter {
            let bundle: &SimpleNFT.Bundle = self.auth.borrow()!.getBundle(bundleName: SimpleNFT.getType().identifier) as! &SimpleNFT.Bundle
            return bundle.borrowMinter(tenant: tenant)
        }

        init(_auth: Capability<&HyperverseAuth.Auth>) {
            self.auth = _auth
        }
    }

    pub fun getBundle(auth: Capability<&HyperverseAuth.Auth>): @Bundle {
        return <- create Bundle(_auth: auth)
    }

    /**************************************** FUNCTIONALITY ****************************************/

    pub event RewardsInitialized()

    pub fun giveReward(tenant: Address, minterBundle: &Bundle{PublicBundle}, recipientBundle: &Bundle{PublicBundle}) {
        let state = self.getTenant(tenant: tenant)
        if state.recipients[recipientBundle.owner!.address] == true {
            panic("This recipient has already received a reward!")
        }
        
        let simpleNFTBundle = getAccount(recipientBundle.owner!.address).getCapability(SimpleNFT.BundlePublicPath)
                                .borrow<&SimpleNFT.Bundle{SimpleNFT.PublicBundle}>()
                                ?? panic("Could not get the recipient's SimpleNFT Bundle")
        
        let nftCollection = simpleNFTBundle.borrowCollectionPublic(tenant: tenant)
        let ids = nftCollection.getIDs()
        if ids.length >= state.numForReward {
            let nftMinter = minterBundle.getMinterInContract(tenant: tenant)
            nftCollection.deposit(token: <- nftMinter.mintNFT(metadata: {"name": "Super Legendary Reward"}))
            state.recipients[recipientBundle.owner!.address] = true
        } else {
            panic("Sorry! This account needs more NFTs to get a Reward!")
        }
    }
    
    init() {
        self.tenants <- {}

        self.BundleStoragePath = /storage/RewardsBundle
        self.BundlePrivatePath = /private/RewardsBundle
        self.BundlePublicPath = /public/RewardsBundle

        Registry.registerContract(
            proposer: self.account.borrow<&HyperverseAuth.Auth>(from: HyperverseAuth.AuthStoragePath)!, 
            metadata: HyperverseModule.ModuleMetadata(
                _identifier: self.getType().identifier,
                _contractAddress: self.account.address,
                _title: "Rewards", 
                _authors: [HyperverseModule.Author(_address: 0x26a365de6d6237cd, _externalURI: "https://www.decentology.com/")], 
                _version: "0.0.1", 
                _publishedAt: getCurrentBlock().timestamp,
                _externalURI: "",
                _secondaryModules: [{(Address(0x26a365de6d6237cd)): "SimpleNFT"}]
            )
        )

        emit RewardsInitialized()
    }
}