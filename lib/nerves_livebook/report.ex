defmodule NervesLivebook.Report do
  use GenServer
  use Toolshed
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, opts)
  end

  @impl true
  def init(_) do
    Process.send_after(self(), :try, 1)
    Delux.start_link(
      indicators: %{
        default: %{red: "led0:red", green: "led0:green", blue: "led0:blue"}
      }
    )

    Delux.render(%{
      default: Delux.Effects.on(:white)
    })

    {:ok, false}
  end

  @impl true
  def handle_info(:try, _reported?) do
    case Req.get("http://192.168.3.98:5003/#{hostname()}", retry: false) do
      {:ok, _} ->
        Delux.render(%{
          default: Delux.Effects.cycle([:black, :white], 1)
        })
        {:noreply, true}
      _ ->
        Process.send_after(self(), :try, 1000)
        {:noreply, false}
    end
  end
end
