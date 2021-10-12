import FlowToken from "../Flow/FlowToken.cdc"
import FungibleToken from "../Flow/FungibleToken.cdc"

pub contract HyperverseService {

    pub var totalTenants: UInt64

    // Named Paths
    //
    pub let AuthStoragePath: StoragePath
    pub let AuthPrivatePath: PrivatePath

    pub resource interface IAuthNFT {
        pub let address: Address
    }

    // AuthNFT
    // The AuthNFT exists so an owner of a DappContract
    // can "register" with this HyperverseService contract in order
    // to use contracts that exist within the Hyperverse.
    //
    // In order to call paid functions that may or may not exist
    // within Hyperverse contracts, you must have an AuthNFT.
    //
    // This will only need to be acquired one time.
    //
    pub resource AuthNFT: IAuthNFT {
        pub let address: Address

        // The FlowToken Vault of the DappContract.
        // This is the vault that will be charged upon
        // calling charge().
        pub let flowTokenVault: Capability<&FlowToken.Vault>

        init(_address: Address, _flowTokenVault: Capability<&FlowToken.Vault>) {
            self.address = _address
            self.flowTokenVault = _flowTokenVault
        }

        // *(HyperverseService.currentHyperverseFee/(10000.0 as UFix64)
    }

    // register
    // register gets called by someone who has never registered with 
    // HyperverseService before.
    //
    // It returns a AuthNFT with a FlowToken vault that is passed in
    // as a parameter.
    //
    pub fun register(flowTokenVault: Capability<&FlowToken.Vault>): @AuthNFT {        
        assert(flowTokenVault.borrow() != nil, message: "This is not a correct FlowToken Vault Capability")
        return <- create AuthNFT(_address: flowTokenVault.borrow()!.owner!.address, _flowTokenVault: flowTokenVault)
    }

    init() {
        self.totalTenants = 0
        self.AuthStoragePath = /storage/HyperverseServiceAuthNFT
        self.AuthPrivatePath = /private/HyperverseServiceAuthNFT
    }
}