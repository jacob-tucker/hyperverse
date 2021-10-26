
const EC = require('elliptic').ec;
const ec = new EC("p256")
const rlp = require('rlp');
const fcl = require('@onflow/fcl');
const t = require('@onflow/types');
const { Signer } = require('./signer.js');
class Flow {

    static get Roles() {
        return {
            'PROPOSER': 'proposer',
            'AUTHORIZER': 'authorizer',
            'AUTHORIZERS': 'authorizers',
            'PAYER': 'payer',
            'ALL': 'all',
        }
    }

    /**
      config {
      httpUri: "...",
       serviceWallet: {
            "address": "...",
            "keys": [
                {
                "publicKey": "...",
                "privateKey": "...",
                "keyId": 0,
                "weight": 1000
                }  
            ]
       }
     } 
     */
    constructor(config) {
        this.serviceUri = config.httpUri;
        this.serviceWallet = config.serviceWallet;
        this.testMode = config.testMode || false;
    }

    /* API */
    /**
      keyInfo { 
          entropy: byte array, 
          weight: 1 ... 1000 
      }
    */

    /* INTERACTIONS */

    async getAccount(address) {
        let accountInfo = await fcl.send([fcl.getAccount(address)], { node: this.serviceUri });
        // Changed to indexOf instead of comparison because fcl returns 0x prefixed address
        // when previously it didn't have the prefix
        if (accountInfo.account.address.indexOf(address) < 0) {
            throw new Error(`Account 0x${address} does not exist`);
        }
        return accountInfo.account;
    }

    async executeTransaction(tx, options) {
        if (options.decode === true) {
            let resultData = await this._processTransaction(tx, options);
            return fcl.decode(resultData);
        } else {
            let response = await this._processTransaction(tx, options);
            let { events } = await fcl.tx(response).onceSealed();
            return {
                response,
                events
            }
        }
    }

    /* HELPERS */

    static _genKeyPair(entropy, weight) {
        const keys = ec.genKeyPair({
            entropy
        })
        const privateKey = keys.getPrivate("hex")
        const publicKey = keys.getPublic("hex").replace(/^04/, "")
        return {
            publicKey,
            privateKey,
            // Require rlp encoded value of publicKey that encodes the key itself, 
            // what curve it uses, how the signed values are hashed and the keys weight.
            encodedPublicKey: rlp.encode([
                Buffer.from(publicKey, "hex"), // publicKey hex to binary
                2, // P256 per https://github.com/onflow/flow/blob/master/docs/accounts-and-keys.md#supported-signature--hash-algorithms
                3, // SHA3-256 per https://github.com/onflow/flow/blob/master/docs/accounts-and-keys.md#supported-signature--hash-algorithms
                weight
            ]).toString("hex")
        }
    }


    /*
        roleInfo 
        {
            [PROPOSER]: address,
            [AUTHORIZERS]: [ address ],
            [PAYER]: address
        }
    */
    async _processTransaction(tx, options) {

        options = options || {};

        let builders = [];

        let debug = null;
        // BUILD INTERACTION

        // Add the actual interaction code
        builders.push(tx);

        // If there are any params, add those here
        if (options.params && Array.isArray(options.params)) {
            let params = [];
            options.params.forEach((param) => {
                params.push(fcl.param(param.value, param.type, param.name));
            });
            builders.push(fcl.params(params));
        }

        // If there are any args, add those here
        if (options.args && Array.isArray(options.args)) {
            let args = [];
            options.args.forEach((arg) => {
                args.push(fcl.arg(arg.value, arg.type));
            });
            builders.push(fcl.args(args));
        }

        if (options.gasLimit && options.gasLimit > 0) {
            builders.push(fcl.limit(options.gasLimit));
        }

        // If the transaction is going to change state, it will require roleInfo to be populated
        if (options.roleInfo) {
            builders.push(fcl.proposer(fcl.authz));
            builders.push(fcl.authorizations([fcl.authz]));
            builders.push(fcl.payer(fcl.authz));
        }
        fcl.config().put("accessNode.api", this.serviceUri);


        // try {
        //     const response = await fcl.serialize(builders);
        //     console.log(JSON.stringify(JSON.parse(response), null, 2))

        // }
        // catch (e) {
        //     console.log(e)
        // }

        // SEND TRANSACTION TO BLOCKCHAIN

        return await fcl.send(builders, { node: this.serviceUri });



    }

    static getEntropy() {
        let entropy = [];
        for (let e = 0; e < 24; e++) {
            // Minimum 24 bytes needed for entropy
            entropy.push(Math.floor(Math.random() * 254)); // This is totally contrived for test account generation
        }
        return entropy;
    }

}

module.exports = {
    Flow: Flow
}