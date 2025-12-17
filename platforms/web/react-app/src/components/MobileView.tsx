import React from 'react'

interface MobileViewProps {
  children: React.ReactNode
}

const MobileView: React.FC<MobileViewProps> = ({ children }) => {
  return (
    <div className="md:hidden">
      {children}
    </div>
  )
}

export default MobileView