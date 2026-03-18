import 'server-only'

import { existsSync, readFileSync } from 'node:fs'

const HF_API_BASE = 'https://huggingface.co/api'
const DEFAULT_HF_USER = 'misterJB'
const IMPLEMENTATION_REGISTRY_PATH = '/Users/field/IMPLEMENTATION_REGISTRY.yaml'
const HF_TOKEN_PATH = '/Users/field/.cache/huggingface/token'

export interface HuggingFaceTrainingStatus {
  user: string
  jobId: string
  monitorUrl: string
  outputRepo: string | null
  stage: string
  statusLabel: string
  createdAt: string | null
  updatedAt: string | null
  flavor: string | null
  baseModel: string | null
  logsTail: string[]
  raw: Record<string, unknown>
}

interface RegistryJobRef {
  jobId: string
  outputRepo: string | null
  flavor: string | null
  baseModel: string | null
}

export async function getNaimaTrainingStatus(jobId?: string) {
  const registryRef = readNaimaRegistryReference()
  const resolvedJobId = jobId ?? registryRef?.jobId
  if (!resolvedJobId) {
    throw new Error('No Naima job ID found in IMPLEMENTATION_REGISTRY.yaml')
  }

  const token = resolveHfToken()
  const user = DEFAULT_HF_USER
  const headers = {
    Authorization: `Bearer ${token}`,
    Accept: 'application/json',
  }

  const jobResponse = await fetch(`${HF_API_BASE}/jobs/${user}/${resolvedJobId}`, {
    headers,
    cache: 'no-store',
  })

  if (!jobResponse.ok) {
    throw new Error(`Hugging Face job lookup failed: HTTP ${jobResponse.status}`)
  }

  const raw = await jobResponse.json() as Record<string, unknown>
  const logsTail = await fetchLogsTail(user, resolvedJobId, headers)
  const rawStatus = asObject(raw.status)
  const rawCreatedAt = asString(raw.createdAt) ?? asString(raw.created_at) ?? null
  const rawUpdatedAt = asString(raw.updatedAt) ?? asString(raw.updated_at) ?? null
  const stage = asString(rawStatus.stage) ?? asString(raw.stage) ?? 'UNKNOWN'
  const outputRepo =
    registryRef?.outputRepo ??
    asString(raw.outputRepo) ??
    asString(raw.output_repo) ??
    asString(asObject(raw.config).hub_model_id) ??
    null

  return {
    user,
    jobId: resolvedJobId,
    monitorUrl: `https://huggingface.co/${user}/jobs/${resolvedJobId}`,
    outputRepo,
    stage,
    statusLabel: asString(rawStatus.message) ?? asString(rawStatus.state) ?? stage,
    createdAt: rawCreatedAt,
    updatedAt: rawUpdatedAt,
    flavor: registryRef?.flavor ?? asString(raw.flavor) ?? null,
    baseModel: registryRef?.baseModel ?? asString(raw.baseModel) ?? asString(raw.base_model) ?? null,
    logsTail,
    raw,
  } satisfies HuggingFaceTrainingStatus
}

export function looksLikeHuggingFaceStatusRequest(message: string) {
  const text = message.toLowerCase()
  const mentionsHf = /\b(hugging ?face|hf|autotrain)\b/.test(text)
  const mentionsNaima = /\b(naima|niama)\b/.test(text)
  const mentionsStatus = /\b(status|training|train|job|progress|logs|monitor|running|complete|completed|failed|error)\b/.test(text)
  return (mentionsNaima && mentionsStatus) || (mentionsHf && mentionsStatus)
}

export function extractJobIdFromMessage(message: string) {
  const match = message.match(/\b([0-9a-f]{24})\b/i)
  return match?.[1] ?? null
}

