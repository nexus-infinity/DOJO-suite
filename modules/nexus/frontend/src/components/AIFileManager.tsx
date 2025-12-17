'use client'

import { useState } from 'react'
import { useChat } from 'ai/react'
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Card, CardContent } from "@/components/ui/card"

export function AIFileManager() {
  const [files, setFiles] = useState([])
  const { messages, input, handleInputChange, handleSubmit } = useChat()

  const handleFileUpload = (event) => {
    const uploadedFiles = Array.from(event.target.files)
    setFiles([...files, ...uploadedFiles])
  }

  return (
    <Card className="w-full max-w-2xl">
      <CardContent className="p-6">
        <div className="mb-4">
          <Input
            type="file"
            multiple
            onChange={handleFileUpload}
            className="mb-2"
          />
          <ul className="list-disc pl-5">
            {files.map((file, index) => (
              <li key={index} className="text-sm text-gray-600">{file.name}</li>
            ))}
          </ul>
        </div>
        <div className="flex flex-col space-y-4 mb-4">
          {messages.map(m => (
            <div key={m.id} className={`p-4 rounded-lg ${m.role === 'user' ? 'bg-blue-100' : 'bg-green-100'}`}>
              {m.content}
            </div>
          ))}
        </div>
        <form onSubmit={handleSubmit} className="flex gap-2">
          <Input
            className="flex-grow"
            value={input}
            placeholder="Ask about your files..."
            onChange={handleInputChange}
          />
          <Button type="submit">Send</Button>
        </form>
      </CardContent>
    </Card>
  )
}