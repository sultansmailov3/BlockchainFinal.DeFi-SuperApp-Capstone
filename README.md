# DeFi Super-App  Blockchain Technologies 2 Capstone

A production-grade decentralized protocol built on Arbitrum Sepolia L2.
AMM + ERC-4626 Vault + Chainlink Oracles + DAO Governance + The Graph indexing.

## Architecture

| Contract | Description |
|---|---|
| AMM.sol | Constant-product AMM (x*y=k), 0.3% fee, LP tokens, ReentrancyGuard |
| Vault.sol | ERC-4626 tokenized yield vault |
| GovToken.sol | ERC20Votes + ERC20Permit governance token (1M supply) |
| ProtocolGovernor.sol | OpenZeppelin Governor, 4% quorum, 1 week voting period |
| ProtocolTimelock.sol | 2-day timelock for all governance actions |
| PriceOracle.sol | Chainlink price feed wrapper with staleness check (1hr) |
| ProtocolV1.sol | UUPS upgradeable proxy implementation |
| Factory.sol | CREATE + CREATE2 pair factory |

## Quick Start

### Prerequisites
- Foundry
- Node.js 18+
- Python 3.x (for Slither)

### Install

git clone https://github.com/sultansmailov3/BlockchainFinal.DeFi-SuperApp-Capstone
cd BlockchainFinal.DeFi-SuperApp-Capstone
forge install
forge build

### Run Tests

forge test -vvv

### Run Coverage

forge coverage

### Run Slither

pip install slither-analyzer
slither .

### Deploy to Arbitrum Sepolia

cp .env.example .env
# Add your PRIVATE_KEY to .env
forge script script/Deploy.s.sol --rpc-url https://sepolia-rollup.arbitrum.io/rpc --broadcast --verify

## Frontend

cd frontend
npm install
npm run dev

Open http://localhost:5173

## Testing

| Type | Count | Description |
|---|---|---|
| Unit | 14+ | Every public function including revert paths |
| Invariant | 1 | AMM k-invariant never decreases |
| Fuzz | 1 | AMM swap fuzz testing |

forge test -vvv

```shell
$ forge --help
$ anvil --help
$ cast --help
```
## Security & DevOps Work

This project includes additional Security & DevOps work focused on testing, static analysis, CI, and reporting.

### Foundry Testing

The test suite includes:

- Governance lifecycle tests
- ERC20Votes governance token tests
- Timelock access-control tests
- Governance invariant tests
- Ethereum Mainnet fork tests

### Invariant Tests

Governance invariants verify that critical protocol assumptions remain stable:

- GovToken total supply remains constant
- Timelock delay remains 2 days
- Governor voting delay remains 1 day
- Governor voting period remains 1 week
- Governor quorum remains 4%
- Governor keeps proposer and executor roles
- Deployer does not keep admin role

### Fork Tests

Fork tests validate interaction with real Ethereum Mainnet contracts:

- USDC decimals check
- USDC total supply check
- Chainlink ETH/USD price feed check

To run fork tests:

```bash
export MAINNET_RPC_URL="YOUR_ETHEREUM_MAINNET_RPC_URL"
forge test --match-path test/Fork.t.sol -vv
CI Pipeline

GitHub Actions CI runs on push and pull request.

The CI pipeline includes:

forge fmt --check
forge build
forge test
forge coverage
Slither static analysis

Fork tests require the repository secret:

MAINNET_RPC_URL
Slither Static Analysis

Slither is configured in CI to fail only on High and Medium severity findings:

slither . --exclude-dependencies --fail-high --fail-medium

A local Slither report is available at:

reports/slither-report.txt
Reports

The following reports are included:

docs/security-audit-report.md
reports/slither-report.txt
reports/gas-report.txt
reports/coverage-report.txt
Security Audit Summary

The audit report documents:

Scope
Methodology
Automated testing
Static analysis results
Findings summary
Governance security review
Timelock security review
Oracle security review
Accepted risks
Recommendations
