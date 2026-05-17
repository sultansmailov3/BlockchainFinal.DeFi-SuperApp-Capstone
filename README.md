## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

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