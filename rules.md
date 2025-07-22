# By Abroad Development Rules

## Core Development Rules
*These rules must be followed throughout the entire development process*

### 1. Documentation & Progress Tracking
- **Always document the steps, what's done, what's not done yet**
  - Update plan.md after each significant change
  - Maintain detailed commit messages
  - Document all API integrations and their status
  - Keep track of test results and fixes applied
  - Record all architectural decisions and rationale

### 2. Plan Adherence
- **Never assume, always stick to the plan.md file**
  - Reference plan.md before starting any new feature
  - Update plan.md if requirements change
  - Get approval before deviating from planned approach
  - Break large tasks into smaller, trackable items
  - Mark completion status clearly in plan.md

### 3. Scope Management
- **If something is out of scope, stop and ask**
  - When user answers scope questions, update plan.md first
  - Wait for explicit approval before proceeding with out-of-scope work
  - Document scope changes with reasoning
  - Re-estimate timelines when scope changes
  - Ask for confirmation to proceed after plan updates

### 4. Testing Requirements
- **Always test with iPhone 16 Pro, check for errors and suggest 2 ways to fix problems**
  - Test every feature on iPhone 16 Pro simulator
  - Document all errors found during testing
  - For each error, provide exactly 2 different solution approaches
  - Wait for user's reply on which solution to implement
  - Test again after implementing fixes
  - Document test results in plan.md

### 5. Version Control & Deployment
- **Once testing is done, upload to GitHub as a new version**
  - Commit all changes with descriptive messages
  - Create proper version tags (v1.0.0, v1.1.0, etc.)
  - Push to GitHub only after successful testing
  - Update README.md with version changes
  - Create release notes for each version

### 6. Context Gathering
- **For new features or suggestions, ask set of questions to get full context**
  - Ask clarifying questions before implementation:
    - What is the expected user behavior?
    - What are the acceptance criteria?
    - How should this integrate with existing features?
    - Are there any constraints or limitations?
    - What is the priority level?
  - Update plan.md with new requirements after getting answers
  - Wait for confirmation before starting implementation

### 7. User Testing Requirements
- **Always run and test the feature as a user, let user do testing too**
  - Test all user flows end-to-end
  - Document the testing process and results
  - Provide clear instructions for user testing
  - Wait for user testing feedback before marking feature complete
  - Record user feedback and implement necessary changes

### 8. Error Resolution Limits
- **If you tried to fix more than 2 times and it fails, stop and suggest 2 alternatives**
  - Track fix attempts for each issue
  - After 2 failed attempts, stop and document the problem
  - Present 2 alternative approaches to the user
  - Wait for user decision on which alternative to pursue
  - Reset attempt counter for the chosen alternative approach

### 9. Code Quality Standards
- **Add unit testing in each code**
  - Every service class must have corresponding unit tests
  - Every data model must have unit tests
  - Every calculation algorithm must have unit tests
  - Test coverage should be >80% for core functionality
  - Use XCTest framework for iOS testing
  - Mock external dependencies in tests

### 10. Architecture Consistency
- **Keep the same code model and structure**
  - Follow established SwiftUI patterns
  - Maintain consistent naming conventions
  - Use the same data flow patterns throughout
  - Keep similar features in similar folder structures
  - Follow iOS development best practices
  - Maintain separation of concerns (MVVM pattern)

### 11. Problem-Solving Approach
- **Never simplify the code just to succeed in compile, keep the original plan and search online to solve issues**
  - Research proper solutions instead of quick fixes
  - Use official documentation and reliable sources
  - Maintain code quality over quick compilation
  - If stuck, research the issue thoroughly before asking for help
  - Document the research process and sources used
  - Implement robust solutions, not workarounds

## Additional Development Guidelines

### Code Standards
- Use meaningful variable and function names
- Add comments for complex logic
- Follow Swift coding conventions
- Use proper error handling (do-catch blocks)
- Implement proper memory management
- Use async/await for network operations

### UI/UX Standards
- Follow iOS Human Interface Guidelines
- Ensure accessibility compliance
- Test on multiple device sizes
- Implement proper loading states
- Provide meaningful error messages to users
- Use consistent spacing and colors

### Security Standards
- Never store sensitive data in plain text
- Use Keychain for sensitive storage
- Validate all user inputs
- Implement proper network security (HTTPS only)
- Follow privacy guidelines (no PII in analytics)
- Implement proper data sanitization

### Performance Standards
- Optimize image loading and caching
- Implement proper list scrolling performance
- Monitor memory usage
- Use background queues for heavy operations
- Implement proper error recovery
- Test with poor network conditions

### Documentation Standards
- Update README.md for setup instructions
- Document all API endpoints used
- Maintain changelog for versions
- Document known issues and limitations
- Keep privacy policy updated
- Document testing procedures

## Violation Consequences
- If rules are violated, development must stop
- Document the violation and corrective action needed
- Update plan.md with lessons learned
- Get user approval before continuing development
- Implement measures to prevent similar violations

---

*These rules are binding for the entire development lifecycle and must be referenced regularly throughout the project.* 