import React from 'react'

interface Project {
  id: string
  name: string
  description: string
}

interface ProjectOverviewProps {
  projects?: Project[]
}

const ProjectOverview: React.FC<ProjectOverviewProps> = ({ projects = [] }) => {
  if (projects.length === 0) {
    return (
      <div className="p-4 border rounded shadow">
        <p className="text-gray-600">No projects available.</p>
      </div>
    )
  }

  return (
    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
      {projects.map((project) => (
        <div key={project.id} className="p-4 border rounded shadow">
          <h3 className="text-lg font-semibold">{project.name}</h3>
          <p className="mt-2 text-gray-600">{project.description}</p>
        </div>
      ))}
    </div>
  )
}

export default ProjectOverview