import { OpenAI } from 'openai'

const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY })

export async function tagFile(fileContent: string): Promise<string[]> {
  const response = await openai.chat.completions.create({
    model: "gpt-4",
    messages: [
      { role: "system", content: "You are a file tagging assistant. Generate relevant tags for the given file content." },
      { role: "user", content: `Generate tags for this file content: ${fileContent}` }
    ],
    max_tokens: 50
  })

  return response.choices[0].message.content.split(',').map(tag => tag.trim())
}

export async function analyzeRelationships(files: { name: string, content: string }[]): Promise<any> {
  const fileDescriptions = files.map(file => `${file.name}: ${file.content}`).join('\n')
  
  const response = await openai.chat.completions.create({
    model: "gpt-4",
    messages: [
      { role: "system", content: "You are a file relationship analyzer. Analyze the relationships between the given files." },
      { role: "user", content: `Analyze relationships between these files:\n${fileDescriptions}` }
    ],
    max_tokens: 200
  })

  return JSON.parse(response.choices[0].message.content)
}