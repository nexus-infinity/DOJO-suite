import React, { useState } from 'react'
import Image from 'next/image'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Progress } from "@/components/ui/progress"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { AlertCircle, BarChart, Cloud, Code, FileText, Folder, HardDrive, Package, RefreshCw, Settings, Smartphone } from 'lucide-react'
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert"
import { Button } from "@/components/ui/button"

const projectStructure = [
  { name: "ai", icon: Folder, description: "AI-related components" },
  { name: "backend", icon: Folder, description: "Backend services" },
  { name: "frontend", icon: Folder, description: "Frontend application" },
  { name: "nexus", icon: Folder, description: "Core Nexus components" },
  { name: "package.json", icon: FileText, description: "Node.js project configuration" },
  { name: "requirements.txt", icon: FileText, description: "Python dependencies" },
]

const technologies = [
  "React", "Node.js", "Python", "Next.js", "Express", "MongoDB"
]

const storageServices = [
  { name: "Local Drive (C:)", usage: 70, color: "bg-yellow-500", type: "local", icon: HardDrive },
  { name: "Cloud Storage", usage: 55, color: "bg-blue-500", type: "cloud", icon: Cloud },
  { name: "Mobile Devices", usage: 80, color: "bg-purple-500", type: "device", icon: Smartphone },
]

export default function UniversalFrameworkDashboard() {
  const [activeTab, setActiveTab] = useState("overview")

  return (
    <div className="grid grid-rows-[20px_1fr_20px] items-center justify-items-center min-h-screen p-8 pb-20 gap-16 sm:p-20 font-[family-name:var(--font-geist-sans)]">
      <main className="flex flex-col gap-8 row-start-2 items-center w-full max-w-6xl">
        <div className="flex items-center justify-between w-full">
          <Image
            className="dark:invert"
            src="https://nextjs.org/icons/next.svg"
            alt="Universal Framework logo"
            width={180}
            height={38}
            priority
          />
          <h1 className="text-3xl font-bold">Universal Framework Dashboard</h1>
        </div>

        <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
          <TabsList className="grid w-full grid-cols-3 mb-6">
            <TabsTrigger value="overview">Overview</TabsTrigger>
            <TabsTrigger value="structure">Project Structure</TabsTrigger>
            <TabsTrigger value="storage">Storage Management</TabsTrigger>
          </TabsList>

          <TabsContent value="overview">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <Card>
                <CardHeader>
                  <CardTitle>Project Overview</CardTitle>
                  <CardDescription>Key components of your Universal Framework</CardDescription>
                </CardHeader>
                <CardContent>
                  <h3 className="text-lg font-semibold mb-2">Technologies Used</h3>
                  <ul className="flex flex-wrap gap-2 mb-4">
                    {technologies.map((tech, index) => (
                      <li key={index} className="bg-primary text-primary-foreground px-3 py-1 rounded-full text-sm">
                        {tech}
                      </li>
                    ))}
                  </ul>
                  <div className="flex items-center space-x-2">
                    <Package className="w-5 h-5 text-primary" />
                    <span>Dependencies managed via npm and requirements.txt</span>
                  </div>
                </CardContent>
              </Card>
              
              <Card>
                <CardHeader>
                  <CardTitle>Quick Actions</CardTitle>
                </CardHeader>
                <CardContent className="flex flex-col gap-4">
                  <Button><RefreshCw className="mr-2 h-4 w-4" /> Sync All Components</Button>
                  <Button><Cloud className="mr-2 h-4 w-4" /> Deploy to Cloud</Button>
                  <Button><Code className="mr-2 h-4 w-4" /> Generate Code</Button>
                  <Button><BarChart className="mr-2 h-4 w-4" /> View Analytics</Button>
                </CardContent>
              </Card>
            </div>
          </TabsContent>

          <TabsContent value="structure">
            <Card>
              <CardHeader>
                <CardTitle>Project Structure</CardTitle>
                <CardDescription>Key components and structure of your Universal Framework</CardDescription>
              </CardHeader>
              <CardContent>
                <ul className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  {projectStructure.map((item, index) => (
                    <li key={index} className="flex items-center space-x-2">
                      <item.icon className="w-5 h-5 text-primary" />
                      <span className="font-medium">{item.name}</span>
                      <span className="text-sm text-muted-foreground">- {item.description}</span>
                    </li>
                  ))}
                </ul>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="storage">
            <Card>
              <CardHeader>
                <CardTitle>Storage Management</CardTitle>
                <CardDescription>Overview of storage usage across different services</CardDescription>
              </CardHeader>
              <CardContent>
                {storageServices.map((service) => (
                  <div key={service.name} className="mb-4">
                    <div className="flex justify-between mb-1">
                      <span className="flex items-center">
                        {<service.icon className="mr-2 h-4 w-4" />}
                        {service.name}
                      </span>
                      <span>{service.usage}%</span>
                    </div>
                    <Progress value={service.usage} className={service.color} />
                  </div>
                ))}
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>

        <Card className="w-full">
          <CardHeader>
            <CardTitle>System Status</CardTitle>
          </CardHeader>
          <CardContent>
            <Alert variant="default" className="mb-4">
              <AlertCircle className="h-4 w-4" />
              <AlertTitle>System Update Available</AlertTitle>
              <AlertDescription>
                A new version of Universal Framework is available. Please update to access the latest features.
              </AlertDescription>
            </Alert>
            <div className="flex items-center justify-between">
              <span>Last Sync: 5 minutes ago</span>
              <Button variant="outline"><Settings className="mr-2 h-4 w-4" /> Advanced Settings</Button>
            </div>
          </CardContent>
        </Card>
      </main>

      <footer className="row-start-3 flex gap-6 flex-wrap items-center justify-center">
        <a
          className="flex items-center gap-2 hover:underline hover:underline-offset-4"
          href="https://github.com/your-repo/universal-framework"
          target="_blank"
          rel="noopener noreferrer"
        >
          <Image
            src="https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png"
            alt="GitHub icon"
            width={16}
            height={16}
          />
          GitHub Repository
        </a>
        <a
          className="flex items-center gap-2 hover:underline hover:underline-offset-4"
          href="https://your-docs-url.com"
          target="_blank"
          rel="noopener noreferrer"
        >
          <FileText className="h-4 w-4" />
          Documentation
        </a>
        <a
          className="flex items-center gap-2 hover:underline hover:underline-offset-4"
          href="https://your-community-url.com"
          target="_blank"
          rel="noopener noreferrer"
        >
          <AlertCircle className="h-4 w-4" />
          Community Support
        </a>
      </footer>
    </div>
  )
}