export function summarizeTrainingStatus(status: HuggingFaceTrainingStatus) {
  const failureHint = deriveFailureHint(status.logsTail)
  const visibleLogs = failureHint ? status.logsTail.filter(line => line.includes(failureHint)).slice(-1) : status.logsTail.slice(-3)
  const lines = [
    `Hugging Face live status for Naima: ${status.stage}.`,
    `Job ID: ${status.jobId}.`,
  ]

  if (status.flavor) lines.push(`Runner: ${status.flavor}.`)
  if (status.baseModel) lines.push(`Base model: ${status.baseModel}.`)
  if (status.outputRepo) lines.push(`Output repo: ${status.outputRepo}.`)
  if (failureHint) lines.push(`Likely failure cause: ${failureHint}.`)
  if (status.updatedAt) lines.push(`Last update: ${status.updatedAt}.`)
  if (visibleLogs.length > 0) {
    lines.push('Recent logs:')
    lines.push(...visibleLogs.map(line => `- ${line}`))
  } else {
    lines.push('Recent logs: none returned by the API.')
  }
  lines.push(`Monitor: ${status.monitorUrl}`)

  return lines.join('\n')
}

function resolveHfToken() {
  const envToken =
    process.env.HF_TOKEN ||
    process.env.HUGGINGFACE_TOKEN ||
    process.env.HUGGING_FACE_HUB_TOKEN

  if (envToken) return envToken
  if (existsSync(HF_TOKEN_PATH)) return readFileSync(HF_TOKEN_PATH, 'utf8').trim()
  throw new Error('No Hugging Face token found in environment or ~/.cache/huggingface/token')
}

async function fetchLogsTail(user: string, jobId: string, headers: Record<string, string>) {
  const response = await fetch(`${HF_API_BASE}/jobs/${user}/${jobId}/logs`, {
    headers,
    cache: 'no-store',
  })

  if (!response.ok) return []
  const body = await response.text()
  const lines = body
    .split('\n')
    .filter(line => line.trim().startsWith('data: '))
    .map(line => line.slice(6).trim())

  const parsed = lines.flatMap(line => {
    try {
      const entry = JSON.parse(line) as Record<string, unknown>
      const data = asString(entry.data)
      const timestamp = asString(entry.timestamp)
      if (!data) return []
      return [`${timestamp ? `${timestamp} ` : ''}${data}`.trim()]
    } catch {
      return []
    }
  })

  return parsed.slice(-8)
}

function readNaimaRegistryReference(): RegistryJobRef | null {
  if (!existsSync(IMPLEMENTATION_REGISTRY_PATH)) return null
  const raw = readFileSync(IMPLEMENTATION_REGISTRY_PATH, 'utf8')
  const blockMatch = raw.match(/naima_training_v5_job:\n([\s\S]*?)(?:\n\S|\n$)/)
  const block = blockMatch?.[1]
  if (!block) return null

  return {
    jobId: captureYamlString(block, 'job_id') ?? '',
    outputRepo: captureYamlString(block, 'output_repo'),
    flavor: captureYamlString(block, 'flavor'),
    baseModel: captureYamlString(block, 'base_model'),
  }
}

function captureYamlString(block: string, key: string) {
  const match = block.match(new RegExp(`^\\s*${key}:\\s*"([^"]+)"`, 'm'))
    ?? block.match(new RegExp(`^\\s*${key}:\\s*([^\\n#]+)`, 'm'))
  return match?.[1]?.trim() ?? null
}

function asObject(value: unknown) {
  return value && typeof value === 'object' && !Array.isArray(value)
    ? value as Record<string, unknown>
    : {}
}

function asString(value: unknown) {
  return typeof value === 'string' ? value : null
}

function deriveFailureHint(logsTail: string[]) {
  const oomLine = logsTail.find(line => /OutOfMemoryError|CUDA out of memory/i.test(line))
  if (oomLine) return oomLine.replace(/^.*?(torch\.OutOfMemoryError: )?/, '').trim()

  const errorLine = [...logsTail].reverse().find(line => /\berror\b|exception|failed/i.test(line))
  return errorLine ? errorLine.trim() : null
}
