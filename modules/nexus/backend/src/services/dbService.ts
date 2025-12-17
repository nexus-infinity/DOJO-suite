import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

export async function saveFile(name: string, path: string, tags: string[]): Promise<void> {
  await prisma.file.create({
    data: { name, path, tags }
  })
}

export async function getFiles(): Promise<any[]> {
  return prisma.file.findMany()
}

export async function saveRelationship(fileId1: string, fileId2: string, type: string, strength: number): Promise<void> {
  await prisma.relationship.create({
    data: { fileId1, fileId2, type, strength }
  })
}

export async function getRelationships(): Promise<any[]> {
  return prisma.relationship.findMany()
}