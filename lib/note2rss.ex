defmodule Note2rss do
  def outlines_from_per_page(url) do
    case HTTPoison.get(url) do
      {:ok, %{body: body}} ->
        subscription_outlines(body)

      {:error, _} ->
        []
    end
  end

  defp subscription_outlines(html) do
    case Floki.parse_document(html) do
      {:ok, document} ->
        Floki.find(document, ".m-userListItem__link")
        |> Enum.map(&subscription_outline/1)

      {:error, _} ->
        []
    end
  end

  defp subscription_outline(node) do
    title = Floki.attribute(node, "aria-label")

    htmlUrl =
      Floki.attribute(node, "href")
      |> List.first()
      |> html_url()

    rssUrl = rss_url(htmlUrl)

    {:outline,
     %{
       "type" => "rss",
       "text" => title,
       "title" => title,
       "xmlUrl" => rssUrl,
       "htmlUrl" => htmlUrl
     }}
  end

  def write(username, pages \\ 1) do
    char_data =
      1..pages
      |> Enum.map(&followings_url(username, &1))
      |> Enum.flat_map(&outlines_from_per_page/1)
      |> opml()

    case File.write("note.opml", char_data) do
      :ok -> IO.puts("note.opml is written.")
      {:error, reason} -> IO.puts("Failed to write note.opml: #{reason}")
    end
  end

  defp followings_url(username, pages) do
    "https://note.com/#{username}/followings?page=#{pages}"
  end

  defp rss_url(html_url) do
    html_url <> "/rss"
  end

  defp html_url(href) do
    if String.starts_with?(href, "/") do
      "https://note.com" <> href
    else
      href
    end
  end

  defp opml(subscription_outlines) do
    {
      "opml",
      [
        {"version", "1.0"},
        {"xmlns:atom", "http://www.w3.org/2005/Atom"},
        {"xmlns:opml", "http://opml.org/spec2"}
      ],
      [
        {:head, [],
         [
           {:title, [], "Note2rss"},
           {:dateCreated, [], DateTime.utc_now() |> DateTime.to_iso8601()}
         ]},
        {:body, [],
         [
           {:outline, %{title: "note", text: "note"}, subscription_outlines}
         ]}
      ]
    }
    |> XmlBuilder.document()
    |> XmlBuilder.generate()
  end
end
