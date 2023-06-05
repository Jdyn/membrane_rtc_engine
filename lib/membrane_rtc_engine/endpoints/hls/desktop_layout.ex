if Code.ensure_loaded?(Membrane.VideoCompositor) do
  defmodule Membrane.RTC.Engine.Endpoint.HLS.DesktopLayout do
    @moduledoc """
    Module representing function for updating video layout for the HLS stream.

    ```ascii
    1) Only main presenter
         _ _ _ _ _ _ _ _ _
        |                 |
        |                 |
        |                 |
        |                 |
        |                 |
         - - - - - - - - -
    2) Main presenter and one side presenter
         _ _ _ _ _ _ _ _ _
        |           |     |
        |            - - -|
        |                 |
        |                 |
        |                 |
         - - - - - - - - -

    3) Main presenter and two side presenters
         _ _ _ _ _ _ _ _ _
        |           |     |
        |            - - -|
        |           |     |
        |            - - -|
        |                 |
         - - - - - - - - -
    ```
    """
    @behaviour Membrane.RTC.Engine.Endpoint.HLS.CustomLayoutMaker

    @impl true
    def track_stream_format(%{width: width, height: height}, _track_no, padding),
      do: %{
        width: round(1 / 5 * width) - padding * 2,
        height: round(1 / 4 * height) - padding * 2
      }

    @impl true
    def track_stream_position(%{width: width, height: height}, track_no, padding),
      do: {round(4 / 5 * width) + padding, height - round((4 - track_no) / 4 * height) + padding}
  end
end