import React from 'react'
import { Folder, Code, Database, Cloud, Settings, Terminal, Users, Zap } from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"

const ProjectOverview: React.FC = () => {
  const features = [
    { icon: Folder, title: "Modular Architecture", description: "Separate, independent modules for easy development and scaling" },
    { icon: Code, title: "Cross-Platform Compatibility", description: "Works seamlessly across web, mobile, and desktop platforms" },
    { icon: Database, title: "Scalable Data Management", description: "Efficiently handle growing amounts of information" },
    { icon: Cloud, title: "Cloud-Native Design", description: "Optimized for deployment on various cloud services" },
    { icon: Settings, title: "Flexible Configuration", description: "Easily adjust settings for different environments" },
    { icon: Terminal, title: "Integrated DevOps", description: "Streamlined development and deployment processes" },
    { icon: Users, title: "Collaboration-Focused", description: "Built for effective teamwork and knowledge sharing" },
    { icon: Zap, title: "AI-Powered Features", description: "Leverage artificial intelligence for enhanced capabilities" }
  ]

  return (
    <div className="max-w-4xl mx-auto p-6 space-y-8">
      <h1 className="text-3xl font-bold text-center mb-2">Nexus Module Overview</h1>
      <Card className="w-full">
        <CardHeader className="text-center">
          <CardTitle className="text-2xl mb-2">Nexus Module: Core of the Universal Framework</CardTitle>
          <CardDescription>An overview for developers and stakeholders</CardDescription>
        </CardHeader>
        <CardContent>
          <Tabs defaultValue="general" className="w-full">
            <TabsList className="grid w-full grid-cols-2 mb-4">
              <TabsTrigger value="general">General Overview</TabsTrigger>
              <TabsTrigger value="technical">Technical Details</TabsTrigger>
            </TabsList>
            <TabsContent value="general" className="space-y-4">
              <p className="text-muted-foreground">
                The Nexus module serves as the central hub of the Universal Framework, 
                integrating key functionalities and providing a foundation for scalable, 
                cross-platform application development. It embodies the framework's 
                principles of modularity, flexibility, and innovation.
              </p>
              <h3 className="text-xl font-semibold mb-2">Key Features:</h3>
              <ul className="space-y-3">
                {features.map((feature, index) => (
                  <li key={index} className="flex items-center space-x-3">
                    <feature.icon className="w-6 h-6 text-primary" />
                    <span>
                      <strong className="text-primary">{feature.title}:</strong>{' '}
                      <span className="text-muted-foreground">{feature.description}</span>
                    </span>
                  </li>
                ))}
              </ul>
            </TabsContent>
            <TabsContent value="technical" className="space-y-4">
              <p className="text-muted-foreground">
                The Nexus module is designed with a focus on modularity, scalability, and 
                cross-platform compatibility. It leverages cutting-edge technologies and 
                development practices to create a robust, maintainable, and extensible system.
              </p>
              <h3 className="text-xl font-semibold mb-2">Core Components:</h3>
              <ul className="list-disc pl-5 space-y-2 text-muted-foreground">
                <li><strong className="text-primary">Frontend:</strong> React with TypeScript, leveraging Next.js for server-side rendering and optimal performance.</li>
                <li><strong className="text-primary">Backend:</strong> Node.js with Express, following a layered architecture (routes, controllers, services, models).</li>
                <li><strong className="text-primary">Database:</strong> MongoDB for flexible document storage, with Mongoose for object modeling.</li>
                <li><strong className="text-primary">API:</strong> GraphQL for efficient, type-safe data querying and manipulation.</li>
                <li><strong className="text-primary">State Management:</strong> Redux for predictable state updates, with Redux Toolkit for simplified logic.</li>
                <li><strong className="text-primary">Testing:</strong> Jest for unit and integration testing, Cypress for end-to-end testing.</li>
                <li><strong className="text-primary">CI/CD:</strong> GitHub Actions for automated testing, building, and deployment processes.</li>
                <li><strong className="text-primary">Containerization:</strong> Docker for consistent development and production environments.</li>
              </ul>
            </TabsContent>
          </Tabs>
        </CardContent>
      </Card>
    </div>
  )
}

export default ProjectOverview