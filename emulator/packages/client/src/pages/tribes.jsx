import React, { useState, useEffect } from 'react';
import DappLib from "@decentology/dappstarter-dapplib";
import { roles } from "../components/account-widget.js";
import archerbow from "./archerbow.png"
import "./tribes.css"

const accounts = DappLib.getAccounts();
let ACCOUNT = {}
for (let i = 0; i < roles.length; i++) {
    ACCOUNT[roles[i]] = accounts[i]
}

const TribesPage = () => {
    const [currentTribe, setCurrentTribe] = useState("")
    const [allTribes, setAllTribes] = useState([])
    const [checkedTribe, setCheckedTribe] = useState(false)
    const [error, setError] = useState(false)

    const getCurrentTribe = async (e) => {
        e.preventDefault()
        let data = {
            tenantOwner: ACCOUNT.Admin,
            account: ACCOUNT.Alice
        }
        try {
            let stuff = await DappLib.TribesGetCurrentTribe(data)
            setCurrentTribe(stuff.result)
            setError(false)
        } catch (e) {
            // This will only happen if you haven't run "instance"
            // for an account under the Tenant module, 
            // and your `tenantOwner` isn't that same account.
            setError(true)
        }
        setCheckedTribe(true)
    }

    useEffect(() => {
        getAllTribes()
    }, [])

    const getAllTribes = async () => {

    }

    return (
        <div class="tribes">
            {error ?
                <div class="error">
                    <h2>Two things could be wrong:</h2>
                    <ul>
                        <li>1) You have not called `instance` for an account in the Tribes module.</li>
                        <li>2) The `tenantOwner` field in `getCurrentTribe` function is not the account you used in the first step.</li>
                    </ul>
                </div> : null}
            {checkedTribe && currentTribe === 'Archers'
                ? <div class="archers-tribe">
                    <h1>Welcome to the Archers Tribe!</h1>
                    <img src={archerbow} />
                </div>
                : checkedTribe && currentTribe === 'None!'
                    ? <h1 class="no-access">You do not belong to a Tribe.</h1>
                    : checkedTribe && !error
                        ? <h1 class="no-access">You do not have access to Archers.</h1>
                        : !error
                            ? <button class="button-9" role="button" onClick={getCurrentTribe}>Look at your Tribe</button>
                            : null}
        </div>
    );

}

export default TribesPage;