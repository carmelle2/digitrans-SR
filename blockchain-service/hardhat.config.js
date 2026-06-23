require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.20",
  networks: {
    // Réseau local pour le développement et les tests
    localhost: {
      url: "http://127.0.0.1:8545"
    },
    // Configuration pour le réseau privé EVM déployé sur AWS ECS
    aws: {
      url: process.env.AWS_BLOCKCHAIN_NODE_URL || "",
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : []
    }
  }
};
