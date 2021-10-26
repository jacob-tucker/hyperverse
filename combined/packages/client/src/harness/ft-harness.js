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

@customElement('ft-harness')
export default class FTHarness extends LitElement {
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
      
        <action-card title="SimpleFT - Instance" description="Instance. **You need a SimpleFT.Package to do this. **"
          action="SimpleFTInstance" method="post" fields="signer">
          <account-widget field="signer" label="Signer">
          </account-widget>
        </action-card>
      
        <action-card title="SimpleFT - Owns Tenant" description="Owns the SimpleFT Tenant" action="SimpleFTOwnsTenant"
          method="get" fields="tenantOwner">
          <account-widget field="tenantOwner" label="Tenant Owner">
          </account-widget>
        </action-card>
      
        <action-card title="SimpleFT - User Setup"
          description="Setting up your SimpleFT.Package. ** 'Recipient' MUST have a SimpleFT.Package **"
          action="SimpleFTSetup" method="post" fields="tenantID signer">
          <text-widget field="tenantID" label="Tenant ID" placeholder="0x1cf0e2f2f715450.49">
          </text-widget>
          <account-widget field="signer" label="Recipient">
          </account-widget>
        </action-card>
      
        <action-card title="SimpleFT - Give Minter"
          description="Give Minter (Receiving a SimpleFT.Minter). ** 'Recipient' MUST have a SimpleFT.Package **"
          action="SimpleFTGiveMinter" method="post" fields="tenantID tenantOwner recipient">
          <text-widget field="tenantID" label="Tenant ID" placeholder="0x1cf0e2f2f715450.49">
          </text-widget>
          <account-widget field="tenantOwner" label="Tenant Owner">
          </account-widget>
          <account-widget field="recipient" label="Recipient">
          </account-widget>
        </action-card>
      
        <action-card title="SimpleFT - Mint FT" description="Mint FT" action="SimpleFTMintFT" method="post"
          fields="tenantID signer recipient amount">
          <text-widget field="tenantID" label="Tenant ID" placeholder="0x1cf0e2f2f715450.49">
          </text-widget>
          <account-widget field="signer" label="FTMinter">
          </account-widget>
          <account-widget field="recipient" label="Recipient">
          </account-widget>
          <text-widget field="amount" label="Amount of FT" placeholder="50">
          </text-widget>
        </action-card>
      
        <action-card title="SimpleFT - Transfer FT" description="Transfer FT" action="SimpleFTTransferFT" method="post"
          fields="tenantID signer recipient amount">
          <text-widget field="tenantID" label="Tenant ID" placeholder="0x1cf0e2f2f715450.49">
          </text-widget>
          <account-widget field="signer" label="Signer">
          </account-widget>
          <account-widget field="recipient" label="Recipient">
          </account-widget>
          <text-widget field="amount" label="Amount of FT" placeholder="50">
          </text-widget>
        </action-card>
      
        <action-card title="SimpleFT - Get Balance" description="Get Balance" action="SimpleFTGetBalance" method="get"
          fields="tenantID account">
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
