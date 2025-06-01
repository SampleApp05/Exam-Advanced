# Soft-Uni-Advanced-Exam

Soft Uni Advanced Course Exam repo

# Installation

NB! For Windows use WSL
NB! Run forge install if needed after cloning

1. Install and run foundryup => curl -L https://foundry.paradigm.xyz | bash. Init a forge project => forge init
2. Install hardhat => npm install --save-dev hardhat. Init a TS project => npx hardhat init
3. Install dependencies => node update.js. Use flag -f/-h to install forge/hardhat only dependencies (common dependencies will be installed in all cases)
4. Add values for the following keys in the .env file
   3.1 SEPOLIA_RPC_URL = https://eth-sepolia.g.alchemy.com/v2/your-key-here;
   3.2 WALLET_PRIVATE_KEY = your-wallet-here;
   3.3 ETHERSCAN_API_KEY = your-key-here;

# Tests

# Deployment

# Contract Addresses

# On Chain Implementation and Tests

func_one => etherscan link
func_two => etherscan link
....

# Dependencies

1.  dotenv => used for env variables
2.  remixd => for easier testing on Sepolia
3.  Foundry:
    3.1 foundry-rs/forge-std;
    3.2 OpenZeppelin/openzeppelin-foundry-upgrades;
    3.3 OpenZeppelin/openzeppelin-contracts-upgradeable;
    3.4 smartcontractkit/chainlink-brownie-contracts
4.  Hardhat
    4.1 @openzeppelin/contracts-upgradeable;
    4.2 chainlink/contracts
