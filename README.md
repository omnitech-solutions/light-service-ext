![LightService](https://raw.githubusercontent.com/adomokos/light-service/master/resources/light-service.png)

# Light Service Extensions

Aims to enhance [light-service](https://github.com/adomokos/light-service) to enhance this powerful and flexible service skeleton framework with an emphasis on simplicity

## Console
run `bin/console` for an interactive prompt.

## Generators
`LightServiceExt::Generators::LightServiceGenerator` automates scaffolding of service
objects. Provide a resource name and a DTO class and it creates organizers,
a validator action and a DTO template under `services/`.

The `my_codegen_app.rb` script offers a simple Thor CLI to scaffold plain Ruby
models. Run `ruby my_codegen_app.rb model user name email` to generate
`user.rb` using the template in `lib/templates/model.rb.erb`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'light-service-ext'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install light-service-ext

## ApplicationOrganizer
> Adds the following support

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

#### Failing The Context
- Prevents further action's been executed in the following scenarios:
  - All actions complete determined by organizer's `:outcome` context field set to `LightServiceExt::Outcome::COMPLETE`

#### Example

```ruby
class TaxCalculator < LightServiceExt::ApplicationOrganizer
  self.retrieve_record = -> (ctx:) { User.find_by(email: ctx.params[:email]) }

  def self.call(input)
    user = record(ctx: input) # `.record` method executes proc provided to `retrieve_record`
    input = { user: user }.merge(input)
    
    super(input)
  end
  
  def self.steps
    [TaxValidator, CalcuateTaxAction]
  end
end
```

## ApplicationOrchestrator
> Useful if you want the current `Organizer` to act as a `Orchestrator` and call another organizer

- *ONLY* modifies the orchestrator context from executing `organizer_steps` if manually applied via `each_organizer_result` Proc

### method overrides
- `organizer_steps` ~ must be a list of organizers to be called prior to orchestrator's actions

### Example

```ruby
class TaxCalculatorReport < LightServiceExt::ApplicationOrchestrator
  self.retrieve_record = -> (ctx:) { User.find_by(email: ctx.params[:email]) }

  def self.call(input)
    user = record(ctx: input) # `.record` method executes proc provided to `retrieve_record`
    input = { user: user }.merge(user: user)
    reduce_with({ input: input }, steps)
    
    super(input.merge({ user: user })) do |current_organizer_ctx, orchestrator_ctx:|
      orchestrator_ctx.add_params(current_organizer_ctx.params.slice(:user_id)) # manually add params from executed organizer(s) 
    end
  end

  def organizer_steps
    [TaxCalculator]
  end

  def steps
    [TaxReportAction]
  end
end
```

## ApplicationAction

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

 
## ApplicationContext

> Adds useful defaults to the organizer/orchestrator context
- `:input` ~> values originally provided to organizer get moved here for better isolation
- `:params` 
  - stores values `filtered` and `mapped` from original `input`
  - outcomes/return values provided by any action that implements `LightServiceExt::ApplicationAction`
- `:errors`
  - validation errors processed by `LightServiceExt::ApplicationValidatorAction` [dry-validation](https://github.com/dry-rb/dry-validation) contract
  - manually added by an action e.g. `{ errors: { email: 'not found' } }`
- `:successful_actions` ~> provides a list of actions processed mostly useful for debugging purposes e.g. `['SomeActionClassName']`
- `invoked_action` ~> instance of action to being called.
- `:current_api_response` ~> action issued api response
- `:api_responses` ~> contains a list of external API interactions mostly for recording/debugging purposes (**internal only**)
- `:allow_raise_on_failure` ~> determines whether or not to throw a `RaiseOnContextError` error up the stack in the case of validation errors and/or captured exceptions
- `:status` denotes the current status of the organizer with one of the following flags:
  - `LightServiceExt::Status::COMPLETE`
  - `LightServiceExt::Status::INCOMPLETE`
- `:last_failed_context` ~ copy of context that failed e.g. with `errors` field present
- `internal_only` ~ includes the likes of raised error summary and should never be passed to endpoint responses
- `meta` ~ used to store any additional information that could be helpful especially for debugging purposes.
Example

````ruby
input = { order: order }
overrides = {} # optionally override `params`, `errors` and `allow_raise_on_failure`
meta = { current_user_id: 12345, request_id: some-unique-request-id, impersonator_id: 54321 }
LightServiceExt::ApplicationContext.make_with_defaults(input, overrides, meta: meta)

# => { input: { order: order },
#      errors: { email: ['not found'] },
#      params: { user_id: 1 },
#      status: Status::INCOMPLETE,
#      invoked_action: SomeActionInstance,
#      successful_actions: ['SomeActionClassName'],
#      current_api_response: { user_id: 1, status: 'ACTIVE' },
#      api_responses: [ { user_id: 1, status: 'ACTIVE' } ],
#      last_failed_context: {input: { order: order }, params: {}, ...},
#      allow_raise_on_failure: true,
#      internal_only: { error_info: ErrorInfoInstance },
#     meta: { current_user_id: 12345, request_id: some-unique-request-id, impersonator_id: 54321 }
#    }
````

#### Useful methods
- `.add_params(**params)`
  - Adds given args to context's `params` field
  - e.g. `add_params(user_id: 1) # => { params: { user_id: 1 } }`

- `add_errors!`
  - Adds given args to to context's `errors` field
  - Fails and returns from current action/organizer's context
  - e.g. `add_to_errors!(email: 'not found') # => { errors: { email: 'not found' } }`

- `.add_errors(**errors)`
  - Adds given args to to context's `errors` field
  - DOES NOT fails current context
  - e.g. `add_to_errors(email: 'not found') # => { errors: { email: 'not found' } }`

- `.add_status(status)`
  - Should be one of Statuses e.g. `Status::COMPLETE` 
  - e.g. `add_status(Status::COMPLETE) # => { status: Status::COMPLETE }`

- `.add_internal_only(attrs)`
  - e.g. `add_internal_only(request_id: 54) # => { internal_only: { error_info: nil, request_id: 54 }  }`
- `add_to_successful_actions(action_name_or_names)` ~> adds action names successfully executed

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
