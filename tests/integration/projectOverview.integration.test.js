import { render, screen } from '@testing-library/react';
import ProjectOverview from '@/components/ProjectOverview';

describe('ProjectOverview Integration Test', () => {
  test('it renders project title from API', async () => {
    render(<ProjectOverview />);
    expect(screen.getByText('Project Overview')).toBeInTheDocument();
  });
});
