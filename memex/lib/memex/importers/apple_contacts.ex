defmodule Memex.Importers.AppleContacts do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Memex.Connector

  def provider, do: "Contacts"

  def default_config do
    %{
      "location" =>
        "#{System.user_home!()}/Library/Application\ Support/AddressBook/Sources/AAE8D6A5-FEED-47BB-82CF-1A51C6789400/AddressBook-v22.abcddb"
    }
  end

  defmodule Contact do
    @moduledoc false
    use Ecto.Schema

    @derive Jason.Encoder
    embedded_schema do
      field :first_name, :string
      field :last_name, :string
      field :phone_number, :string
      field :email_address, :string
    end

    def contacts_by_ids(ids) do
      String.replace(
        """
          SELECT
            json_object(
              'id', record.ZUNIQUEID,
              'first_name', record.ZFIRSTNAME,
              'last_name', record.ZLASTNAME,
              'phone_number', REPLACE(phone.ZFULLNUMBER, ' ', ''),
              'email_address', email.ZADDRESSNORMALIZED
            ) AS json
          FROM ZABCDRECORD AS record
          LEFT JOIN ZABCDPHONENUMBER AS phone ON phone.ZOWNER = record.Z_PK
          LEFT JOIN ZABCDEMAILADDRESS AS email ON email.ZOWNER = record.Z_PK
          WHERE record.ZUNIQUEID IN (?)
        """,
        "IN (?)",
        "IN ('#{Enum.join(ids, "','")}')"
      )
    end
  end

  # A importer can define enrichment functions that are used on results.
  # This function is with a list of itesm that were returned from the database.
  # It can be used to enrich the data with additional information from other sources.
  # The function should return the enriched item.

  # For example, this module can define that the `person_id` field can be enriched with information
  # from the `contacts` app database. It can return a custom data structure that is then merged.
  def enrich(items, config) do
    ids =
      items
      |> Enum.map(& &1["person_id"])
      |> Enum.filter(&(&1 != nil))
      |> Enum.uniq()

    # if the list ids is not empty
    with true <- Enum.count(ids) > 0,
         {:ok, results} <-
           Connector.sqlite_json(config["location"], Contact.contacts_by_ids(ids), [], [], journal_mode: :wal) do
      contacts =
        results
        |> Enum.map(fn item ->
          changeset = cast(%Contact{}, item, Contact.__schema__(:fields))

          if changeset.valid? do
            apply_changes(changeset)
          end
        end)
        |> Enum.reduce(%{}, fn item, acc -> Map.put(acc, item.id, item) end)

      Enum.map(items, fn item -> put_in(item, ["_enrichment"], get_in(contacts, [item["person_id"]])) end)
    else
      _ -> items
    end
  end

  defmodule TimeLineItemRight do
    @moduledoc false
    use Surface.Component

    prop item, :map, required: true

    def render(assigns) do
      ~F"""
      <button
        :for={person <- @item["_enrichment"]}
        phx-click="open-sidebar"
        phx-value-type="person"
        phx-value-name={person["name"]}
        class="inline-flex items-center justify-center text-xs px-3 pr-1 py-1 dark:bg-gray-800 rounded-full"
      >{person["first_name"]} <svg
          xmlns="http://www.w3.org/2000/svg"
          width="12"
          height="12"
          class="ml-1 text-gray-400 dark:text-gray-700"
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
        ><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" /></svg></button>
      """
    end
  end
end
