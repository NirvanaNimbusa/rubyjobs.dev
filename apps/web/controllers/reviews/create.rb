# frozen_string_literal: true

module Web
  module Controllers
    module Reviews
      class Create
        include Web::Action
        include Dry::Monads::Result::Mixin
        include Import[
          :rollbar, :logger,
          operation: 'reviews.operations.create'
        ]

        def call(params) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
          result = operation.call(company_id: params[:company_id], review: params[:review])

          case result
          when Success
            flash[:success] = 'Отзыв успешно создан.'
          when Failure
            flash[:fail] = 'Произошла ошибка, пожалуйста повторите позже'
            logger.error("fail on review create, params: #{params.to_h}, result: #{result.failure}")
            rollbar.error(result.failure, payload: params.to_h)
          end

          redirect_to routes.company_path(params[:company_id])
        end
      end
    end
  end
end
