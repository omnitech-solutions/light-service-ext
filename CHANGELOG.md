## [Unreleased]

## [0.1.0] - 2023-02-15

- Initial release

## [0.1.1] - 2023-02-15

- Fixing issue with with use of `relative_path` inside of `light-service-ext.gemspec`

## [0.1.2] - 2023-02-24

- Updates `README.md` with detailed information on features provided

## [0.1.3] - 2023-02-25

- Adds `Orchestration` of organizers via `ApplicationOrchestrator` functionality to support calling an organizer(s) inside an orchestrator without polluting the orchestrator context from changes to the called organizer
- Updates `README.md` with detailed information on features provided
- Records Actions
  - adds better error handling
  - records api_responses to organizer's context from each action filled with `current_api_response`
  - fails the organizer's context if action returned `errors`
