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
                self.identities[tenant] <-! create Identity(tenant)
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
            state.tribes[newTribeName] = TribeData(_name: newTribeName, _ipfsHash: ipfsHash, _description: description)
        }

        init(_ tenant: Address) {
            self.tenant = tenant
        }
    }


    pub resource interface IdentityPublic {
        pub var currentTribeName: String?
    }

    pub resource Identity: IdentityPublic {
        pub let tenant: Address
        pub var currentTribeName: String?

        pub fun joinTribe(tribeName: String) {
            pre {
                Tribes.getAllTribes(tenant: self.tenant)[tribeName] != nil:
                    "This Tribe does not exist!"
            }
            let state = Tribes.getTenant(tenant: self.tenant)
            let me = self.owner!.address

            assert(state.participants[me] == nil || !state.participants[me]!, message: "Member already belongs to a Tribe!")
            
            state.tribes[tribeName]!.addMember(member: me)
            state.participants[me] = true
            
            self.currentTribeName = tribeName
        }

        pub fun leaveTribe() {
            let currentTribe = self.currentTribeName ?? panic("You don't belong to a Tribe.")
            let me = self.owner!.address
            let state = Tribes.getTenant(tenant: self.tenant)

            assert(state.participants[me]!, message: "Member does not belong to a Tribe!")
            state.tribes[currentTribe]!.removeMember(member: me)
            state.participants[me] = false
            
            self.currentTribeName = nil
        }

        init(_ tenant: Address) {
            self.tenant = tenant
            self.currentTribeName = nil
        }
    }

    pub struct TribeData {
        pub let name: String
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

        init(_name: String, _ipfsHash: String, _description: String) {
            self.name = _name
            self.ipfsHash = _ipfsHash
            self.members = {}
            self.description = _description
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