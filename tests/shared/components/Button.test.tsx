import React from 'react';
import { render, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';  // For extended matchers like toBeInTheDocument
import Button from '../../../shared/components/Button';  // Adjust the path if needed

describe('Button component', () => {
  it('renders with the correct label', () => {
    const { getByText } = render(<Button label="Click me" onClick={() => {}} />);
    
    // Check if the button text renders correctly
    const buttonElement = getByText('Click me');
    expect(buttonElement).toBeInTheDocument();
  });

  it('calls onClick when clicked', () => {
    const handleClick = jest.fn();  // Mock function for onClick handler
    const { getByText } = render(<Button label="Click me" onClick={handleClick} />);
    
    // Simulate click event
    fireEvent.click(getByText('Click me'));
    
    // Ensure the onClick handler was called once
    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  it('applies the correct styles for different variants', () => {
    // First render with "primary" variant
    const { getByText, rerender } = render(<Button label="Primary" onClick={() => {}} variant="primary" />);
    
    // Check that the primary button has the correct class
    expect(getByText('Primary')).toHaveClass('bg-blue-500');

    // Rerender with "secondary" variant
    rerender(<Button label="Secondary" onClick={() => {}} variant="secondary" />);
    
    // Check that the secondary button has the correct class
    expect(getByText('Secondary')).toHaveClass('bg-gray-200');

    // Rerender with "tertiary" variant
    rerender(<Button label="Tertiary" onClick={() => {}} variant="tertiary" />);
    
    // Check that the tertiary button has the correct class
    expect(getByText('Tertiary')).toHaveClass('bg-transparent');
  });
});
