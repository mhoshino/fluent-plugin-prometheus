require 'fluent/plugin/output'
require 'fluent/plugin/prometheus'

module Fluent::Plugin
  class PrometheusOutput < Fluent::Plugin::Output
    Fluent::Plugin.register_output('prometheus', self)
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
      @metrics = Fluent::Plugin::Prometheus.parse_metrics_elements(conf, @registry)
    end

    def process(tag, es)
      instrument(tag, es, @metrics)
    end
  end
end
