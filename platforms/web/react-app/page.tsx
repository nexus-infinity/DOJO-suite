import Link from 'next/link'
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { PenTool, BookOpen, LayoutDashboard, AlertTriangle } from 'lucide-react'
import NewFeature from '@/components/NewFeature'
import ToastDemo from '@/components/ToastDemo'

export default function Home() {
  return (
    <div className="flex flex-col min-h-screen bg-gray-50">
      <header className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex justify-between items-center">
          <div className="flex items-center">
            <svg className="h-8 w-8 text-purple-600" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M9 6L15 12L9 18" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
            </svg>
            <span className="ml-2 text-2xl font-bold text-gray-900">Nexus-Infinity</span>
          </div>
          <nav>
            <Link href="/submit-story" className="text-gray-500 hover:text-gray-900 mx-3">Submit Story</Link>
            <Link href="/stories" className="text-gray-500 hover:text-gray-900 mx-3">View Stories</Link>
            <Link href="/dashboard" className="text-gray-500 hover:text-gray-900 mx-3">Dashboard</Link>
            <Link href="/report" className="text-gray-500 hover:text-gray-900 mx-3">Urgent Report</Link>
          </nav>
        </div>
      </header>

      <main className="flex-grow container mx-auto px-4 py-8">
        <h1 className="text-4xl font-bold text-center mb-4">Welcome to Nexus-Infinity Platform</h1>
        <p className="text-xl text-center text-gray-600 mb-8">
          Share your story and make a difference in our community.
        </p>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center">
                <PenTool className="h-6 w-6 text-purple-600 mr-2" />
                Submit Your Story
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-gray-600 mb-4">Share your experiences and insights with our community.</p>
              <Button asChild className="w-full">
                <Link href="/submit-story">Submit a Story</Link>
              </Button>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle className="flex items-center">
                <BookOpen className="h-6 w-6 text-green-600 mr-2" />
                Read Stories
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-gray-600 mb-4">Explore inspiring stories from our community members.</p>
              <Button asChild variant="outline" className="w-full">
                <Link href="/stories">View Stories</Link>
              </Button>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle className="flex items-center">
                <LayoutDashboard className="h-6 w-6 text-blue-600 mr-2" />
                Your Dashboard
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-gray-600 mb-4">Manage your stories and see your impact on the community.</p>
              <Button asChild variant="outline" className="w-full">
                <Link href="/dashboard">Go to Dashboard</Link>
              </Button>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle className="flex items-center">
                <AlertTriangle className="h-6 w-6 text-red-600 mr-2" />
                Urgent Report
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-gray-600 mb-4">View and respond to urgent community issues and reports.</p>
              <Button asChild variant="outline" className="w-full bg-red-100 hover:bg-red-200 text-red-600 border-red-200">
                <Link href="/report">View Urgent Report</Link>
              </Button>
            </CardContent>
          </Card>
        </div>

        <div className="mb-8">
          <NewFeature />
        </div>

        <div className="mb-8">
          <ToastDemo />
        </div>
      </main>

      <footer className="bg-white mt-12">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 text-center text-gray-500">
          © 2023 Nexus-Infinity Platform. All rights reserved.
        </div>
      </footer>
    </div>
  )
}