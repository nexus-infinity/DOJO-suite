import React from 'react';

const Home = () => {
  return (
    <div className="bg-white shadow overflow-hidden sm:rounded-lg">
      <div className="px-4 py-5 sm:px-6">
        <h1 className="text-3xl font-bold text-gray-900">Welcome to Universal Framework</h1>
        <p className="mt-1 max-w-2xl text-sm text-gray-500">A comprehensive solution for cross-platform development</p>
      </div>
      <div className="border-t border-gray-200">
        <dl>
          <div className="bg-gray-50 px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
            <dt className="text-sm font-medium text-gray-500">Description</dt>
            <dd className="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
              Universal Framework is designed to streamline development across multiple platforms, 
              integrating AI capabilities and providing a robust set of tools and modules.
            </dd>
          </div>
          <div className="bg-white px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
            <dt className="text-sm font-medium text-gray-500">Key Features</dt>
            <dd className="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
              <ul className="list-disc pl-5">
                <li>Cross-platform compatibility</li>
                <li>Integrated AI capabilities</li>
                <li>Modular architecture</li>
                <li>Comprehensive documentation</li>
                <li>Robust testing framework</li>
              </ul>
            </dd>
          </div>
        </dl>
      </div>
    </div>
  );
};

export default Home;