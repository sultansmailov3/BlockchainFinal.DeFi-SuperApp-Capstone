import { useAccount, useConnect, useDisconnect, useBalance } from 'wagmi'

function App() {
  const { address, isConnected, chain } = useAccount()
  const { connectors, connect, error } = useConnect()
  const { disconnect } = useDisconnect()
  const { data: balance } = useBalance({ address })

  if (isConnected) {
    return (
      <div style={{ padding: '2rem', fontFamily: 'monospace' }}>
        <h2>Connected</h2>
        <p>Address: {address}</p>
        <p>Network: {chain?.name}</p>
        <p>Balance: {balance ? `${Number(balance.formatted).toFixed(4)} ${balance.symbol}` : '...'}</p>
        <button onClick={() => disconnect()}>Disconnect</button>
      </div>
    )
  }

  return (
    <div style={{ padding: '2rem', fontFamily: 'monospace' }}>
      <h2>Connect Wallet</h2>
      {connectors.map((connector) => (
        <button
          key={connector.uid}
          onClick={() => connect({ connector })}
          style={{ display: 'block', margin: '8px 0' }}
        >
          {connector.name}
        </button>
      ))}
      {error && <p style={{ color: 'red' }}>{error.message}</p>}
    </div>
  )
}

export default App
