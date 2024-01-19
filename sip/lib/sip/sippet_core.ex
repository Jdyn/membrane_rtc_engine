defmodule Membrane.RTC.Engine.Endpoint.SIP.SippetCore do
  @moduledoc false

  use Sippet.Core

  require Membrane.Logger

  alias Membrane.Logger
  alias Membrane.RTC.Engine.Endpoint.SIP.Call

  @sippet_id __MODULE__
  @default_sip_address "0.0.0.0"
  @default_sip_port 5060

  @spec setup() :: :ok
  def setup() do
    transport_opts = [
      address: Application.get_env(:membrane_rtc_engine_sip, :sip_address, @default_sip_address),
      port: Application.get_env(:membrane_rtc_engine_sip, :sip_port, @default_sip_port)
    ]

    {:ok, _pid} = Sippet.start_link(name: @sippet_id)
    {:ok, _pid} = Sippet.Transports.UDP.start_link([name: @sippet_id] ++ transport_opts)
    Sippet.register_core(@sippet_id, __MODULE__)
  end

  @spec send_message(Sippet.Message.t()) :: :ok | {:error, term()}
  def send_message(message) do
    Sippet.send(@sippet_id, message)
  end

  @impl true
  def receive_request(
        %Sippet.Message{start_line: %{method: method}} = incoming_request,
        server_key
      ) do
    Logger.debug(
      "Sippet receive_request (server_key=#{inspect(server_key)}): #{inspect(incoming_request)}"
    )

    call_id = Sippet.Message.get_header(incoming_request, :call_id)

    cond do
      # We don't support incoming calls until new sip client implementation
      Call.exists?(call_id) ->
        Call.handle_request(call_id, incoming_request)

      method == :notify ->
        incoming_request
        |> Sippet.Message.to_response(200)
        |> send_message()

      true ->
        Logger.warning("""
          SIP client: Call #{inspect(call_id)} doesn't exist. Incoming calls are unsupported
        """)
    end
  end

  @impl true
  def receive_response(incoming_response, client_key) do
    Logger.debug(
      "Sippet receive_response (client_key=#{inspect(client_key)}): #{inspect(incoming_response)}"
    )

    Call.handle_response(incoming_response.headers.call_id, incoming_response)
  end

  @impl true
  def receive_error(reason, client_or_server_key) do
    Logger.warning("""
      SIP client: Received an error (key=#{inspect(client_or_server_key)}): #{inspect(reason)}
    """)

    # XXX: Routing this error would necessitate running a unique process
    # which would hold the mapping %{transaction_key => call_id} GLOBALLY,
    # for all SIP Endpoints on the machine. This seems like an anti-pattern...
  end
end
