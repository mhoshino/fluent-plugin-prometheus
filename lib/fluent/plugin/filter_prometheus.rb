require 'fluent/plugin/prometheus'
require 'fluent/plugin/filter'

module Fluent::Plugin
  class PrometheusFilter < Fluent::Plugin::Filter
    Fluent::Plugin.register_filter('prometheus', self)
    include Fluent::Plugin::Prometheus

    def initialize
      super
      @registry = ::Prometheus::Client.registry
    end

    def multi_workers_ready?
      true
    end

    def configure(conf)
      super

      placeholder_values = {
        'hostname' => @hostname,
        'worker_id' => fluentd_worker_id,
      }

      placeholders = @placeholder_expander.prepare_placeholders(placeholder_values)

      @metrics = Fluent::Plugin::Prometheus.parse_metrics_elements(conf, @registry , @placeholder_expander, placeholders)
    end

    def filter_stream(tag, es)
      instrument(tag, es, @metrics)
      es
    end
  end
end
