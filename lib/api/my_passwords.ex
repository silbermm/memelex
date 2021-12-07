defmodule Memex.My.Passwords do
  alias Memex.Env.PasswordManager

  # how close we need labels to be in our search algorithm
  @simularity_cutoff 0.72

  @creation_doc """
  Add a new password to the Memex.

  Takes a map with the following fields:
    * label (required)     - How we describe the password, e.g. "DigitalOcean"
    * username (required)  - The username associated with this password
    * password (required)  - The actual password to save
    * url                  - The URL where this password can be used
    * meta                 - Any additional metadata to store with the password
  """

  # API sugar
  @doc @creation_doc
  def new(params) do
    create(params)
  end

  # API sugar
  @doc @creation_doc
  def add(params) do
    create(params)
  end

  @doc @creation_doc
  def create(params) do
    new_password = Memex.Password.construct(params)
    {:ok, password} = GenServer.call(PasswordManager, {:new_password, new_password})
    password
  end

  # we have to pass in a real struct, to get the unredacted password ;)
  def find(%Memex.Password{} = password) do
    case GenServer.call(PasswordManager, {:find_unredacted_password, password}) do
      {:ok, %Memex.Password{} = unredacted_password} ->
        unredacted_password

      {:error, "password not found"} ->
        :not_found
    end
  end

  # search through the labels
  def find(search_term) when is_binary(search_term) do
    password =
      list()
      |> Enum.find(
        :not_found,
        &(String.jaro_distance(&1.label, search_term) > @simularity_cutoff)
      )

    if password == :not_found do
      :not_found
    else
      find(password)
    end
  end

  def find(params) do
    case GenServer.call(PasswordManager, {:find_password, params}) do
      {:ok, %Memex.Password{} = password} ->
        password

      {:error, "password not found"} ->
        :not_found
    end
  end

  def list do
    {:ok, passwords} = GenServer.call(PasswordManager, :list_passwords)
    passwords
  end

  def update(password, updates) do
    GenServer.call(PasswordManager, {:update_password, password, updates})
  end

  def delete(%Memex.Password{uuid: uuid} = password) do
    GenServer.call(PasswordManager, {:delete_password, password})
  end
end
