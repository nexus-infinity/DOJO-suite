'use client'

import { useState, useEffect } from 'react'
import { Button } from "@/components/ui/button"
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Edit2, Trash2 } from 'lucide-react'
import Link from 'next/link'
import EvidenceSubmissionPlatform from '@/components/EvidenceSubmissionPlatform'

// Mock data for demonstration
const mockUserStories = [
  { id: 1, title: "My Journey to Recovery", createdAt: "2023-06-15", status: "published" },
  { id: 2, title: "Fighting for Equality", createdAt: "2023-06-20", status: "under review" },
  { id: 3, title: "A Voice for the Voiceless", createdAt: "2023-06-25", status: "draft" },
]

export default function Dashboard() {
  const [userStories, setUserStories] = useState(mockUserStories)
  const [showSubmissionForm, setShowSubmissionForm] = useState(false)

  // In a real application, you would fetch the user's stories from your API here
  useEffect(() => {
    // Simulating an API call
    setTimeout(() => {
      setUserStories(mockUserStories)
    }, 1000)
  }, [])

  const handleDelete = (id: number) => {
    // In a real application, you would call your API to delete the story
    setUserStories(userStories.filter(story => story.id !== id))
  }

  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="text-3xl font-bold mb-6">Your Dashboard</h1>
      <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3 mb-6">
        <Card>
          <CardHeader>
            <CardTitle>Total Stories</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-3xl font-bold">{userStories.length}</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle>Published Stories</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-3xl font-bold">{userStories.filter(story => story.status === 'published').length}</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle>Stories Under Review</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-3xl font-bold">{userStories.filter(story => story.status === 'under review').length}</p>
          </CardContent>
        </Card>
      </div>
      <Card className="mb-6">
        <CardHeader>
          <CardTitle>Your Stories</CardTitle>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Title</TableHead>
                <TableHead>Created At</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {userStories.map((story) => (
                <TableRow key={story.id}>
                  <TableCell>{story.title}</TableCell>
                  <TableCell>{story.createdAt}</TableCell>
                  <TableCell>{story.status}</TableCell>
                  <TableCell>
                    <div className="flex space-x-2">
                      <Button variant="outline" size="sm">
                        <Edit2 className="h-4 w-4 mr-2" />
                        Edit
                      </Button>
                      <Button variant="outline" size="sm" onClick={() => handleDelete(story.id)}>
                        <Trash2 className="h-4 w-4 mr-2" />
                        Delete
                      </Button>
                    </div>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
      <div className="mb-6">
        <Button onClick={() => setShowSubmissionForm(!showSubmissionForm)}>
          {showSubmissionForm ? 'Hide Submission Form' : 'Submit New Evidence'}
        </Button>
      </div>
      {showSubmissionForm && (
        <Card className="mb-6">
          <CardHeader>
            <CardTitle>Submit New Evidence</CardTitle>
          </CardHeader>
          <CardContent>
            <EvidenceSubmissionPlatform />
          </CardContent>
        </Card>
      )}
      <div>
        <Button asChild>
          <Link href="/submit-story">Submit New Story</Link>
        </Button>
      </div>
    </div>
  )
}