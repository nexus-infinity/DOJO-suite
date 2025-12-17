import { render, screen } from '@testing-library/react'
import Header from '../../../modules/nexus/frontend/src/components/Header'

describe('Header component', () => {
  it('renders the header with correct title', () => {
    render(<Header />)
    const titleElement = screen.getByText(/Nexus Module/i)
    expect(titleElement).toBeInTheDocument()
  })

  it('renders navigation links', () => {
    render(<Header />)
    const homeLink = screen.getByText(/Home/i)
    const aboutLink = screen.getByText(/About/i)
    const contactLink = screen.getByText(/Contact/i)
    expect(homeLink).toBeInTheDocument()
    expect(aboutLink).toBeInTheDocument()
    expect(contactLink).toBeInTheDocument()
  })
})