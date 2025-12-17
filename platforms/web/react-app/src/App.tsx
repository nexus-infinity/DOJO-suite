import React, { useState } from 'react'
import Button from '../../../../shared/components/Button'
import { Bell, Settings, User } from 'lucide-react'

const App: React.FC = () => {
  const [sidebarOpen, setSidebarOpen] = useState(true)

  const toggleSidebar = () => {
    setSidebarOpen(!sidebarOpen)
  }

  return (
    <div className="flex h-screen bg-gray-100">
      {/* Sidebar */}
      <aside
        className={`bg-gray-800 text-white w-64 space-y-6 py-7 px-2 absolute inset-y-0 left-0 transform ${
          sidebarOpen ? 'translate-x-0' : '-translate-x-full'
        } transition duration-200 ease-in-out md:relative md:translate-x-0`}
      >
        <nav>
          <a href="#" className="block py-2.5 px-4 rounded transition duration-200 hover:bg-gray-700">
            Dashboard
          </a>
          <a href="#" className="block py-2.5 px-4 rounded transition duration-200 hover:bg-gray-700">
            Projects
          </a>
          <a href="#" className="block py-2.5 px-4 rounded transition duration-200 hover:bg-gray-700">
            Tasks
          </a>
          <a href="#" className="block py-2.5 px-4 rounded transition duration-200 hover:bg-gray-700">
            Calendar
          </a>
        </nav>
      </aside>

      {/* Main Content */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Header */}
        <header className="bg-white shadow-md p-4">
          <div className="flex items-center justify-between">
            <Button label={sidebarOpen ? 'Close Sidebar' : 'Open Sidebar'} onClick={toggleSidebar} variant="secondary" />
            <h1 className="text-2xl font-semibold">Universal Framework Web App</h1>
            <div className="flex items-center space-x-4">
              <Button label="" onClick={() => console.log('Notifications')} variant="icon">
                <Bell className="h-5 w-5" />
              </Button>
              <Button label="" onClick={() => console.log('Settings')} variant="icon">
                <Settings className="h-5 w-5" />
              </Button>
              <Button label="" onClick={() => console.log('Profile')} variant="icon">
                <User className="h-5 w-5" />
              </Button>
            </div>
          </div>
        </header>

        {/* Main content area */}
        <main className="flex-1 overflow-x-hidden overflow-y-auto bg-gray-200 p-6">
          <div className="bg-white rounded-lg shadow-md p-6">
            <h2 className="text-xl font-semibold mb-4">Welcome to Your Dashboard</h2>
            <p className="mb-4">This is where you'll see an overview of your projects and tasks.</p>
            <Button label="Create New Project" onClick={() => console.log('Create New Project')} variant="primary" />
          </div>
        </main>

        {/* Footer */}
        <footer className="bg-white shadow-md p-4 mt-auto">
          <p className="text-center text-gray-600">© 2024 Universal Framework. All rights reserved.</p>
        </footer>
      </div>
    </div>
  )
}

export default App