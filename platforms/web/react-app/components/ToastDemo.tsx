'use client'

import { useState } from 'react'
import { Button } from "@/components/ui/button"
import { useToast } from "@/components/ui/use-toast"

export default function ToastDemo() {
  const { toast } = useToast()
  const [count, setCount] = useState(0)

  const showToast = () => {
    setCount(prevCount => prevCount + 1)
    toast({
      title: "Toast Triggered",
      description: `This toast has been shown ${count + 1} times.`,
    })
  }

  return (
    <div className="p-4">
      <h2 className="text-2xl font-bold mb-4">Toast Demo</h2>
      <Button onClick={showToast}>Show Toast</Button>
    </div>
  )
}