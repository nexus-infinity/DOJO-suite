import { render, screen } from '@testing-library/react';
import MobileView from '@/components/MobileView';

describe('Mobile View', () => {
  test('renders mobile view component', () => {
    render(<MobileView />);
    expect(screen.getByText('Mobile View Component')).toBeInTheDocument();
  });
});
