import { BigInt } from '@graphprotocol/graph-ts'
import { Swap as SwapEvent, LiquidityAdded } from '../generated/AMM/AMM'
import { Swap, LiquidityPosition } from '../generated/schema'

export function handleSwap(event: SwapEvent): void {
  let id = event.transaction.hash.toHex() + '-' + event.logIndex.toString()
  let swap = new Swap(id)
  swap.sender = event.params.sender
  swap.amountIn = event.params.amountIn
  swap.amountOut = event.params.amountOut
  swap.timestamp = event.block.timestamp
  swap.blockNumber = event.block.number
  swap.save()
}

export function handleLiquidityAdded(event: LiquidityAdded): void {
  let id = event.params.provider.toHex()
  let position = LiquidityPosition.load(id)
  if (!position) {
    position = new LiquidityPosition(id)
    position.provider = event.params.provider
    position.liquidity = BigInt.fromI32(0)
  }
  position.liquidity = position.liquidity.plus(event.params.amount0)
  position.timestamp = event.block.timestamp
  position.save()
}
