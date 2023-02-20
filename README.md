![LightService](https://raw.githubusercontent.com/adomokos/light-service/master/resources/light-service.png)

# Light Service Extensions

Aims to enhance [light-service](https://github.com/adomokos/light-service) to enhance this powerful and flexible service skeleton framework with an emphasis on simplicity

## Console
run `bin/console` for an interactive prompt.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'light-service-ext'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install light-service-ext

## ApplicationContext

> Adds useful defaults to the organizer/orchestrator context
- `:input` ~> values originally provided to organizer get moved here for better isolation
- `:params` 
  - stores values `filtered` and `mapped` from original `input`
  - outcomes/return values provided by any action that implements `LightServiceExt::ApplicationAction`
- `:errors`
  - validation errors processed by `LightServiceExt::ApplicationValidatorAction` [dry-validation](https://github.com/dry-rb/dry-validation) contract
  - manually added by an action e.g. `{ errors: { email: 'not found' } }`
- `:successful_actions` ~> provides a list of actions processed mostly useful for debugging purposes
- `:api_responses` ~> contains a list of external API interactions mostly for recording/debugging purposes
- `:allow_raise_on_failure` ~> determines whether or not to throw a `RaiseOnContextError` error up the stack in the case of validation errors and/or captured exceptions
- `:outcome` denotes the current status of the organizer with one of the following flags:
  - `LightServiceExt::Outcome::COMPLETE`

Example

````ruby
input = { order: order }
overrides = {} # optionally override `params`, `errors` and `allow_raise_on_failure`
LightServiceExt::ApplicationContext.make_with_defaults(input, overrides)

# => { input: { order: order },
#      params: {}, 
#      errors: {}, 
#      successful_actions: [], 
#      api_responses: [], 
#      allow_raise_on_failure: true 
#    }
````

#### Useful methods

- `.add_params(**params)`
  - Adds given args to context's `params` field
  - e.g. `add_params(user_id: 1) # => { params: { user_id: 1 } }`
- `.add_errors(**errors)`
  - Adds given args to to context's `errors` field
  - Fails and returns from current action/organizer's context
  - e.g. `add_to_errors(email: 'not found') # => { errors: { email: 'not found' } }`


## ApplicationOrganizer

> Adds the following support

### Useful methods

- `.reduce_if_success(<list of actions>)` prevents execution of action/step in the case of context failure or `:errors` present
- `.with_context(&block)` calls given block with `:ctx` argument
- `.execute_if` ~> Useful if you want the current `Organizer` to act as a `Orchestrator` and call another organizer
  - *ONLY* modifies the current organizer/orchestrator's as a result of executing `organizer_or_action_class_or_proc` if manually applied by a given `result_callback` Proc
  - Executed `steps` do modify the current organizer/orchestrator's context without the need for manual intervention
  - Arguments:
    - `condition_block` (required) ~> given block is called with current `context` argument
    - `organizer_or_action_class_or_proc` (required) ~> only executed if `condition_block` evaluates to `true`
      - must be one of `ApplicationOrganizer`, `ApplicationAction`, `Proc`
    - `apply_ctx_transform` (optional)
      - given block is called prior to `organizer_or_action_class_or_proc` being executed 
      - e.g. `apply_ctx_transform: -> (context) { context[:params][:user_id] = record(context)&.id }`
      - returned value gets passed to `organizer_or_action_class_or_proc` call
    - `result_callback` (optional)
      - given block is called after `organizer_or_action_class_or_proc` has been executed
      - Useful in the case where you want to augment the current organizer's context based on the context returned from the `organizer_or_action_class_or_proc` call
      - e.g. `result_callback: -> (ctx:, result:) { ctx[:params] = result[:params] }`
        - `ctx:` represents the main `organizer/orchestrator's` context
        - `result:` represents the context returned from the executed `organizer_or_action_class_or_proc`
    - `steps` (optional) ~> calls current `organizer/orchestrator's` actions/steps and called once `organizer_or_action_class_or_proc` has been processed
      - *PLEASE NOTE* called regardless of the result from the `organizer_or_action_class_or_proc` call unless you *manually* fail the current context or add `:errors`
  
#### Error Handling
> Provided by `.with_error_handler`

- Records errors via `issue_error_report!` into context as exemplified below:
```ruby
  {
    errors: {
            base: "some-exception-message",
            internal_only: {
                    type: 'ArgumentError',
                    message: "`user_id` must be a number",
                    exception: "ArgumentError : `user_id` must be a number",
                    backtrace: [], # filtered backtrace via `[ActiveSupport::BacktraceCleaner](https://api.rubyonrails.org/classes/ActiveSupport/BacktraceCleaner.html)`
                    error: original_captured_exception
            }
    }
  }
```

- Captures `model validation` exceptions and record the messages to the organizer's `:errors` context field
  - Supports the following exceptions by default
    - `ActiveRecord::Errors`
    - `ActiveModel::Errors`
- Raises any non validation errors up the stack

#### API Responses
- records api responses set by an action's `:api_response` context field
- Stored inside of the organizer's `:api_responses` field

#### Retrieve Record
> Allows for a block to be defined on an organizer in order to retrieve the model record

Example

```ruby
class TaxCalculator < LightServiceExt::ApplicationOrganizer
  self.retrieve_record = -> (ctx:) { User.find_by(email: ctx.params[:email]) }

  def self.call(input:)
    user = record(ctx: input) # `.record` method executes proc provided to `retrieve_record`
    input = { user: user }.merge(user: user)
    reduce_with({ input: input }, steps)
  end
end
```

#### Failing The Context
- Prevents further action's been executed in the following scenarios:
  - All actions complete determined by organizer's `:outcome` context field set to `LightServiceExt::Outcome::COMPLETE`

### ApplicationAction

#### Useful methods
- TODO

#### Invoked Action
- *NOTE* Action's `executed` block gets called by the underlying `LightService::Action`
  - this means in order to call your action's methods you need to invoke it from `invoked_action:` instead of `self`
- `invoked_action:` added to current action's context before it gets executed
  - Consist of an instance of the current action that implements `LightServiceExt::ApplicationAction`

## ApplicationContract

- Enhances `Dry::Validation::Contract` with the following methods:
  - `#keys` ~> returns names of params defined
  - `#t` ~> returns translation messages in context with the current organizer
    - Arguments:
      - `key` e.g. :not_found
      - `base_path:` e.g. :user
      - `**opts` options passed into underlying Rails i18n translate call
    - E.g. `t(:not_found, base_path: 'business_create', scope: 'user')` would execute
      - => `I18n.t('business_create.user.not_found', opts.except(:scope))`

## ApplicationValidatorAction

> Responsible for mapping, filtering and validating the context `input:` field

- `executed` block does the following:
  - Appends `params:` field to the current context with the mapped and filtered values
  - Appends errors returned from a `ApplicationContract` [dry-validation](https://github.com/dry-rb/dry-validation) contract to the current context's `errors:` field
    - *NOTE* fails current context if `errors:` present

##### Useful Accessors

- `.contract_class` ~> sets the [dry-validation](https://github.com/dry-rb/dry-validation) contract to be applied by the current validator action
- `.params_mapper_class` ~> sets the mapper class that must implement `.map_from(context)` and return mapped `:input` values

## ContextError

> Provides all the information related to an exception/validation errors captured by the current organizer

#### Useful methods
- `#error_info` ~> `ErrorInfo` instance
- `#context` ~> state of context provided
- `#error` ~> original exception
- `#message` ~> summarizes which action failed etc.

## ErrorInfo
- Summarize captured exception

#### Useful accessors
- `non_fatal_errors` ~> takes a list of error class names considered to be non fatal exceptions

#### Useful methods
- `#error` ~> captured exception
- `#type` ~> exception class name e.g. `ArgumentError`
- `#message` ~> error message
- `title` ~> combined error class name and error message e.g. `ArgumentError : email must be present`
- `#fatal_error?`
- `#error_summary` ~> summarizes exception with message and cleaned backtrace via `ActiveSupport::BacktraceCleaner`

## Regex

#### Useful methods
- `.match?(type, value)` e.g. `LightServiceExt::Regex.match?(email:, 'email@domain.com')`
  - supported `type`:
    - :email

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/light-service-ext. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/light-service-ext/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the LightServiceExt project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/light-service-ext/blob/master/CODE_OF_CONDUCT.md).
