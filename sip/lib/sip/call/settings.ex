defmodule Membrane.RTC.Engine.Endpoint.SIP.Call.Settings do
  @moduledoc false

  alias Membrane.RTC.Engine.Endpoint.SIP.RegistrarCredentials

  @type t :: %__MODULE__{
          endpoint: pid(),
          rtp_port: 1..65_535,
          sip_port: 1..65_535,
          registrar_credentials: RegistrarCredentials.t(),
          external_ip: String.t(),
          register_interval_ms: non_neg_integer(),
          phone_number: String.t() | nil
        }

  @enforce_keys [
    :endpoint,
    :rtp_port,
    :sip_port,
    :registrar_credentials,
    :external_ip,
    :register_interval_ms,
    :phone_number
  ]

  defstruct @enforce_keys

  @spec new(struct()) :: t()
  def new(endpoint_state) do
    endpoint_state
    |> Map.from_struct()
    |> Map.put(:endpoint, self())
    |> then(&struct(Call.Settings, &1))
  end
end
