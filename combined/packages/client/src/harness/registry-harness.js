import "../components/page-panel.js";
import "../components/page-body.js";
import "../components/action-card.js";
import "../components/account-widget.js";
import "../components/text-widget.js";
import "../components/number-widget.js";
import "../components/switch-widget.js";
import "../components/array-widget.js"
import "../components/dictionary-widget.js"

import DappLib from "@decentology/dappstarter-dapplib";
import { LitElement, html, customElement, property } from "lit-element";

@customElement('registry-harness')
export default class RegistryHarness extends LitElement {
    @property()
    title;
    @property()
    category;
    @property()
    description;

    createRenderRoot() {
        return this;
    }

    constructor(args) {
        super(args);
    }

    render() {
        let content = html`
    <page-body title="${this.title}" category="${this.category}" description="${this.description}">
    
        <action-card title="Register Contract" description="Register a new contract with the Hyperverse Registry"
            action="RegisterContract" method="post" fields="signer convention address name">
            <account-widget field="signer" label="Signer">
            </account-widget>
            <text-widget field="convention" label="Convention" placeholder="[Creator].[Category].[Contract name]">
            </text-widget>
            <text-widget field="address" label="Address" placeholder="0x12345678910">
            </text-widget>
            <text-widget field="name" label="Contract Name" placeholder="SimpleNFT">
            </text-widget>
        </action-card>
    
        <action-card title="Retrieve Contract"
            description="Retrieve a contract from the Hyperverse Registry by its convention" action="RetrieveContract"
            method="get" fields="convention">
            <text-widget field="convention" label="Convention" placeholder="[Creator].[Category].[Contract name]">
            </text-widget>
        </action-card>
    
    </page-body>
    <page-panel id="resultPanel"></page-panel>
    `;

        return content;
    }
}
