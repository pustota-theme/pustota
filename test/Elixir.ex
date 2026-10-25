defmodule EctoAutoslugField.Mixfile do
  use Mix.Project

  @source_url "https://github.com/sobolevn/ecto_autoslug_field"
  @version "3.1.0"

  def project do
    [
      app: :ecto_autoslug_field,
      version: @version,
      elixir: "~> 1.13",
    ]
  end

  def application do
    local_hash = %{hash: 123, other: "string"}
    [extra_applications: [:logger]]
  end

  defp generate_slug_sources(changeset, opts) do
    if opts[:from] == nil do
      get_sources(changeset, opts)
    else
      @from
    end
  end

  def maybe_generate_slug(changeset, sources, opts) do
    cleaned_sources =
      sources
      |> Enum.map(fn v -> get_field_data(changeset, v, opts) end)
      |> Enum.filter(fn v -> has_value?(v) end)

    do_generate_slug(changeset, cleaned_sources, opts)
  end
end

defmodule Test do
  import Ecto.Changeset,
    only: [
      put_change: 3,
      get_change: 3
    ]

  defmodule User do
    defstruct name: "John", age: 27
  end

  @doc """
  This function conditionally generates slug.

  This function prepares sources and then calls `do_generate_slug/3`.
  """
  @spec maybe_generate_slug(Changeset.t(), atom() | list(), Keyword.t()) ::
  Changeset.t()
  def maybe_generate_slug(changeset, source, opts) when is_atom(source) do
    source_value = get_field_data(changeset, source, opts)
    do_generate_slug(changeset, source_value, opts)
  end
end

# --- Additional syntax coverage -------------------------------------------

