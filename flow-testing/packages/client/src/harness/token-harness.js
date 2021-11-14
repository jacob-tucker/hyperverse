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

@customElement('token-harness')
export default class TokenHarness extends LitElement {
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
      
        <action-card title="SimpleToken - Instance" description="Create your own Tenant" action="SimpleTokenInstance"
          method="post" fields="signer">
          <account-widget field="signer" label="Signer">
          </account-widget>
        </action-card>
      
        <action-card title="SimpleToken - Get Client Tenants" description="SimpleToken TenantID for this account"
          action="SimpleTokenGetClientTenants" method="get" fields="account">
          <account-widget field="account" label="Account">
          </account-widget>
        </action-card>
      
        <action-card title="SimpleToken - Give Minter" description="Give Minter" action="SimpleTokenGiveMinter" method="post"
          fields="tenantOwner recipient">
          <account-widget field="tenantOwner" label="Tenant Owner">
          </account-widget>
          <account-widget field="recipient" label="Recipient">
          </account-widget>
        </action-card>
      
        <action-card title="SimpleToken - Mint FT" description="Mint FT" action="SimpleTokenMintFT" method="post"
          fields="tenantOwner signer recipient amount">
          <account-widget field="tenantOwner" label="Tenant Owner">
          </account-widget>
          <account-widget field="signer" label="FTMinter">
          </account-widget>
          <account-widget field="recipient" label="Recipient">
          </account-widget>
          <text-widget field="amount" label="Amount of FT" placeholder="50.0">
          </text-widget>
        </action-card>
      
        <action-card title="SimpleToken - Transfer FT" description="Transfer FT" action="SimpleTokenTransferFT" method="post"
          fields="tenantOwner signer recipient amount">
          <account-widget field="tenantOwner" label="Tenant Owner">
          </account-widget>
          <account-widget field="signer" label="Signer">
          </account-widget>
          <account-widget field="recipient" label="Recipient">
          </account-widget>
          <text-widget field="amount" label="Amount of FT" placeholder="50">
          </text-widget>
        </action-card>
      
        <action-card title="SimpleToken - Get Balance" description="Get Balance" action="SimpleTokenGetBalance" method="get"
          fields="tenantOwner account">
          <account-widget field="tenantOwner" label="Tenant Owner">
          </account-widget>
          <account-widget field="account" label="Account">
          </account-widget>
        </action-card>
      
      </page-body>
      <page-panel id="resultPanel"></page-panel>
    `;

    return content;
  }
}
