usePlugin("@nomiclabs/buidler-waffle");
usePlugin("@nomiclabs/buidler-web3");
require('dotenv').config();
const mnemonic_phrase = process.env.mnemonic

// This is a sample Buidler task. To learn how to create your own go to
// https://buidler.dev/guides/create-task.html

// task("accounts", "Prints the list of accounts", async () => {
//   const accounts = await ethers.getSigners();
//
//   for (const account of accounts) {
//     console.log(await account.getAddress());
//   }
// });

task("accounts", "Prints accounts", async (_, { web3 }) => {
    console.log(await web3.eth.getAccounts());
});

// You have to export an object to set up your config
// This object can have the following optional entries:
// defaultNetwork, networks, solc, and paths.
// Go to https://buidler.dev/config/ to learn more
module.exports = {
    defaultNetwork: "localhost",
    networks: {
        buidlerevm: {
        },
        localhost: {
          url: "http://localhost:8545"
        },
        rinkeby: {
            url: "https://rinkeby.infura.io/v3/"+process.env.infura_id,
            accounts: {mnemonic: mnemonic_phrase}
        },
        main: {
            url: "https://mainnet.infura.io/v3/"+process.env.infura_id,
            accounts: {mnemonic: mnemonic_phrase}
        },
    },
  // This is a sample solc configuration that specifies which version of solc to use
  solc: {
    version: "0.6.8",
    optimizer: {enabled: true, runs: 200},
  },
};
