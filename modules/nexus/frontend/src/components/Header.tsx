import React from 'react'

export default function Header() {
  return (
    <header className="bg-primary text-white p-4">
      <h1 className="text-2xl font-bold">Nexus Module</h1>
      <nav>
        <ul className="flex space-x-4">
          <li><a href="/" className="hover:underline">Home</a></li>
          <li><a href="/about" className="hover:underline">About</a></li>
          <li><a href="/contact" className="hover:underline">Contact</a></li>
        </ul>
      </nav>
    </header>
  )
}