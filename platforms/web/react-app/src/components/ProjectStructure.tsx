import React, { useState } from 'react';
import { ChevronRight, ChevronDown, Folder, File } from 'lucide-react';

type TreeNode = {
  name: string;
  children?: TreeNode[];
};

const projectStructure: TreeNode = {
  name: "universal-framework",
  children: [
    { name: "AI_IMPLEMENTATION_PLAN.md" },
    { name: "AI_INTEGRATION.md" },
    { name: "LICENSE" },
    { name: "README.md" },
    {
      name: "platforms",
      children: [
        { name: "desktop" },
        { name: "mobile" },
        { name: "smart-devices" },
        { name: "tv" },
        { name: "wearables" },
        {
          name: "web",
          children: [
            {
              name: "react-app",
              children: [
                { name: "public" },
                {
                  name: "src",
                  children: [
                    { name: "components" },
                    { name: "pages" },
                    { name: "styles" },
                    { name: "utils" },
                    { name: "App.tsx" },
                    { name: "index.tsx" }
                  ]
                },
                { name: "package.json" },
                { name: "tsconfig.json" },
                { name: "README.md" }
              ]
            }
          ]
        }
      ]
    },
    { name: "ci-cd" },
    { name: "config" },
    { name: "core" },
    { name: "docs" },
    { name: "modules" },
    { name: "node_modules" },
    { name: "package.json" },
    { name: "package-lock.json" },
    { name: "playground" },
    { name: "shared" },
    { name: "tests" },
    { name: "universal-framework.txt" }
  ]
};

const TreeNode: React.FC<{ node: TreeNode }> = ({ node }) => {
  const [isExpanded, setIsExpanded] = useState(false);
  const hasChildren = node.children && node.children.length > 0;

  return (
    <div>
      <div 
        className="flex items-center cursor-pointer py-1"
        onClick={() => hasChildren && setIsExpanded(!isExpanded)}
      >
        {hasChildren ? (
          isExpanded ? <ChevronDown className="w-4 h-4 mr-1" /> : <ChevronRight className="w-4 h-4 mr-1" />
        ) : (
          <span className="w-4 h-4 mr-1"></span>
        )}
        {hasChildren ? <Folder className="w-4 h-4 mr-2 text-yellow-500" /> : <File className="w-4 h-4 mr-2 text-gray-500" />}
        <span>{node.name}</span>
      </div>
      {isExpanded && node.children && (
        <div className="ml-6">
          {node.children.map((childNode, index) => (
            <TreeNode key={index} node={childNode} />
          ))}
        </div>
      )}
    </div>
  );
};

const ProjectStructure: React.FC = () => {
  return (
    <div className="bg-white shadow overflow-hidden sm:rounded-lg">
      <div className="px-4 py-5 sm:px-6">
        <h1 className="text-3xl font-bold text-gray-900">Project Structure</h1>
        <p className="mt-1 max-w-2xl text-sm text-gray-500">An interactive view of the Universal Framework project structure</p>
      </div>
      <div className="border-t border-gray-200 px-4 py-5 sm:p-0">
        <div className="sm:divide-y sm:divide-gray-200">
          <div className="py-4 sm:py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
            <dt className="text-sm font-medium text-gray-500">Directory Tree</dt>
            <dd className="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
              <div className="border rounded p-4 bg-gray-50">
                <TreeNode node={projectStructure} />
              </div>
            </dd>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ProjectStructure;