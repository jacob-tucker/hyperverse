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
      
        <action-card title="Tribes - Instance" description="Instance. **You need a Tribes.Package to do this. **"
          action="TribesInstance" method="post" fields="signer">
          <account-widget field="signer" label="Signer">
          </account-widget>
        </action-card>
      
        <action-card title="Tribes - Get Client Tenants" description="Get all your Tenant IDs" action="TribesGetClientTenants"
          method="get" fields="account">
          <account-widget field="account" label="Account">
          </account-widget>
        </action-card>
      
        <action-card title="Tribes - Add a New Tribe"
          description="Add a new Tribe. ** 'Recipient' MUST have a Tribes.Admin for the specified tenantID**"
          action="TribesAddTribe" method="post" fields="tenantOwner newTribeName">
          <account-widget field="tenantOwner" label="Tenant Address">
          </account-widget>
          <text-widget field="newTribeName" label="Tribe Name" placeholder="Archers">
          </text-widget>
        </action-card>
      
        <action-card title="Tribes - Join a Tribe"
          description="Join a Tribe and add the Tribe's resource to your Identity. ** 'Recipient' MUST have a Tribes.Package and Setup their Package**"
          action="TribesJoinTribe" method="post" fields="tenantOwner signer tribeName">
          <account-widget field="tenantOwner" label="Tenant Owner">
          </account-widget>
          <account-widget field="signer" label="Identity Owner">
          </account-widget>
          <text-widget field="tribeName" label="Tribe Name" placeholder="Archers">
          </text-widget>
        </action-card>
      
        <action-card title="Tribes - Leave Your Tribe"
          description="Leave your current Tribe and remove the Tribe's resource from your Identity. ** 'Signer' MUST be a part of a Tribe already.**"
          action="TribesLeaveTribe" method="post" fields="tenantOwner signer">
          <account-widget field="tenantOwner" label="Tenant Owner">
          </account-widget>
          <account-widget field="signer" label="Identity Owner">
          </account-widget>
        </action-card>
      
        <action-card title="Tribes - Get Current Tribe" description="Get Current Tribe" action="TribesGetCurrentTribe"
          method="get" fields="account tenantOwner">
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
