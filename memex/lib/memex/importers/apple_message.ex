defmodule Memex.Importers.AppleMessages do
  alias Memex.Importer

  use Ecto.Schema
  @primary_key false
  schema "document" do
    field :provider, :string
    field :verb, :string
    field :id, :string
    field :date_month, :string
    field :timestamp_utc, :string
    field :timestamp_unix, :integer
    field :message_direction, :string
    field :message_service, :string
    field :message_text, :string
    field :person_name, :string
    field :person_id, :string
  end

  def provider(), do: "iMessage"

  def default_config() do
    %{
      "location" => "#{System.user_home!()}/Library/Messages/chat.db",
      "contacts_db" =>
        "#{System.user_home!()}/Library/Application Support/AddressBook/Sources/AAE8D6A5-FEED-47BB-82CF-1A51C6789400/AddressBook-v22.abcddb",
      "schedule" => :watcher
    }
  end

  def fetch(config) do
    date_correction = "/ 1000000000 + 978307200"

    %Importer.Sqlite{
      location: config["location"],
      connection_options: [
        journal_mode: :wal
      ],
      setup: [
        """
        ATTACH DATABASE '#{config["contacts_db"]}' as contacts;
        """
      ],
      query: """
      WITH contact AS (
        SELECT
          record.ZUNIQUEID as id,
          record.ZFIRSTNAME AS first_name,
          record.ZLASTNAME AS last_name,
          REPLACE(phone.ZFULLNUMBER, ' ', '') AS phone_number,
          email.ZADDRESSNORMALIZED AS email_address
        FROM
          contacts.ZABCDRECORD AS record
        LEFT JOIN contacts.ZABCDPHONENUMBER AS phone ON phone.ZOWNER = record.Z_PK
        LEFT JOIN contacts.ZABCDEMAILADDRESS AS email ON email.ZOWNER = record.Z_PK
      )
      SELECT
        json_object(
          'provider', 'iMessage',
          'verb', 'messaged',
          'id', 'imessage-' || message.guid,
          'date_month', strftime('%Y-%m', message.date #{date_correction}, 'unixepoch'),
          'timestamp_utc', datetime(message.date #{date_correction}, 'unixepoch'),
          'timestamp_unix', CAST(strftime('%s', datetime(message.date #{date_correction}, 'unixepoch')) as INT),
          'message_direction', (CASE WHEN message.is_from_me THEN 'sent' ELSE 'received' END),
          'message_service', chat.service_name,
          'message_text', message.text,
          'person_name', CASE WHEN contact.first_name IS NULL AND contact.last_name IS NULL THEN chat.chat_identifier ELSE contact.first_name || ' ' || contact.last_name END,
          'person_id', contact.id
        ) AS json
      FROM
        main.chat chat
        JOIN chat_message_join ON chat.ROWID = chat_message_join.chat_id
        JOIN message ON chat_message_join.message_id = message.ROWID
        LEFT JOIN contact ON contact.phone_number = chat.chat_identifier OR contact.email_address = chat.chat_identifier
      WHERE message.text IS NOT NULL
      GROUP BY message.guid
      """
    }
  end

  defmodule TimeLineItem do
    use Surface.Component

    prop item, :map, required: true

    def render(assigns) do
      ~F"""
      <div class="text-xs text-gray-400 dark:text-gray-500 truncate">
        {case @item["message_direction"] do
          "sent" -> "Sent to "
          "received" -> "Received from "
        end}
        {raw(@item["_formatted"]["person_name"])}
      </div>
      {raw(@item["_formatted"]["message_text"])}
      """
    end
  end
end
