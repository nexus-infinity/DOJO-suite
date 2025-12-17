'use client'

import React, { useState } from 'react'
import { Upload, Check, AlertTriangle, Loader2 } from 'lucide-react'
import { motion, AnimatePresence } from 'framer-motion'
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card"
import { useToast } from "@/components/ui/use-toast"
import { Label } from "@/components/ui/label"
import { Progress } from "@/components/ui/progress"

const EvidenceSubmissionForm: React.FC = () => {
  const [file, setFile] = useState<File | null>(null)
  const [title, setTitle] = useState('')
  const [description, setDescription] = useState('')
  const [location, setLocation] = useState('')
  const [submissionStatus, setSubmissionStatus] = useState<'idle' | 'submitting' | 'success' | 'error'>('idle')
  const [errors, setErrors] = useState<{ [key: string]: string }>({})
  const [uploadProgress, setUploadProgress] = useState(0)
  const { toast } = useToast()

  const handleFileChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    if (event.target.files && event.target.files[0]) {
      setFile(event.target.files[0])
    }
  }

  const validateForm = () => {
    const newErrors: { [key: string]: string } = {}
    if (!title.trim()) newErrors.title = 'Title is required'
    if (!description.trim()) newErrors.description = 'Description is required'
    if (!file) newErrors.file = 'File is required'
    setErrors(newErrors)
    return Object.keys(newErrors).length === 0
  }

  const handleSubmit = async (event: React.FormEvent) => {
    event.preventDefault()
    if (!validateForm()) return

    setSubmissionStatus('submitting')
    setUploadProgress(0)

    // Simulating file upload progress
    const progressInterval = setInterval(() => {
      setUploadProgress((prevProgress) => {
        if (prevProgress >= 95) {
          clearInterval(progressInterval)
          return prevProgress
        }
        return prevProgress + 5
      })
    }, 500)

    try {
      // Simulating API call
      await new Promise(resolve => setTimeout(resolve, 3000))

      setSubmissionStatus('success')
      toast({
        title: "Evidence Submitted",
        description: "Your evidence has been successfully submitted.",
        duration: 5000,
      })
    } catch (error) {
      setSubmissionStatus('error')
      toast({
        title: "Submission Failed",
        description: "There was an error submitting your evidence. Please try again.",
        variant: "destructive",
        duration: 5000,
      })
    } finally {
      clearInterval(progressInterval)
      setUploadProgress(100)
    }
  }

  return (
    <Card className="w-full max-w-2xl mx-auto">
      <CardHeader>
        <CardTitle className="text-2xl font-bold">Submit Evidence</CardTitle>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="title">Title</Label>
            <Input
              id="title"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              className={errors.title ? 'border-red-500' : ''}
            />
            {errors.title && <p className="text-sm text-red-500">{errors.title}</p>}
          </div>
          <div className="space-y-2">
            <Label htmlFor="description">Description</Label>
            <Textarea
              id="description"
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              className={errors.description ? 'border-red-500' : ''}
            />
            {errors.description && <p className="text-sm text-red-500">{errors.description}</p>}
          </div>
          <div className="space-y-2">
            <Label htmlFor="location">Location (Optional)</Label>
            <Input
              id="location"
              value={location}
              onChange={(e) => setLocation(e.target.value)}
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="file">Upload File</Label>
            <Input
              id="file"
              type="file"
              onChange={handleFileChange}
              className={errors.file ? 'border-red-500' : ''}
            />
            {errors.file && <p className="text-sm text-red-500">{errors.file}</p>}
          </div>
          <AnimatePresence>
            {submissionStatus === 'submitting' && (
              <motion.div
                initial={{ opacity: 0, height: 0 }}
                animate={{ opacity: 1, height: 'auto' }}
                exit={{ opacity: 0, height: 0 }}
              >
                <Progress value={uploadProgress} className="w-full" />
              </motion.div>
            )}
          </AnimatePresence>
          <Button
            type="submit"
            className="w-full"
            disabled={submissionStatus === 'submitting'}
          >
            {submissionStatus === 'submitting' ? (
              <>
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                Submitting...
              
              </>
            ) : (
              <>
                <Upload className="mr-2 h-4 w-4" />
                Submit Evidence
              </>
            )}
          </Button>
        </form>
        <AnimatePresence>
          {submissionStatus === 'success' && (
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="mt-4 p-4 bg-green-100 text-green-700 rounded-md flex items-center"
            >
              <Check className="mr-2 h-5 w-5" />
              Evidence submitted successfully!
            </motion.div>
          )}
          {submissionStatus === 'error' && (
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="mt-4 p-4 bg-red-100 text-red-700 rounded-md flex items-center"
            >
              <AlertTriangle className="mr-2 h-5 w-5" />
              An error occurred. Please try again.
            </motion.div>
          )}
        </AnimatePresence>
      </CardContent>
    </Card>
  )
}

export default EvidenceSubmissionForm