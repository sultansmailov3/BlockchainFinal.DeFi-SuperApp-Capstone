# DeFi Super-App — Full-Stack Decentralized Protocol

A full-stack decentralized protocol built for the Blockchain Technologies 2 Final Project.

The project combines DeFi primitives, token standards, Chainlink-style oracle integration, DAO governance, upgradeability, The Graph indexing, frontend interaction, security testing, CI, and documentation.

## Project Scenario

**Option A — DeFi Super-App**

The protocol includes:

- Constant-product AMM
- ERC-4626 tokenized vault
- ERC20Votes + ERC20Permit governance token
- ERC-721 protocol NFT
- Chainlink-style price oracle with staleness protection
- OpenZeppelin Governor + Timelock governance
- UUPS upgradeable protocol module
- Factory contract using CREATE and CREATE2
- The Graph subgraph
- React / Vite / Wagmi frontend
- Foundry test suite with unit, fuzz, invariant, and fork tests
- GitHub Actions CI
- Slither static analysis
- Security audit report
- Gas and coverage reports

---

## Repository Structure

```text
src/                 Smart contracts
test/                Foundry tests
script/              Deployment and verification scripts
frontend/            React + Vite + Wagmi frontend dApp
subgraph/            The Graph subgraph configuration
docs/                Architecture, audit, and presentation documents
reports/             Gas, coverage, and Slither reports
deployments/         L2 deployment addresses and explorer links
.github/workflows/   GitHub Actions CI


---

## Documentation

Main documentation files:

---

## Documentation

Main documentation files:

| Document | Path |
|---|---|
| Architecture Document | `docs/architecture.md` |
| Security Audit Report | `docs/security-audit-report.md` |
| Additional Audit Notes | `docs/audit.md` |
| Gas Report | `reports/gas-report.txt` |
| Coverage Report | `reports/coverage-report.txt` |
| Slither Report | `reports/slither-report.txt` |
| Final Presentation | `docs/final-presentation.pdf` |

---

## How to Run

### Build contracts

```bash
forge build
```

### Run tests

```bash
forge test -vv
```

### Run fast invariant tests

```bash
FOUNDRY_INVARIANT_RUNS=1 FOUNDRY_INVARIANT_DEPTH=1 forge test -vv
```

### Run fork tests

Fork tests require a mainnet RPC URL:

```bash
export MAINNET_RPC_URL="YOUR_MAINNET_RPC_URL"
forge test --match-path test/Fork.t.sol -vv
```

---

## Frontend

Frontend source code is located in:

```text
frontend/
```

Run frontend:

```bash
cd frontend
npm install
npm run build
npm run dev
```

---

## Subgraph

Subgraph files are located in:

```text
subgraph/
```

Important files:

```text
subgraph/subgraph.yaml
subgraph/schema.graphql
subgraph/src/amm.ts
subgraph/src/governor.ts
```

Indexed entities:

- `Swap`
- `LiquidityPosition`
- `Proposal`
- `Vote`

---

## L2 Deployment

Deployment scripts:

```text
script/Deploy.s.sol
script/Verify.s.sol
```

Target network:

```text
Base Sepolia
```

Deployment command:

```bash
source .env

forge script script/Deploy.s.sol:Deploy \
  --rpc-url $BASE_SEPOLIA_RPC \
  --broadcast \
  -vvv
```

Deployment addresses should be stored in:

```text
deployments/base-sepolia.md
```

Current status:

```text
Deployment script is included. Verified L2 addresses must be added after deployment.
```

---

## Final Presentation

Final presentation slide deck:

```text
docs/final-presentation.pdf
```

---

## Final Submission Checklist

- [x] Smart contracts
- [x] AMM
- [x] ERC-4626 Vault
- [x] ERC20Votes + ERC20Permit governance token
- [x] ERC-721 NFT
- [x] Factory with CREATE and CREATE2
- [x] UUPS upgradeability V1 → V2
- [x] Chainlink-style oracle with staleness check
- [x] Governor + Timelock governance
- [x] Unit tests
- [x] Fuzz tests
- [x] Invariant tests
- [x] Fork tests
- [x] 80+ total tests
- [x] Frontend dApp
- [x] The Graph subgraph files
- [x] GitHub Actions CI
- [x] Slither report
- [x] Gas report
- [x] Coverage report
- [x] Security audit report
- [x] Architecture document
- [x] Final presentation PDF
- [ ] L2 verified explorer links

---

## License

MIT