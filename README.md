# DeFi Super-App ? Blockchain Technologies 2 Capstone

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

## Security

- Zero High findings in src/ contracts (Slither)
- Zero Medium findings in src/ contracts
- ReentrancyGuard on all AMM state-changing functions
- CEI pattern throughout
- UUPS upgrade protected by onlyOwner (Timelock)
- Chainlink staleness check (3600s max)

Full audit report: docs/audit.md
Slither output: slither-output.txt

## The Graph Subgraph

Indexes: Swap events, LiquidityAdded events, ProposalCreated, VoteCast

Entities: Swap, LiquidityPosition, Proposal, Vote

subgraph/schema.graphql ? entity definitions
subgraph/subgraph.yaml ? data sources
subgraph/src/ ? AssemblyScript mappings

## Governance

1. Delegate voting power: token.delegate(yourAddress)
2. Propose: governor.propose(targets, values, calldatas, description)
3. Vote: governor.castVote(proposalId, 1) after 1 day voting delay
4. Queue: governor.queue(...) after 1 week voting period
5. Execute: governor.execute(...) after 2 day timelock

## Team

| Member | Role |
|---|---|
| Participant 1 | Smart Contract Lead ? AMM, Vault, Factory, Yul assembly |
| Participant 2 | Security and DevOps ? Governance, Testing, CI, Audit |
| Participant 3 | Full-Stack and Integration ? Frontend, Oracle, UUPS, Subgraph, Docs |

## License

MIT
