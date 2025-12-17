import React from 'react';
import { Folder, Code, Database, Cloud, Settings, Terminal, Users, Zap } from 'lucide-react';
import ProjectOverview from '../components/ProjectOverview';

// Optional: Enforcing strict typing for the features array
interface Feature {
  icon: React.ComponentType;
  title: string;
  description: string;
}

const ProjectOverviewPage: React.FC = () => {
  const customFeatures: Feature[] = [
    { icon: Folder, title: "Modular Architecture", description: "Separate, independent modules for easy development and scaling" },
    { icon: Code, title: "Cross-Platform Compatibility", description: "Works seamlessly across web, mobile, and desktop platforms" },
    { icon: Database, title: "Scalable Data Management", description: "Efficiently handle growing amounts of information" },
    { icon: Cloud, title: "Cloud-Native Design", description: "Optimized for deployment on various cloud services" },
    { icon: Settings, title: "Flexible Configuration", description: "Easily adjust settings for different environments" },
    { icon: Terminal, title: "Integrated DevOps", description: "Streamlined development and deployment processes" },
    { icon: Users, title: "Collaboration-Focused", description: "Built for effective teamwork and knowledge sharing" },
    { icon: Zap, title: "AI-Powered Features", description: "Leverage artificial intelligence for enhanced capabilities" }
  ];

  return (
    <div className="max-w-5xl mx-auto p-6 space-y-8 sm:px-4">
      <ProjectOverview
        title="Custom Nexus Module Overview"
        description="Custom overview for the Nexus module, tailored for stakeholders and developers"
        features={customFeatures}
      />
    </div>
  );
};

export default ProjectOverviewPage;
