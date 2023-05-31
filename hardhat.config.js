require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  networks: {
    sepolia:{
      url: "https://eth-sepolia.g.alchemy.com/v2/bL6ciLNodUqbbpGquMWEGr-MmxOuaj0s",
      accounts: [
        "ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80",
      ],
    },
  },
  etherscan:{
    apiKey: "VEVSU5X8G5FUT44NQ2WC3WWNQXCEDMHXTY",
  },
};
