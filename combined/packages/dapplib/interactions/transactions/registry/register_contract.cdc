import Registry from "../../../contracts/Hyperverse/Registry.cdc"

transaction(convention: String, address: Address, name: String) {

    let Headmaster: &Registry.Headmaster
    prepare(signer: AuthAccount) {
        self.Headmaster = signer.borrow<&Registry.Headmaster>(from: /storage/RegistryHeadmaster)
                                ?? panic("Could not get the Headmaster reference from the signer.")
    }

    execute {
        self.Headmaster.registerContract(convention: convention, address: address, name: name, metadata: {})
        log("Registered a new contract with the Hyperverse.")
    }
} 