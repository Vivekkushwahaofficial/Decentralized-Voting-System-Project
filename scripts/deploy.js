const { ethers } = require("hardhat");

async function main() {
  console.log("🚀 Starting deployment of VotingSystem contract...\n");

  // Get the contract factory
  const VotingSystem = await ethers.getContractFactory("VotingSystem");

  // Election name for the constructor
  const electionName = "Presidential Election 2024";

  console.log("📋 Deployment Details:");
  console.log(`Election Name: ${electionName}`);
  console.log(`Network: ${hre.network.name}`);

  // Get deployer account
  const [deployer] = await ethers.getSigners();
  console.log(`Deployer: ${deployer.address}`);
  console.log(`Balance: ${ethers.utils.formatEther(await deployer.getBalance())} ETH\n`);

  // Deploy the contract
  console.log("⏳ Deploying VotingSystem contract...");
  const votingSystem = await VotingSystem.deploy(electionName);

  // Wait for deployment
  await votingSystem.deployed();

  console.log("✅ VotingSystem deployed successfully!");
  console.log(`📍 Contract Address: ${votingSystem.address}`);
  console.log(`🔗 Transaction Hash: ${votingSystem.deployTransaction.hash}`);
  console.log(`⛽ Gas Used: ${votingSystem.deployTransaction.gasLimit.toString()}`);

  // Verify contract details
  console.log("\n📊 Contract Verification:");
  console.log(`Owner: ${await votingSystem.owner()}`);
  console.log(`Election Name: ${await votingSystem.electionName()}`);
  console.log(`Voting Status: ${await votingSystem.votingOpen() ? "Open" : "Closed"}`);
  console.log(`Total Candidates: ${await votingSystem.candidateCount()}`);
  console.log(`Total Votes: ${await votingSystem.totalVotes()}`);

  // Save deployment info
  const deploymentInfo = {
    network: hre.network.name,
    contractAddress: votingSystem.address,
    transactionHash: votingSystem.deployTransaction.hash,
    electionName: electionName,
    deployer: deployer.address,
    deploymentTime: new Date().toISOString(),
    gasUsed: votingSystem.deployTransaction.gasLimit.toString()
  };

  const fs = require('fs');
  const path = require('path');
  
  // Create deployments directory if it doesn't exist
  const deploymentsDir = path.join(__dirname, '../deployments');
  if (!fs.existsSync(deploymentsDir)) {
    fs.mkdirSync(deploymentsDir);
  }

  // Save deployment info to file
  const deploymentFile = path.join(deploymentsDir, `${hre.network.name}_deployment.json`);
  fs.writeFileSync(deploymentFile, JSON.stringify(deploymentInfo, null, 2));

  console.log(`\n💾 Deployment info saved to: ${deploymentFile}`);
  console.log("\n🎉 Deployment completed successfully!");
  console.log("\n📝 Next Steps:");
  console.log("1. Add candidates using addCandidate() function");
  console.log("2. Register voters using registerVoter() function");
  console.log("3. Start voting using startVoting() function");
  console.log("4. Monitor voting and get results using getWinner() function");
}

// Execute deployment
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ Deployment failed:", error);
    process.exit(1);
  });
