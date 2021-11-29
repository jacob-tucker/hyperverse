import IHyperverseComposable from "../Hyperverse/IHyperverseComposable.cdc"
import HyperverseModule from "../Hyperverse/HyperverseModule.cdc"
import HyperverseAuth from "../Hyperverse/HyperverseAuth.cdc"
import Registry from "../Hyperverse/Registry.cdc"

pub contract Tribes: IHyperverseComposable {

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
        pub let tenantID: Address
        pub var holder: Address

        pub(set) var tribes: {String: TribeData}
        pub(set) var participants: {Address: Bool}

        init(_tenant: Address, _holder: Address) {
            self.tenantID = _tenant
            self.holder = _holder
            self.tribes = {}
            self.participants = {}
        }
    }

    pub fun createTenant(auth: &HyperverseAuth.Auth) {
        let tenant = auth.owner!.address
        
        self.tenants[tenant] <-! create Tenant(_tenant: tenant, _holder: tenant)
        
        let bundle = auth.bundles[self.getType().identifier]!.borrow()! as! &Bundle
        bundle.depositAdmin(Admin: <- create Admin(tenant))
        
        emit TenantCreated(tenant: tenant)
    }

    /**************************************** BUNDLE ****************************************/

    pub let BundleStoragePath: StoragePath
    pub let BundlePrivatePath: PrivatePath
    pub let BundlePublicPath: PublicPath

    pub resource interface PublicBundle {
        pub fun borrowIdentityPublic(tenant: Address): &Identity{IdentityPublic}
    }
   
    pub resource Bundle: PublicBundle {
        pub var identities: @{Address: Identity}
        pub var admins: @{Address: Admin}

        pub fun borrowIdentity(tenant: Address): &Identity {
            if self.identities[tenant] == nil {
                self.identities[tenant] <-! create Identity(tenant, _address: self.owner!.address)
            }
            return &self.identities[tenant] as &Identity
        }
        pub fun borrowIdentityPublic(tenant: Address): &Identity{IdentityPublic} {
            return self.borrowIdentity(tenant: tenant)
        }

        pub fun depositAdmin(Admin: @Admin) {
            self.admins[Admin.tenant] <-! Admin
        }
        pub fun borrowAdmin(tenant: Address): &Admin {
            return &self.admins[tenant] as &Admin
        }

        init() {
            self.identities <- {}
            self.admins <- {}
        }

        destroy() {
            destroy self.identities
            destroy self.admins
        }
    }

    pub fun getBundle(): @Bundle {
        return <- create Bundle()
    }

    /**************************************** FUNCTIONALITY ****************************************/

    pub event TribesContractInitialized()

    pub resource Admin {
        pub let tenant: Address
        pub fun addNewTribe(newTribeName: String, ipfsHash: String, description: String) {
            let state = Tribes.getTenant(tenant: self.tenant)
            state.tribes[newTribeName] = TribeData(_ipfsHash: ipfsHash, _description: description)
        }

        init(_ tenant: Address) {
            self.tenant = tenant
        }
    }

    pub fun joinTribe(identity: &Identity, tribe: String) {
        pre {
            self.getAllTribes(tenant: identity.tenant)[tribe] != nil:
                "This Tribe does not exist!"
        }
        let state = Tribes.getTenant(tenant: identity.tenant)
        
        let member = identity.address
        assert(state.participants[member] == nil || !state.participants[member]!, message: "Member already belongs to a Tribe!")
        
        state.tribes[tribe]!.addMember(member: member)
        state.participants[member] = true
        
        identity.addTribe(newTribe: <- create Tribe(_name: tribe))
    }
    
    pub fun leaveTribe(identity: &Identity) {
        let currentTribe = identity.currentTribeName!
        let member = identity.address
        let state = Tribes.getTenant(tenant: identity.tenant)

        assert(state.participants[member]!, message: "Member does not belong to a Tribe!")
        state.tribes[currentTribe]!.removeMember(member: member)
        state.participants[member] = false
        
        identity.removeTribe()
    }


    pub resource interface IdentityPublic {
        pub let address: Address
        pub var currentTribeName: String?
    }

    pub resource Identity: IdentityPublic {
        pub let tenant: Address
        pub let address: Address
        pub var currentTribe: @Tribe?
        pub var currentTribeName: String?

        access(contract) fun addTribe(newTribe: @Tribe) {
            self.currentTribeName = newTribe.name

            let oldTribe <- self.currentTribe <- newTribe
            destroy oldTribe
        }

        access(contract) fun removeTribe() {
            self.currentTribeName = nil

            let oldTribe <- self.currentTribe <- nil
            destroy oldTribe
        }

        init(_ tenant: Address, _address: Address) {
            self.tenant = tenant
            self.address = _address
            self.currentTribe <- nil
            self.currentTribeName = nil
        }

        destroy() {
            destroy self.currentTribe
        }
    }

    pub struct TribeData {

        pub let ipfsHash: String

        pub var description: String

        access(contract) var members: {Address: Bool}

        pub fun getMembers(): [Address] {
            return self.members.keys
        }

        access(contract) fun addMember(member: Address) {
            self.members[member] = true
        }

        access(contract) fun removeMember(member: Address) {
            self.members.remove(key: member)
        }

        init(_ipfsHash: String, _description: String) {
            self.ipfsHash = _ipfsHash
            self.members = {}
            self.description = _description
        }
    }
    
    pub resource Tribe {
        pub let name: String

        pub let joinDate: UFix64

        init(_name: String) {
            self.name = _name 
            self.joinDate = getCurrentBlock().timestamp
        }
    }

    pub fun getAllTribes(tenant: Address): {String: TribeData} {
        return self.getTenant(tenant: tenant).tribes
    }

    pub fun getTribeData(tenant: Address, tribeName: String): TribeData {
        return self.getTenant(tenant: tenant).tribes[tribeName]!
    }

    init() {
        self.tenants <- {}

        self.BundleStoragePath = /storage/TribesBundle
        self.BundlePrivatePath = /private/TribesBundle
        self.BundlePublicPath = /public/TribesBundle

        Registry.registerContract(
            proposer: self.account.borrow<&HyperverseAuth.Auth>(from: HyperverseAuth.AuthStoragePath)!, 
            metadata: HyperverseModule.ModuleMetadata(
                _identifier: self.getType().identifier,
                _contractAddress: self.account.address,
                _title: "Tribes", 
                _authors: [HyperverseModule.Author(_address: 0x26a365de6d6237cd, _externalLink: "https://www.decentology.com/")], 
                _version: "0.0.1", 
                _publishedAt: getCurrentBlock().timestamp,
                _externalUri: "",
                _secondaryModules: nil
            )
        )

        emit TribesContractInitialized()
    }
}