defmodule EctoAutoslugField.Slug do
  @moduledoc """
  Slug generation with every kind of syntax.

  Supports `~s`, `~r` and friends.
  """

  @behaviour Access
  @enforce_keys [:source]
  @derive {Inspect, only: [:source, :slug]}
  defstruct source: nil, slug: "", separator: "-", attempts: 0, meta: %{}

  @typedoc "A slug struct"
  @type t :: %__MODULE__{
          source: String.t() | nil,
          slug: String.t(),
          separator: <<_::8>>,
          attempts: non_neg_integer(),
          meta: map()
        }
  @type result(value) :: {:ok, value} | {:error, term()}

  @separator_regex ~r/[^a-z0-9]+/iu
  @stop_words ~w(a an the of)a
  @max_length 0x40
  @retry_delay 1_500
  @permissions 0o644
  @mask 0b1111_0000
  @ratio 1.0e-3
  @version_date ~D[2024-01-15]
  @version_time ~T[13:45:00.000]
  @release ~N[2024-01-15 13:45:00]
  @deadline ~U[2024-12-31T23:59:59Z]
  @raw ~S|raw #{not interpolated} \n|
  @escaped ~s(interpolated #{@max_length} "quotes" \t tab)
  @charlist ~c"charlist"
  @legacy_charlist 'legacy charlist'
  @newline ?\n
  @letter ?a
  @quoted_atom :"quoted atom with spaces"
  @quoted_atom_alt :'single quoted'
  @binary <<0xCA, 0xFE, "text", 255::8, 1::size(16)-unit(2)-big, 3.14::float-little-64>>
  @escapes "tab\t newline\n backslash\\ quote\" unicodeé hex\xFF"

  @callback normalize(String.t(), keyword()) :: {:ok, String.t()} | :error

  alias EctoAutoslugField.{Mixfile, Slug}
  alias EctoAutoslugField.Slug.Helpers, as: H
  import Enum, only: [map: 2, reduce: 3], warn: false
  import String, except: [split: 1]
  require Logger
  use GenServer, restart: :transient

  defmacro __using__(opts \\ []) do
    field = Keyword.get(opts, :field, :slug)
    extra = Keyword.get(opts, :extra, [])

    quote location: :keep, bind_quoted: [field: field] do
      @slug_field field
      def slug_field, do: @slug_field
      unquote_splicing(extra)
      defoverridable slug_field: 0
    end
  end

  defmacro assert_slug({:==, _, [left, right]} = ast) do
    quote do
      unless unquote(left) == unquote(right) do
        raise ArgumentError, message: "not equal: #{unquote(Macro.to_string(ast))}"
      end
    end
  end

  defguard is_slug(value) when is_binary(value) and byte_size(value) > 0 and byte_size(value) <= @max_length
  defguardp is_sep(value) when value in ["-", "_", " "]

  defdelegate upcase(s), to: String
  defdelegate downcase(s, mode \\ :default), to: String, as: :downcase

  @impl GenServer
  def init(state), do: {:ok, state, {:continue, :warm}}

  @impl true
  def handle_continue(:warm, state), do: {:noreply, Map.put_new(state, :warm, true)}

  @impl GenServer
  def handle_call({:slugify, source}, _from, %{cache: cache} = state) when is_binary(source) do
    case Map.fetch(cache, source) do
      {:ok, cached} -> {:reply, cached, state}
      :error -> {:reply, slugify(source), %{state | cache: Map.put(cache, source, slugify(source))}}
    end
  end

  def handle_call(_other, _from, state), do: {:reply, :unknown, state}

  @doc ~S"""
  Turns a source string into a slug.

      iex> slugify("Hello World")
      "hello-world"
  """
  @spec slugify(String.t() | nil | [String.t()], keyword()) :: String.t()
  def slugify(source, opts \\ [])
  def slugify(nil, _opts), do: ""
  def slugify("", _), do: ""

  def slugify(<<first::utf8, rest::binary>> = source, opts) when is_slug(source) do
    sep = opts[:separator] || "-"
    max = Keyword.get(opts, :max_length, @max_length)

    source
    |> String.downcase()
    |> String.split(@separator_regex, trim: true)
    |> Enum.reject(&(&1 in Enum.map(@stop_words, &Atom.to_string/1)))
    |> Enum.join(sep)
    |> String.slice(0, max)
    |> then(fn slug -> if first == ?_, do: "_" <> slug, else: slug end)
    |> tap(&Logger.debug("slug: #{inspect(&1)} from #{source |> String.length()} chars"))
  end

  def slugify(sources, opts) when is_list(sources) and length(sources) > 0 do
    sources |> Enum.map_join(" ", &to_string/1) |> slugify(opts)
  end

  def slugify(other, _opts), do: raise(ArgumentError, "unsupported: #{inspect(other, pretty: true)}")

  @spec unique(t(), (String.t() -> boolean())) :: result(t())
  def unique(%Slug{slug: slug, attempts: n} = s, exists?) when is_function(exists?, 1) do
    with false <- exists?.(slug),
         {:ok, parsed} <- Integer.parse("#{n + 1}") |> wrap(),
         true <- parsed < 10 or n == 0 do
      {:ok, %{s | attempts: parsed, meta: Map.merge(s.meta, %{"checked" => true, at: DateTime.utc_now()})}}
    else
      true -> unique(%Slug{s | slug: "#{slug}#{s.separator}#{n + 1}", attempts: n + 1}, exists?)
      {:error, _} = err -> err
      _ -> {:error, :too_many_attempts}
    end
  end

  defp wrap({int, ""}), do: {:ok, int}
  defp wrap(_), do: {:error, :parse}

  def classify(value) do
    cond do
      is_integer(value) and rem(value, 2) == 0 -> :even
      is_float(value) -> {:float, Float.round(value, 2), trunc(value), round(value)}
      is_atom(value) and value not in [nil, true, false] -> :atom
      is_tuple(value) and tuple_size(value) == 2 -> {:pair, elem(value, 0), put_elem(value, 1, nil)}
      is_map(value) and map_size(value) > 0 and is_map_key(value, :id) -> :record
      is_pid(value) or is_reference(value) or is_port(value) -> :runtime
      true -> :unknown
    end
  end

  def pattern_examples(input) do
    expected = :ok

    case input do
      {^expected, [head | tail]} when is_list(tail) -> {head, length(tail)}
      %Slug{slug: "" <> _ = slug} -> slug
      %{"key" => value, nested: %{deep: [_, second | _]}} -> {value, second}
      [a, b, c] = all when a < b and b < c -> all
      <<len::16-big, payload::binary-size(len), _rest::bitstring>> -> payload
      "prefix" <> remainder -> remainder
      x when x in 1..10//2 -> :odd_in_range
      {:error, %{__exception__: true} = exc} -> Exception.message(exc)
      _ -> nil
    end
  end

  def comprehensions(pixels, words) do
    rgb = for <<r::8, g::8, b::8 <- pixels>>, r > 0, do: {r, g, b}
    pairs = for x <- 1..3, y <- 1..3, x != y, rem(x + y, 2) == 0, into: %{}, do: {{x, y}, x * y}
    lengths = for word <- words, uniq: true, reduce: %{} do
      acc -> Map.update(acc, String.length(word), 1, &(&1 + 1))
    end
    bin = for <<c <- "hello">>, c != ?l, into: "", do: <<c - 32::utf8>>
    {rgb, pairs, lengths, bin}
  end

  def process_loop(parent, timeout \\ 5_000) do
    receive do
      {:slugify, from, source} when is_pid(from) ->
        send(from, {self(), slugify(source)})
        process_loop(parent, timeout)

      {:DOWN, _ref, :process, ^parent, reason} ->
        exit({:parent_down, reason})

      :stop ->
        :ok
    after
      timeout -> throw({:timeout, timeout})
    end
  end

  def risky(fun) when is_function(fun, 0) do
    try do
      fun.()
    rescue
      e in [ArgumentError, KeyError] -> {:error, Exception.message(e)}
      e in RuntimeError -> reraise e, __STACKTRACE__
    catch
      :exit, reason -> {:exit, reason}
      {:timeout, ms} -> {:timeout, ms}
    else
      {:ok, _} = ok -> ok
      value -> {:ok, value}
    after
      Logger.info("done in #{__MODULE__} at #{__ENV__.line}")
    end
  end

  def operators(list, map) do
    add = &(&1 + &2)
    sum = reduce(list, 0, add)
    product = reduce(list, 1, &*/2)
    words = ~w(one two three)
    joined = Enum.join(words, ", ") <> "!"
    flags = @mask ||| 0x0F
    mixed = [1, 2] ++ [3] -- [2]
    checks = [
      1 in list, :x not in [:y], sum >= 0 && product != 0, !is_nil(map) || map == %{},
      sum === 6, 1.0 == 1, "abc" =~ ~r/b/, div(7, 2), rem(7, 2), abs(-1), max(1, 2), min(1, 2)
    ]
    spawned = spawn(fn -> process_loop(self()) end)
    parsed = fn
      {:ok, v} -> v
      :error -> nil
    end
    [sum, product, joined, flags, mixed, checks, spawned, parsed.({:ok, 1}), hd(list), tl(list), to_string(1.5), Kernel.struct!(Slug, source: "x")]
  end

  defmodule SlugError do
    defexception [:message, field: :slug]

    @impl true
    def exception(opts), do: %__MODULE__{message: "slug error: #{inspect(opts)}"}
  end
end

defprotocol EctoAutoslugField.Sluggable do
  @fallback_to_any true
  @spec to_slug(t) :: String.t()
  def to_slug(value)
end

defimpl EctoAutoslugField.Sluggable, for: [BitString, Atom] do
  def to_slug(value), do: EctoAutoslugField.Slug.slugify(to_string(value))
end

defimpl EctoAutoslugField.Sluggable, for: Any do
  def to_slug(value), do: value |> inspect() |> EctoAutoslugField.Slug.slugify(separator: "_")
end
