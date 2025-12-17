import React from 'react';

const About = () => {
  return (
    <div className="bg-white shadow overflow-hidden sm:rounded-lg">
      <div className="px-4 py-5 sm:px-6">
        <h1 className="text-3xl font-bold text-gray-900">About Universal Framework</h1>
        <p className="mt-1 max-w-2xl text-sm text-gray-500">Learn more about our project and its goals</p>
      </div>
      <div className="border-t border-gray-200">
        <dl>
          <div className="bg-gray-50 px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
            <dt className="text-sm font-medium text-gray-500">Mission</dt>
            <dd className="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
              To provide developers with a comprehensive, AI-enhanced framework for building 
              cross-platform applications efficiently and effectively.
            </dd>
          </div>
          <div className="bg-white px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
            <dt className="text-sm font-medium text-gray-500">Vision</dt>
            <dd className="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
              To revolutionize the development process by seamlessly integrating AI capabilities 
              and cross-platform compatibility into a single, powerful framework.
            </dd>
          </div>
          <div className="bg-gray-50 px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
            <dt className="text-sm font-medium text-gray-500">Core Values</dt>
            <dd className="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
              <ul className="list-disc pl-5">
                <li>Innovation in development practices</li>
                <li>Commitment to open-source principles</li>
                <li>Continuous learning and improvement</li>
                <li>User-centric design and functionality</li>
              </ul>
            </dd>
          </div>
        </dl>
      </div>
    </div>
  );
};

export default About;