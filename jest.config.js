module.exports = {
  projects: [
    '<rootDir>/apps/apis/auth',
    '<rootDir>/apps/apis/gateway',
  ],
  collectCoverageFrom: [
    '**/*.{js,ts}',
    '!**/*.d.ts',
    '!**/node_modules/**',
    '!**/dist/**',
    '!**/coverage/**',
    '!**/*.config.{js,ts}',
  ],
  coverageThreshold: {
    global: {
      branches: 70,
      functions: 70,
      lines: 70,
      statements: 70,
    },
  },
};

