import fs from 'fs/promises'
import path from 'path'

const UPLOAD_DIR = path.join(process.cwd(), 'uploads')

export async function saveFile(file: Express.Multer.File): Promise<string> {
  await fs.mkdir(UPLOAD_DIR, { recursive: true })
  const fileName = `${Date.now()}-${file.originalname}`
  const filePath = path.join(UPLOAD_DIR, fileName)
  await fs.writeFile(filePath, file.buffer)
  return fileName
}

export async function getFile(fileName: string): Promise<Buffer> {
  const filePath = path.join(UPLOAD_DIR, fileName)
  return fs.readFile(filePath)
}