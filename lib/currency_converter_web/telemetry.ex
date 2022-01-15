defmodule CurrencyConverterWeb.Telemetry do
  @moduledoc """
   Main instrumenter for this application. This is where we declare all metrics.
  """
  use Supervisor
  import Telemetry.Metrics

  @time_unit {:native, :millisecond}

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl Supervisor
  def init(_arg) do
    children = [
      # Telemetry poller will execute the given period measurements
      # every 10_000ms. Learn more here: https://hexdocs.pm/telemetry_metrics
      {:telemetry_poller, measurements: periodic_measurements(), period: 10_000}
      # Add reporters as children of your supervision tree.
      # {Telemetry.Metrics.ConsoleReporter, metrics: metrics()}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  @spec buckets() :: list()
  defp buckets do
    [
      50,
      100,
      250,
      500,
      1_000,
      2_000,
      3_000,
      4_000,
      5_000,
      6_000,
      7_000,
      8_000,
      9_000,
      10_000
    ]
  end

  @spec metrics :: [Telemetry.Metrics.t(), ...]
  def metrics do
    [
      # Tesla
      # Metrics scoped by method/url
      last_value([:tesla, :request, :stop, :duration],
        tags: [:method, :url, :error, :status],
        tag_values: fn meta ->
          %{
            method: meta.env.method,
            url: meta.env.url,
            status: meta.env.status,
            error: meta[:error]
          }
        end,
        unit: @time_unit
      ),
      last_value([:tesla, :request, :exception, :duration],
        tags: [:kind, :reason],
        unit: @time_unit
      ),
      # Phoenix Metrics
      summary("phoenix.endpoint.stop.duration",
        unit: @time_unit,
        tags: [:route, :status, :controller, :method],
        tag_values: &get_phoenix_tags/1,
        reporter_options: [buckets: buckets()]
      ),
      summary("phoenix.router_dispatch.stop.duration",
        tags: [:route],
        unit: @time_unit
      ),

      # Database Metrics
      summary("currency_converter.repo.query.total_time",
        unit: @time_unit,
        description: "The sum of the other measurements"
      ),
      summary("currency_converter.repo.query.decode_time",
        unit: @time_unit,
        description: "The time spent decoding the data received from the database"
      ),
      summary("currency_converter.repo.query.query_time",
        unit: @time_unit,
        description: "The time spent executing the query"
      ),
      summary("currency_converter.repo.query.queue_time",
        unit: @time_unit,
        description: "The time spent waiting for a database connection"
      ),
      summary("currency_converter.repo.query.idle_time",
        unit: @time_unit,
        description:
          "The time the connection spent waiting before being checked out for the query"
      ),

      # Oban
      last_value("oban.job.stop.duration",
        unit: @time_unit,
        tag_values: &get_oban_tags/1,
        tags: [:job_module, :queue]
      ),
      last_value("oban.job.stop.queue_time",
        unit: @time_unit,
        tag_values: &get_oban_tags/1,
        tags: [:job_module, :queue]
      ),
      last_value("oban.job.exception.queue_time",
        unit: @time_unit,
        tag_values: &get_oban_tags/1,
        tags: [:kind, :job_module, :queue]
      ),
      last_value("oban.job.duration.queue_time",
        unit: @time_unit,
        tag_values: &get_oban_tags/1,
        tags: [:kind, :job_module, :queue]
      ),
      last_value("oban.producer.stop.duration",
        unit: @time_unit,
        tags: [:action, :queue]
      ),
      counter("oban.circuit.trip", tags: [:name, :error]),

      # VM Metrics
      last_value("vm.memory.total", unit: {:byte, :kilobyte}),
      last_value("vm.memory.atom", unit: {:byte, :kilobyte}),
      last_value("vm.memory.atom_used", unit: {:byte, :kilobyte}),
      last_value("vm.memory.binary", unit: {:byte, :kilobyte}),
      last_value("vm.memory.ets", unit: {:byte, :kilobyte}),
      last_value("vm.memory.processes"),
      last_value("vm.total_run_queue_lengths.total"),
      last_value("vm.total_run_queue_lengths.cpu"),
      last_value("vm.total_run_queue_lengths.io"),
      last_value([:vm, :reductions, :total], description: "Total reduction count since startup"),
      last_value([:vm, :reductions, :current], description: "Reduction count since last check")
    ]
  end

  defp periodic_measurements do
    []
  end

  defp get_oban_tags(meta) do
    %{
      queue: meta.queue,
      kind: meta[:kind],
      job_module: meta.worker
    }
  end

  defp get_phoenix_tags(meta) do
    conn = meta[:conn] || %{}

    method = conn[:method] || ""
    status = conn[:status] || ""
    path = conn[:request_path] || ""
    kind = meta[:kind] || ""

    case Phoenix.Router.route_info(CurrencyConverterWeb.Router, method, path, nil) do
      %{route: route, plug: controller} ->
        %{
          error_kind: kind,
          route: route,
          controller: controller,
          method: method,
          status: status
        }

      _ ->
        %{
          error_kind: kind,
          route: nil,
          controller: nil,
          method: method,
          status: status
        }
    end
  end
end
