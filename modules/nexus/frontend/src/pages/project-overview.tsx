import React from 'react'
import ProjectOverview from '../components/ProjectOverview'

const ProjectOverviewPage: React.FC = () => {
  return (
    <div className="container mx-auto p-4">
      <h1 className="text-2xl font-bold mb-4">Nexus Module Overview</h1>
      <ProjectOverview />
    </div>
  )
}

export default ProjectOverviewPage