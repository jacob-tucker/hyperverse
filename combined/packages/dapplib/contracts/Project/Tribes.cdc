import IHyperverseComposable from "../Hyperverse/IHyperverseComposable.cdc"
import IHyperverseModule from "../Hyperverse/IHyperverseModule.cdc"
import HyperverseModule from "../Hyperverse/HyperverseModule.cdc"

pub contract Tribes: IHyperverseModule, IHyperverseComposable {

    /**************************************** METADATA ****************************************/

    access(contract) let metadata: HyperverseModule.ModuleMetadata
    pub fun getMetadata(): HyperverseModule.ModuleMetadata {
        return self.metadata
    }

    /**************************************** TENANT ****************************************/

    pub event TenantCreated(id: String)
    access(contract) var clientTenants: {Address: [String]}
    pub fun getClientTenants(account: Address): [String] {
        return self.clientTenants[account]!
    }
    access(contract) var tenants: @{String: Tenant{IHyperverseComposable.ITenant, IState}}
    pub fun getTenant(id: String): &Tenant{IHyperverseComposable.ITenant, IState} {
        return &self.tenants[id] as &Tenant{IHyperverseComposable.ITenant, IState}
    }

    pub resource interface IState {
        pub let tenantID: String
        access(contract) var participants: {Address: Bool}
        access(contract) var tribes: {String: TribeData}

        access(contract) fun addNewTribe(newTribeName: String)
        access(contract) fun addMember(tribe: String, member: Address)
        access(contract) fun removeMember(currentTribe: String, member: Address)
    }
    
    pub resource Tenant: IHyperverseComposable.ITenant, IState {
        pub let tenantID: String
        pub var holder: Address

        pub var tribes: {String: TribeData}
        pub var participants: {Address: Bool}

        pub fun addNewTribe(newTribeName: String) {
            self.tribes[newTribeName] = TribeData()
        }

        pub fun addMember(tribe: String, member: Address) {
            pre {
                self.participants[member] == nil || !self.participants[member]!:
                    "Member already belongs to a Tribe!"
            }
            self.tribes[tribe]!.addMember(member: member)
            self.participants[member] = true
        }

        pub fun removeMember(currentTribe: String, member: Address) {
            pre {
                self.participants[member]!:
                    "Member does not belong to a Tribe!"
            }
            self.tribes[currentTribe]!.removeMember(member: member)
            self.participants[member] = false
        }

        init(_tenantID: String, _holder: Address) {
            self.tenantID = _tenantID
            self.holder = _holder
            self.tribes = {}
            self.participants = {}
        }
    }

    /**************************************** PACKAGE ****************************************/

    // Named Paths
    //
    pub let PackageStoragePath: StoragePath
    pub let PackagePrivatePath: PrivatePath
    pub let PackagePublicPath: PublicPath

    pub resource interface PackagePublic {
        pub fun borrowIdentityPublic(tenantID: String): &Identity{IdentityPublic}
    }
   
    pub resource Package: PackagePublic {
        pub var identities: @{String: Identity}
        pub var admins: @{String: Admin}

        pub fun instance(tenantID: UInt64) {
            var tenantID: String = self.owner!.address.toString().concat(".").concat(tenantID.toString())
            let newTenant <- create Tenant(_tenantID: tenantID, _holder: self.owner!.address)
            Tribes.tenants[tenantID] <-! newTenant
            self.depositAdmin(Admin: <- create Admin(tenantID))
            emit TenantCreated(id: tenantID)
            
             if Tribes.clientTenants[self.owner!.address] != nil {
                Tribes.clientTenants[self.owner!.address]!.append(tenantID)
            } else {
                Tribes.clientTenants[self.owner!.address] = [tenantID]
            }
        }

        pub fun setup(tenantID: String) {
            self.identities[tenantID] <-! create Identity(tenantID, _address: self.owner!.address)
        }

        pub fun depositAdmin(Admin: @Admin) {
            self.admins[Admin.tenantID] <-! Admin
        }

        pub fun borrowAdmin(tenantID: String): &Admin {
            pre {
                self.admins[tenantID] != nil:
                    "This Package does not have an Admin at this tenantID"
            }
            return &self.admins[tenantID] as &Admin
        }

        pub fun borrowIdentity(tenantID: String): &Identity {
            if self.identities[tenantID] == nil {
                self.setup(tenantID: tenantID)
            }
            return &self.identities[tenantID] as &Identity
        }

        pub fun borrowIdentityPublic(tenantID: String): &Identity{IdentityPublic} {
             if self.identities[tenantID] == nil {
                self.setup(tenantID: tenantID)
            }
            return &self.identities[tenantID] as &Identity{IdentityPublic}
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

    pub fun getPackage(): @Package {
        return <- create Package()
    }

    /**************************************** FUNCTIONALITY ****************************************/

    pub event TribesContractInitialized()

    pub resource Admin {
        pub let tenantID: String
        pub fun addNewTribe(newTribeName: String) {
            Tribes.getTenant(id: self.tenantID).addNewTribe(newTribeName: newTribeName)
        }

        init(_ tenantID: String) {
            self.tenantID = tenantID
        }
    }

    pub fun joinTribe(identity: &Identity, tribe: String) {
        pre {
            Tribes.getTenant(id: identity.tenantID).tribes.keys.contains(tribe):
                "This Tribe does not exist!"
        }
        Tribes.getTenant(id: identity.tenantID).addMember(tribe: tribe, member: identity.address)
        identity.addTribe(newTribe: <- create Tribe(_name: tribe))
    }
    
    pub fun leaveTribe(identity: &Identity) {
        Tribes.getTenant(id: identity.tenantID).removeMember(currentTribe: identity.currentTribeName!, member: identity.address)
        identity.removeTribe()
    }


    pub resource interface IdentityPublic {
        pub let address: Address
        pub var currentTribeName: String?
    }

    pub resource Identity: IdentityPublic {
        pub let tenantID: String
        pub let address: Address
        pub var currentTribe: @Tribe?
        pub var currentTribeName: String?

        access(contract) fun addTribe(newTribe: @Tribe) {
            self.currentTribeName = newTribe.name

            log(newTribe.name)
            log(self.currentTribeName)

            let oldTribe <- self.currentTribe <- newTribe
            destroy oldTribe
        }

        access(contract) fun removeTribe() {
            self.currentTribeName = nil

            let oldTribe <- self.currentTribe <- nil
            destroy oldTribe
        }

        init(_ tenantID: String, _address: Address) {
            self.tenantID = tenantID
            self.address = _address
            self.currentTribe <- nil
            self.currentTribeName = nil
        }

        destroy() {
            destroy self.currentTribe
        }
    }

    pub struct TribeData {

        pub var members: {Address: Bool}

        pub fun addMember(member: Address) {
            self.members[member] = true
        }

        pub fun removeMember(member: Address) {
            self.members.remove(key: member)
        }

        init() {
            self.members = {}
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

    init() {
        /* For Secondary Export */
        self.clientTenants = {}
        self.tenants <- {}

        // Set our named paths
        self.PackageStoragePath = /storage/TribesPackage
        self.PackagePrivatePath = /private/TribesPackage
        self.PackagePublicPath = /public/TribesPackage

        self.metadata = HyperverseModule.ModuleMetadata(
            _title: "Tribes", 
            _authors: [HyperverseModule.Author(_address: 0xe37a242dfff69bbc, _externalLink: "https://www.decentology.com/")], 
            _version: "0.0.1", 
            _publishedAt: getCurrentBlock().timestamp,
            _externalUri: "",
            _secondaryModules: nil
        )

        emit TribesContractInitialized()
    }
}