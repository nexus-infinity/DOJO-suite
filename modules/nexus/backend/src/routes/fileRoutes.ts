import express, { Request } from 'express'
import multer from 'multer'
import * as fileService from '../services/fileService'
import * as aiService from '../services/aiService'
import * as dbService from '../services/dbService'
import { File as MulterFile } from 'multer'

const router = express.Router()
const upload = multer({ storage: multer.memoryStorage() })
router.post('/upload', upload.single('file'), async (req: Request & { file?: MulterFile }, res) => {
  try {
    const file = req.file
    if (!file) {
      return res.status(400).json({ error: 'No file uploaded' })
    }

    const fileName = await fileService.saveFile(file)
    const fileContent = file.buffer.toString()
    const tags = await aiService.tagFile(fileContent)
    await dbService.saveFile(file.originalname, fileName, tags)

    res.json({ message: 'File uploaded successfully', fileName, tags })
  } catch (error) {
    res.status(500).json({ error: 'Error uploading file' })
  }
})

router.get('/files', async (req, res) => {
  try {
    const files = await dbService.getFiles()
    res.json(files)
  } catch (error) {
    res.status(500).json({ error: 'Error retrieving files' })
  }
})

router.post('/analyze-relationships', async (req, res) => {
  try {
    const { files } = req.body
    const relationships = await aiService.analyzeRelationships(files)
    
    for (const relationship of relationships) {
      await dbService.saveRelationship(
        relationship.file1,
        relationship.file2,
        relationship.relationshipType,
        relationship.strength
      )
    }

    res.json(relationships)
  } catch (error) {
    res.status(500).json({ error: 'Error analyzing relationships' })
  }
})

export default router