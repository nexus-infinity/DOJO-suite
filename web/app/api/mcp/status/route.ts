import { NextResponse } from 'next/server'
import { ALL_MCP_SERVICES } from '@/lib/mcpServices'
import { CHAMBERS, chamberUrl, type ChamberKey } from '@/lib/chambers'

export const dynamic = 'force-dynamic'

type RouteState = 'connected' | 'routed' | 'unreachable' | 'unverified'

interface ServiceStatus {
  id: string
  status: RouteState
  chamberReachable: boolean
  gatewayReachable: boolean | null
  directPort: number | null
  detail: string
}

export async function GET() {
  const chamberStates = await Promise.all(
    (Object.keys(CHAMBERS) as ChamberKey[]).map(async chamber => {
      const reachable = await probe(`${chamberUrl(chamber)}/health`)
      return [chamber, reachable] as const
    })
  )

  const chamberReachability = Object.fromEntries(chamberStates) as Record<ChamberKey, boolean>

  const services = await Promise.all(
    ALL_MCP_SERVICES.map(async service => {
      const chamberReachable = chamberReachability[service.chamber as ChamberKey] ?? false
      const gatewayReachable = service.directPort
        ? await probe(gatewayUrl(service.chamber as ChamberKey, service.directPort))
        : null

      return {
        id: service.id,
        ...resolveStatus(service.id, chamberReachable, gatewayReachable, service.directPort ?? null, service.category),
      } satisfies ServiceStatus
    })
  )

  return NextResponse.json({
    timestamp: new Date().toISOString(),
    services,
    activeRoutes: services.filter(service => service.status === 'connected' || service.status === 'routed').length,
    total: services.length,
  })
}

function gatewayUrl(chamber: ChamberKey, directPort: number) {
  return `${chamberUrl(chamber).replace(/:\d+$/, '')}:${directPort}/health`
}

function resolveStatus(
  id: string,
  chamberReachable: boolean,
  gatewayReachable: boolean | null,
  directPort: number | null,
  category: 'field-tier2' | 'third-party'
): Omit<ServiceStatus, 'id'> {
  if (category === 'field-tier2') {
    if (gatewayReachable) {
      return {
        status: 'connected',
        chamberReachable,
        gatewayReachable,
        directPort,
        detail: 'Gateway online through sacred chamber ownership.',
      }
    }

    if (chamberReachable) {
      return {
        status: 'routed',
        chamberReachable,
        gatewayReachable,
        directPort,
        detail: 'Chamber route is alive; no dedicated Tier 2 gateway is currently exposed.',
      }
    }

    return {
      status: 'unreachable',
      chamberReachable,
      gatewayReachable,
      directPort,
      detail: 'Routing chamber is unreachable.',
    }
  }

  if (id === 'filesystem') {
    return {
      status: chamberReachable ? 'routed' : 'unreachable',
      chamberReachable,
      gatewayReachable,
      directPort,
      detail: chamberReachable
        ? 'Available through FIELD server-side routing only.'
        : 'Archive/routing chamber is unreachable.',
    }
  }

  return {
    status: chamberReachable ? 'unverified' : 'unreachable',
    chamberReachable,
    gatewayReachable,
    directPort,
    detail: chamberReachable
      ? 'Routing chamber is alive; external capability is not directly instrumented from this surface.'
      : 'Routing chamber is unreachable.',
  }
}

async function probe(url: string) {
  const controller = new AbortController()
  const timeout = setTimeout(() => controller.abort(), 900)

  try {
    const res = await fetch(url, { signal: controller.signal, cache: 'no-store' })
    return res.ok
  } catch {
    return false
  } finally {
    clearTimeout(timeout)
  }
}
