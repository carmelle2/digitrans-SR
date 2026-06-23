const hre = require("hardhat");

async function main() {
  console.log("Deploiement du Smart Contract SupplyChainTraceability...");

  const SupplyChain = await hre.ethers.getContractFactory("SupplyChainTraceability");
  
  // Deploy the contract
  const supplyChain = await SupplyChain.deploy();
  await supplyChain.waitForDeployment();

  const address = await supplyChain.getAddress();
  console.log(`SupplyChainTraceability deploye a l'adresse: ${address}`);

  // Configuration initiale de test (Optionnel)
  console.log("Configuration des participants initiaux (Plantation et Usine)...");
  
  // Dans un cas réel, vous passerez les adresses réelles
  // const [admin, plantation, usine] = await hre.ethers.getSigners();
  // await supplyChain.addParticipant(plantation.address, "Plantation Cacao Moungo", "Nkongsamba", 1);
  // await supplyChain.addParticipant(usine.address, "Usine Transformation Douala", "Douala", 2);
  
  console.log("Deploiement et configuration termines avec succes.");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
