import React from 'react';
import { render, screen } from '@testing-library/react';
import ProjectOverview from '../../platforms/web/components/ProjectOverview';

describe('ProjectOverview Component', () => {
  const mockProjects = [
    { id: '1', name: 'Project A', description: 'Description for Project A' },
    { id: '2', name: 'Project B', description: 'Description for Project B' },
  ];

  test('renders the component with projects', () => {
    render(<ProjectOverview projects={mockProjects} />);
    expect(screen.getByText('Project A')).toBeInTheDocument();
    expect(screen.getByText('Project B')).toBeInTheDocument();
    expect(screen.getByText('Description for Project A')).toBeInTheDocument();
    expect(screen.getByText('Description for Project B')).toBeInTheDocument();
  });

  test('renders "No projects available" when projects array is empty', () => {
    render(<ProjectOverview projects={[]} />);
    expect(screen.getByText('No projects available.')).toBeInTheDocument();
  });

  test('renders "No projects available" when projects prop is undefined', () => {
    render(<ProjectOverview />);
    expect(screen.getByText('No projects available.')).toBeInTheDocument();
  });
});