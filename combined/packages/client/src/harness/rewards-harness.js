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

@customElement('rewards-harness')
export default class RewardsHarness extends LitElement {
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
      
        <action-card title="Rewards - Instance" description="Instance" action="RewardsInstance" method="post" fields="signer">
          <account-widget field="signer tenantIDs" label="Signer">
          </account-widget>
          <dictionary-widget field="tenantIDs" label="Tenant IDs" objectLabel="Tenant ID" keyplaceholder="Contract"
            valueplaceholder="ID">
          </dictionary-widget>
        </action-card>
      
        <action-card title="Rewards - Owns Tenant" description="Owns the Rewards Tenant" action="RewardsOwnsTenant"
          method="get" fields="tenantOwner">
          <account-widget field="tenantOwner" label="Tenant Owner">
          </account-widget>
        </action-card>
      
        <action-card title="Rewards - Mint NFT" description="Mint NFT" action="RewardsMintNFT" method="post"
          fields="tenantID tenantOwner recipient">
          <text-widget field="tenantID" label="Tenant ID" placeholder="0x1cf0e2f2f715450.49">
          </text-widget>
          <account-widget field="tenantOwner" label="Tenant Owner">
          </account-widget>
          <account-widget field="recipient" label="Recipient">
          </account-widget>
        </action-card>
      
        <action-card title="Rewards - Give Reward" description="Give Reward" action="RewardsGiveReward" method="post"
          fields="tenantID tenantOwner signer">
          <text-widget field="tenantID" label="Tenant ID" placeholder="0x1cf0e2f2f715450.49">
          </text-widget>
          <account-widget field="tenantOwner" label="Tenant Owner">
          </account-widget>
          <account-widget field="signer" label="Signer">
          </account-widget>
        </action-card>
      
        <action-card title="Rewards - Get NFT IDs" description="Get NFT IDs" action="SimpleNFTGetNFTIDs" method="get"
          fields="account tenantID">
          <text-widget field="tenantID" label="Tenant ID" placeholder="0x1cf0e2f2f715450.49">
          </text-widget>
          <account-widget field="account" label="Account">
          </account-widget>
        </action-card>
      
      </page-body>
      <page-panel id="resultPanel"></page-panel>
    `;

    return content;
  }
}
