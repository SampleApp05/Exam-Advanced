# Soft-Uni-Advanced-Exam

Soft Uni Advanced Course Exam repo

# Repo link

https://github.com/SampleApp05/Exam-Advanced;

# Installation

**NB! For Windows use WSL**

1. Install and run foundryup => `curl -L https://foundry.paradigm.xyz | bash`.
2. Init a forge project => `forge init` if needed;
3. Install hardhat => `npm install --save-dev hardhat`.
4. Init a TS project => `npx hardhat init` if needed;
5. Install dependencies => `node update.js.` **Use flag -f/-h (no flag for all)** to install forge/hardhat only dependencies (common dependencies will be installed in all cases);

# Tests

1. Run `forge test` => local foundry testing (no hardhat tests currently);

# Env vars

Create and `.env` file and populate **all** of these in t:

1. **SEPOLIA_RPC_URL**;
2. **PRIMARY_WALLET_PRIVATE_KEY** => used for deployments;
3. **ETHERSCAN_API_KEY**;
4. **PRIMARY_WALLET** => Sepolia Wallet account to be used as director account;
5. **LOGIC_CONTRACT_ADDRESS** => after deploying logic contract, needed for factory methods;

# Deployment

1. **Deploy Logic Contract**  
   Use Forge to deploy the logic contract. The output address will be used by the factory.
   ```bash
   forge script script/DeployLogic.s.sol \
     --rpc-url $SEPOLIA_RPC_URL \
     --private-key $PRIMARY_WALLET_PRIVATE_KEY \
     --broadcast \
     --verify \
     --etherscan-api-key $ETHERSCAN_API_KEY
   ```
2. **Deploy Factory Contract**
   ```bash
   forge script script/DeployFactory.s.sol \
    --rpc-url $SEPOLIA_RPC_URL \
    --private-key $PRIMARY_WALLET_PRIVATE_KEY \
    --broadcast \
    --verify \
    --etherscan-api-key $ETHERSCAN_API_KEY
   ```
3. **Build new Merkle tree** (if needed)
   edit `merkleTreeBuilder.js` and run it otherwise use `merkle_data.json`;

# Interact with Contracts via Remix

1. Run `remixd` in your project directory;
2. Open Remix IDE and enable the Remixd plugin;
3. In Remix:

- Load the deployed Factory contract using its address.
- Call the function to create a proxy (dispenser). **ETH/USD price feed address `0x694AA1769357215DE4FAC081bf1f309aDC325306`.**
- Copy the proxy address from the logs or transaction receipt and use it to access the actual instance
- **NB!** Make sure to run `source .env` before each script to load the correct env vars. **Clear remappings when using Remix IDE (delete entries)**;

# Deployed Addresses

1. Logic => https://sepolia.etherscan.io/address/0xd2053D05e1F943ac9c92605bdA51dA47bf86F8CF;
2. Factory => https://sepolia.etherscan.io/address/0x87B4BC87C7CCD1CF258fa552021B101b2dAE5515;
3. Proxy => https://sepolia.etherscan.io/address/0x841b3063f2fe4c09aa1b469875149fc6ed685b57;

# Sepolia testnet transactions

1. Deploy Logic Template contract:

- https://sepolia.etherscan.io/tx/0xc58b4d64f9df1657d30fcb1e3210591df8de50ac9aa85e4a73a1baaf931db260;

2. Deploy Factory contract:

- https://sepolia.etherscan.io/tx/0xc22c27df00648bb32f3cf27203d90b3eb2c42d3752ae70aa65a444e31b5b59da;

3. Create proxy:

- https://sepolia.etherscan.io/tx/0xc19781dde0cc01ac701217f87f9187bac35523c239bb203c78e49401a642e416;

4. Fund proxy:

- https://sepolia.etherscan.io/tx/0x7b73adda7c3d4a5626d4b8c63bfe681f6a050b55b396f476974f2930560444c7;

5. Claim Scholarship

- https://sepolia.etherscan.io/tx/0x09d7e74f35fda7c0ded1afe1fc5c5ca7bd7309d0d69d44985ed3bae1fa3ddda6

6. Withdraw leftover funds

- https://sepolia.etherscan.io/tx/0x4d6a58179fde24fa2d560ff38984dd63c36f310a79135da1c3146018c76abc3b

# Dependencies

1. **dotenv** – Used for environment variables.
2. **remixd** – For easier testing on Sepolia.
3. **@openzeppelin/merkle-tree** – Merkle Tree generation.
4. **Foundry**
   - `foundry-rs/forge-std`
   - `OpenZeppelin/openzeppelin-foundry-upgrades`
   - `OpenZeppelin/openzeppelin-contracts-upgradeable`
   - `smartcontractkit/chainlink-brownie-contracts`
5. **Hardhat**
   - `@openzeppelin/contracts-upgradeable`
   - `chainlink/contracts`
