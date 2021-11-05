import React, { useState, useEffect, SyntheticEvent } from 'react';
//@ts-ignore
import DappLib from "@decentology/dappstarter-dapplib";
import archerbow from "./archerbow.png"
import "./tribes.css"

const accounts = DappLib.getAccounts();
let ACCOUNT = {
    "Admin": "0x",
    "Alice": "0x"
}

const TribesPage = (props:any) => {
    const [currentTribe, setCurrentTribe] = useState("")
    const [allTribes, setAllTribes] = useState([])
    const [checkedTribe, setCheckedTribe] = useState(false)
    const [error, setError] = useState(false)

    const getCurrentTribe = async (e: SyntheticEvent) => {
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
        <div className="tribes">
            {error ?
                <div className="error">
                    <h2>Two things could be wrong:</h2>
                    <ul>
                        <li>1) You have not called `instance` for an account in the Tribes module.</li>
                        <li>2) The `tenantOwner` field in `getCurrentTribe` function is not the account you used in the first step.</li>
                    </ul>
                </div> : null}
            {checkedTribe && currentTribe === 'Archers'
                ? <div className="archers-tribe">
                    <h1>Welcome to the Archers Tribe!</h1>
                    <img src={archerbow} alt="" />
                </div>
                : checkedTribe && currentTribe === 'None!'
                    ? <h1 className="no-access">You do not belong to a Tribe.</h1>
                    : checkedTribe && !error
                        ? <h1 className="no-access">You do not have access to Archers.</h1>
                        : !error
                            ? <button className="button-9" onClick={getCurrentTribe}>Look at your Tribe</button>
                            : null}
        </div>
    );

}



export default TribesPage;