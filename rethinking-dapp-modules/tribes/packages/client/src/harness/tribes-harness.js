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

@customElement('tribes-harness')
export default class TribesHarness extends LitElement {
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
      
        <action-card title="Tribes - Get Package" description="Get Package" action="TribesGetPackage" method="post"
          fields="signer">
          <account-widget field="signer" label="Signer">
          </account-widget>
        </action-card>
      
        <action-card title="Tribes - Instance" description="Instance. **You need a Tribes.Package to do this. **"
          action="TribesInstance" method="post" fields="signer">
          <account-widget field="signer" label="Signer">
          </account-widget>
        </action-card>
      
        <action-card title="Tribes - Owns Tenant" description="Owns the Tribes Tenant" action="TribesOwnsTenant" method="get"
          fields="account tenantID">
          <account-widget field="account" label="Account">
          </account-widget>
          <text-widget field="tenantID" label="Tenant" placeholder="0">
          </text-widget>
        </action-card>
      
        <action-card title="Tribes - Setup"
          description="Setting up your Tribes.Package. ** 'Recipient' MUST have a Tribes.Package **" action="TribesSetup"
          method="post" fields="signer tenantID">
          <text-widget field="tenantID" label="Tenant" placeholder="0">
          </text-widget>
          <account-widget field="signer" label="Recipient">
          </account-widget>
        </action-card>
      
        <action-card title="Tribes - Join a Tribe" description="Join a Tribe and add the Tribe's resource to your Identity. ** 'Recipient' MUST have a Tribes.Package 
                                        and Setup their Package**" action="TribesJoinTribe" method="post"
          fields="tenantID signer tribeName">
          <text-widget field="tenantID" label="Tenant" placeholder="0">
          </text-widget>
          <account-widget field="signer" label="Identity Owner">
          </account-widget>
          <text-widget field="tribeName" label="Tribe Name" placeholder="Archers">
          </text-widget>
        </action-card>
      
        <action-card title="Tribes - Leave Your Tribe" description="Leave your current Tribe and remove 
                          the Tribe's resource from your Identity. ** 'Signer' MUST be a part of a Tribe already.**"
          action="TribesLeaveTribe" method="post" fields="tenantID signer">
          <text-widget field="tenantID" label="Tenant" placeholder="0">
          </text-widget>
          <account-widget field="signer" label="Identity Owner">
          </account-widget>
        </action-card>
      
        <action-card title="Tribes - Get Current Tribe" description="Get Current Tribe" action="TribesGetCurrentTribe"
          method="get" fields="account tenantID">
          <text-widget field="tenantID" label="Tenant" placeholder="0">
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
