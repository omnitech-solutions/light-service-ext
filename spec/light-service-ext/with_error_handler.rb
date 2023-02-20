module WithErrorHandler
  def with_error_handler(ctx:, &block)
    @result = block.call || {}
  rescue Rails::ActiveRecordError => e
    errors = errors_from(e)
    add_errors(ctx: ctx, **errors)
    add_errors(ctx: @result, **errors)

    issue_error_report!(e, ctx: ctx, include_internal_only: false)

    ctx.fail!
    ctx
  rescue StandardError => e
    issue_error_report!(e, ctx: ctx)

    raise
  end

  def errors_from(exception)
    model = exception&.model || exception&.record
    return model.errors.messages.transform_values(&:first) if model.present?

    { base: exception.message }
  end
end
