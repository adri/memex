defmodule Memex.Vault do
  use Cloak.Vault, otp_app: :memex

  @impl GenServer
  def init(config) do
    config =
      Keyword.put(config, :ciphers,
        default:
          {Cloak.Ciphers.AES.GCM, tag: "AES.GCM.V1", key: decode_env!("SECRETS_ENCRYPTION_KEY")}
      )

    {:ok, config}
  end

  defp decode_env!(var) do
    var
    |> System.get_env()
    |> Base.decode64!()
  end
end
