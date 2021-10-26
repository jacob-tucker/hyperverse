const fs = require('fs');
const path = require('path');
const waitOn = require('wait-on');
const spawn = require('cross-spawn');
const fkill = require('fkill');
const walk = require('walkdir');
const toposort = require('toposort');
const { Flow } = require('./flow');
const flowConfig = require('./flow.json');

const NEWLINE = '\n';
const TAB = '\t';
const BLOCK_INTERVAL = 0;
const MODE = {
  DEFAULT: 'default',
  DEPLOY: 'deploy',
  TRANSPILE: 'transpile',
  TEST: 'test',
}
const NETWORK_TESTNET_KEY = 'testnet';
const SCRIPT_NAME = 'rhythm.js';

const mode = process.argv.length > 2 ? process.argv[process.argv.length - 1].toLowerCase() : MODE.DEFAULT;
const chainContracts = {};

const emulator = flowConfig.emulators[mode === MODE.TEST ? MODE.TEST : MODE.DEFAULT];
const serviceAccount = flowConfig.accounts[emulator.serviceAccount];
const httpUriTestnet = 'https://access-testnet.onflow.org';
const serviceWallet = {
  'address': '0x' + serviceAccount.address,
  'keys': [
    {
      'privateKey': serviceAccount.keys,
      'keyId': 0,
      'weight': 1000
    }
  ]
}

// Only fill this in with testnet accounts if you're developing on testnet
const testnetAccounts = ['0xac70648174bc9884', '0xcfd43d231ceee5ab', '0x1', '0x2'];

const dappConfigFile = path.join(__dirname, 'dapp-config.json');

(async () => {
  let accountCount = 5;
  let keyCount = 2;
  let dappConfig = null;
  let pending = false;
  let queue = [];
  let tokens = 1000;

  if ((mode === MODE.DEFAULT) || (mode === MODE.TEST)) {

    // get the already deployed contracts and set chainContracts
    // but only if it has a testnet alias
    Object.keys(flowConfig.contracts).forEach((key) => {
      if (flowConfig.contracts[key].aliases[NETWORK_TESTNET_KEY]) {
        chainContracts[key] = flowConfig.contracts[key].aliases[NETWORK_TESTNET_KEY];
      }
    });

    // Gets rid of dapp-config
    if (fs.existsSync(dappConfigFile)) {
      fs.unlinkSync(dappConfigFile);
    }

    // Empties dappConfig to make a new one
    dappConfig = {
      httpUri: httpUriTestnet,
      accounts: [],
      contracts: chainContracts,
    };

    addTestnetAccounts();

    updateConfiguration();

    spawn('npx', ['watch', `node ${path.join(__dirname, SCRIPT_NAME)} transpile`, 'interactions'], { stdio: 'inherit' });

  } else if (mode === MODE.TRANSPILE) {

    // After all the project contracts are deployed, the call back runs this script file with a watch
    // on the interactions folder and an arg of 'transpile' causing processing to start here

    await transpile();

  }

  // Added function to be able to add testnet accounts
  // for the account widget
  function addTestnetAccounts() {
    for (let i = 0; i < testnetAccounts.length; i++) {
      dappConfig.accounts.push(testnetAccounts[i]);
      console.log(`\n🤖  Account added to dapp-config: ${testnetAccounts[i]}`);
    }
  }

  async function transpile(runTest) {
    if (fs.existsSync(dappConfigFile)) {
      console.log('\n🎛   Transpiling scripts and transactions...');
      dappConfig = JSON.parse(fs.readFileSync(dappConfigFile, 'utf8'));

      let interactionsFolder = path.join(__dirname, '..', '..', 'dapplib', 'interactions');
      let destFolder = __dirname;

      await generate(interactionsFolder, destFolder, 'scripts', dappConfig.contracts);
      await generate(interactionsFolder, destFolder, 'transactions', dappConfig.contracts);
    }
  }


  function updateConfiguration() {
    //Write the configuration file with test and contract accounts for use in the web app dev
    fs.writeFileSync(
      dappConfigFile,
      JSON.stringify(dappConfig, null, '\t'),
      'utf8'
    );
    console.log(
      `\n🚀  Dapp configuration file updated at ${dappConfigFile}`
    );
  }

  async function generate(interactionsFolder, destFolder, type, deployedContracts) {

    return new Promise((resolve, reject) => {
      let isTransaction = type === 'transactions';
      // Outermost class wrapper
      let outSource = '// 🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨' + NEWLINE;
      outSource += '// ⚠️ THIS FILE IS AUTO-GENERATED WHEN packages/dapplib/interactions CHANGES' + NEWLINE;
      outSource += '// DO **** NOT **** MODIFY CODE HERE AS IT WILL BE OVER-WRITTEN' + NEWLINE;
      outSource += '// 🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨' + NEWLINE + NEWLINE;
      outSource += 'const fcl = require("@onflow/fcl");' + NEWLINE + NEWLINE;
      outSource += 'module.exports = class Dapp' + (isTransaction ? 'Transactions' : 'Scripts') + ' {' + NEWLINE;


      // Read the 'scripts' or 'transactions' folder as determined by 'type'
      let sourceFolder = path.join(interactionsFolder, type);
      let emitter = walk(sourceFolder, filePath => { });

      emitter.on('file', filePath => {
        if (filePath.endsWith('.cdc')) {
          let functionName = filePath.replace(sourceFolder + path.sep, '');
          functionName = functionName.split(path.sep).join('_');
          functionName = functionName.split('.')[0];

          let code = fs.readFileSync(filePath, 'utf8');

          // Function name
          outSource += NEWLINE + TAB + 'static ' + functionName + '() {' + NEWLINE;

          // All the code is added into a JS template literal so line breaks
          // are preserved. We also need to inject imports at run-time which 
          // a template literal enables quite easily
          outSource += TAB + TAB + 'return fcl.' + (isTransaction ? 'transaction' : 'script') + '`' + NEWLINE;
          outSource += code;
          outSource += TAB + TAB + '`;';
          outSource += NEWLINE + TAB + '}' + NEWLINE;
        }

      });

      emitter.on('end', () => {
        outSource += NEWLINE + '}' + NEWLINE;

        // Create dapp-*.js output file based on the type
        fs.writeFileSync(path.join(destFolder, 'dapp-' + type + '.js'), outSource, 'utf8')
        console.log(`\n    📑  Transpiled ${type} to dapp-${type}.js`);
        resolve();
      });
    });

  }

})();
