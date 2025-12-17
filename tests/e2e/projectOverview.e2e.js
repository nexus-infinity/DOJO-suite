// tests/e2e/projectOverview.e2e.js
describe('Project Overview Page', () => {
  it('loads and displays project title', () => {
    cy.visit('/project-overview');
    cy.get('h1').should('contain', 'Project Overview');
  });
});
