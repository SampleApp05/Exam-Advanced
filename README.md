# Soft-Uni-Advanced-Exam

Soft Uni Advanced Course Exam repo

# Repo link

https://github.com/SampleApp05/Exam-Advanced;

# Installation

NB! For Windows use WSL

1. Install and run foundryup => curl -L https://foundry.paradigm.xyz | bash. Init a forge project => forge init if needed;
2. Install hardhat => npm install --save-dev hardhat. Init a TS project => npx hardhat init if needed;
3. Install dependencies => node update.js. Use flag -f/-h to install forge/hardhat only dependencies (common dependencies will be installed in all cases);

# Tests

1. Run "forge test" => local foundry testing (no hardhat test currently);

# Env vars

Populate all of these:

1. SEPOLIA_RPC_URL;
2. PRIMARY_WALLET_PRIVATE_KEY => used for deployments;
3. ETHERSCAN_API_KEY;
4. PRIMARY_WALLET => Sepolia Wallet account to be used as director account;
5. LOGIC_CONTRACT_ADDRESS => after deploying logic contract, needed for factory methods;

# Deployment

1. Logic contract => forge script script/DeployLogic.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIMARY_WALLET_PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY. Use logged address for factory methods;
2. Factory => forge script script/DeployFactory.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIMARY_WALLET_PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY;
3. Build new Merkle tree if needed => edit merkleTreeBuilder.js and run it otherwise use merkle_data.json;
4. Run remixd and use Remix IDE to interact with deployed factory => create a proxy and load it in Remix IDE => use proxy to test functionality (might need to activate remixd plugin in Remix IDE);
   NB! Make sure to run "source .env" before each script to load the correct env vars. Clear remappings when using Remix IDE (delete entries);

# Deployed Addresses

1. Logic => https://sepolia.etherscan.io/address/0xd2053D05e1F943ac9c92605bdA51dA47bf86F8CF;
2. Factory => https://sepolia.etherscan.io/address/0x87B4BC87C7CCD1CF258fa552021B101b2dAE5515;
3. Proxy => https://sepolia.etherscan.io/address/0x841b3063f2fe4c09aa1b469875149fc6ed685b57;

# Sepolia test transactions

1. Create proxy => https://sepolia.etherscan.io/tx/0xc19781dde0cc01ac701217f87f9187bac35523c239bb203c78e49401a642e416;
2. Fund proxy => https://sepolia.etherscan.io/tx/0x7b73adda7c3d4a5626d4b8c63bfe681f6a050b55b396f476974f2930560444c7;
3. Claim Scholarship => https://sepolia.etherscan.io/tx/0x09d7e74f35fda7c0ded1afe1fc5c5ca7bd7309d0d69d44985ed3bae1fa3ddda6
4. Withdraw leftover funds =>

# Dependencies

1.  dotenv => used for env variables;
2.  remixd => for easier testing on Sepolia;
3.  @openzeppelin/merkle-tree => Merkle Tree generation;
4.  Foundry:
    3.1 foundry-rs/forge-std;
    3.2 OpenZeppelin/openzeppelin-foundry-upgrades;
    3.3 OpenZeppelin/openzeppelin-contracts-upgradeable;
    3.4 smartcontractkit/chainlink-brownie-contracts
5.  Hardhat
    4.1 @openzeppelin/contracts-upgradeable;
    4.2 chainlink/contracts;
