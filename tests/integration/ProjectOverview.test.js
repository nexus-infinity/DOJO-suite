import React from 'react';
import { render, screen } from '@testing-library/react';
import ProjectOverview from '@/components/ProjectOverview';

describe('ProjectOverview Component', () => {
  test('renders the component', () => {
    render(<ProjectOverview />);
    expect(screen.getByText('Project Overview')).toBeInTheDocument();
  });
});