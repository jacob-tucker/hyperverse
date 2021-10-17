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
      
        <action-card title="SimpleFT - Instance" description="Instance" action="SimpleFTInstance" method="post"
          fields="signer">
          <account-widget field="signer" label="Signer">
          </account-widget>
        </action-card>
      
        <action-card title="SimpleFT - Has Tenant" description="Has SimpleFT Tenant" action="SimpleFTHasTenant" method="get"
          fields="account">
          <account-widget field="account" label="Account">
          </account-widget>
        </action-card>
      
        <action-card title="SimpleFT - Get Package" description="Get Package" action="SimpleFTGetPackage" method="post"
          fields="signer">
          <account-widget field="signer" label="Signer">
          </account-widget>
        </action-card>
      
        <action-card title="SimpleFT - User Setup"
          description="User Setup (Receiving a SimpleFT.Vault). ** 'Recipient' MUST have a SimpleFT.Package **"
          action="SimpleFTUserSetup" method="post" fields="signer tenant">
          <account-widget field="tenant" label="Tenant">
          </account-widget>
          <account-widget field="signer" label="Recipient">
          </account-widget>
        </action-card>
      
        <action-card title="SimpleFT - Give Administrator"
          description="Give Minter (Receiving a SimpleFT.Administrator). ** 'Recipient' MUST have a SimpleFT.Package **"
          action="SimpleFTGiveAdministrator" method="post" fields="signer recipient">
          <account-widget field="signer" label="Tenant">
          </account-widget>
          <account-widget field="recipient" label="Recipient">
          </account-widget>
        </action-card>
      
        <action-card title="SimpleFT - Give Minter"
          description="Give Minter (Receiving a SimpleFT.Minter). ** 'Recipient' MUST have a SimpleFT.Package **"
          action="SimpleFTGiveMinter" method="post" fields="tenant signer recipient">
          <account-widget field="tenant" label="Tenant">
          </account-widget>
          <account-widget field="signer" label="Administrator/Signer">
          </account-widget>
          <account-widget field="recipient" label="Recipient">
          </account-widget>
        </action-card>
      
        <action-card title="SimpleFT - Mint FT" description="Mint FT" action="SimpleFTMintFT" method="post"
          fields="tenant signer recipient amount">
          <account-widget field="tenant" label="Tenant">
          </account-widget>
          <account-widget field="signer" label="FTMinter">
          </account-widget>
          <account-widget field="recipient" label="Recipient">
          </account-widget>
          <text-widget field="amount" label="Amount of FT" placeholder="50">
          </text-widget>
        </action-card>
      
        <action-card title="SimpleFT - Transfer FT" description="Transfer FT" action="SimpleFTTransferFT" method="post"
          fields="tenant signer recipient amount">
          <account-widget field="tenant" label="Tenant">
          </account-widget>
          <account-widget field="signer" label="Signer">
          </account-widget>
          <account-widget field="recipient" label="Recipient">
          </account-widget>
          <text-widget field="amount" label="Amount of FT" placeholder="50">
          </text-widget>
        </action-card>
      
        <action-card title="SimpleFT - Get Balance" description="Get Balance" action="SimpleFTGetBalance" method="get"
          fields="tenant account">
          <account-widget field="tenant" label="Tenant">
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
