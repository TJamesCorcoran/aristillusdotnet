# frozen_string_literal: true

require 'stripe'

module Api
  module V1
    # allow someone to create a new subscription / payment
    class PaymentsController < ApplicationController
      def create_subscription
        # Create a customer (if one doesn't exist)
        customer = Stripe::Customer.create(email: @user.email, name: @user.name)

        # Attach the payment method to the customer
        payment_method = Stripe::PaymentMethod.attach(
          params[:payment_method_id], # From frontend (Stripe Element)
          { customer: customer.id }
        )

        # Set the payment method as the default for invoices
        stripe_customer = Stripe::Customer.update(
          customer.id,
          {
            invoice_settings: { default_payment_method: params[:payment_method_id] }
          }
        )

        membership_tier = Membership.find(params[:membership_id])
        raise 'no such tier found' unless membership_tier

        stripe_price = Stripe::Price.create({
                                              currency: 'usd',
                                              unit_amount_decimal: membership_tier.price * 100,
                                              recurring: { interval: 'month' },
                                              product_data: { name: membership_tier.name }
                                            })

        # Create a subscription
        subscription = Stripe::Subscription.create(
          customer: stripe_customer.id,
          items: [{
            metadata: { name: membership_tier.name },
            price: stripe_price.id
          }], # Use the Stripe price ID for your plan
          collection_method: 'charge_automatically',
          default_payment_method: payment_method.id,
          payment_behavior: 'default_incomplete', # 'error_if_incomplete',
          expand: ['latest_invoice.payment_intent'] # Include the payment intent for handling frontend confirmation
        )

        # Send the client_secret back to the frontend to confirm payment
        render json: { success: true,
                       data: { client_secret: subscription.latest_invoice.payment_intent.client_secret } }
      rescue StandardError => e
        render json: { success: false, error: e.message }
      end
    end
  end
end
