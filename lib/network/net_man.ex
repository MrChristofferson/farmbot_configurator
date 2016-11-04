defmodule NetMan do
  @dnsmasq_file Application.get_env(:fb, :dnsmasq_path)
  use GenServer
  require Logger

  def init(:prod) do
    # {current state, callback}
    {:ok, {nil, nil}}
  end

  def init(:dev) do
    # {current state, callback}
    {:ok, {:dev, nil}}
  end

  def start_link(args) do
    System.cmd("epmd", ["-daemon"])
    GenEvent.add_handler(Nerves.NetworkInterface.event_manager(), Network.EventManager, nil)
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  defp start_wifi_client(ssid, pass) when is_bitstring(ssid) and is_bitstring(pass) do
     spawn_link fn -> Nerves.InterimWiFi.setup "wlan0", ssid: ssid, key_mgmt: :"WPA-PSK", psk: pass end
  end

  defp start_ethernet do
    spawn_link fn -> Nerves.InterimWiFi.setup "eth0" end
  end

  # Blatently ripped off from @joelbyler
  # https://github.com/joelbyler/elixir_conf_chores/blob/f13298f9185b850fdfaad0448f03a03b3067a85c/apps/firmware/lib/firmware.ex
  defp start_hostapd_deps do
    System.cmd("ip", ["link", "set", "wlan0", "up"]) |> print_cmd_result
    System.cmd("ip", ["addr", "add", "192.168.24.1/24", "dev", "wlan0"]) |> print_cmd_result
    System.cmd("dnsmasq", ["--dhcp-lease", @dnsmasq_file]) |> print_cmd_result
  end


  defp start_hostapd do
    System.cmd("hostapd", ["-B", "-d", "/etc/hostapd/hostapd.conf"]) |> print_cmd_result
  end

  def handle_cast({:connect, _, pid}, {:dev, _}) do
    spawn(fn ->
      NetMan.on_ip("localhost")
    end)
    {:noreply, {:dev, pid}}
  end

  # If bot State has no previous state
  def handle_cast({:connect, nil, pid}, {nil, nil}) do
    start_hostapd_deps
    start_hostapd
    {:noreply, {:hostapd, pid}}
  end

  # Login from configurator
  def handle_cast({:connect, {ssid, pass}, pid}, {:hostapd, _}) do
    Logger.debug("trying to switch from hostapd to wpa_supplicant ")
    System.cmd("sh", ["-c", "killall hostapd"]) |> print_cmd_result
    System.cmd("sh", ["-c", "killall dnsmasq"]) |> print_cmd_result
    File.rm(@dnsmasq_file)
    System.cmd("ip", ["link", "set", "wlan0", "down"]) |> print_cmd_result
    System.cmd("ip", ["addr", "del", "192.168.24.1/24", "dev", "wlan0"]) |> print_cmd_result
    System.cmd("ip", ["link", "set", "wlan0", "up"]) |> print_cmd_result
    start_wifi_client(ssid, pass)
    {:noreply, {{ssid, pass}, pid}}
  end

  # If hostapd isnt started.
  def handle_cast({:connect, {ssid, pass}, pid}, {nil, _}) do
    start_wifi_client(ssid, pass)
    {:noreply, {{ssid, pass}, pid}}
  end

  # Login from configurator
  def handle_cast({:connect, :ethernet, pid}, {:hostapd, _}) do
    Logger.debug("trying to switch from hostapd to ethernet ")
    System.cmd("sh", ["-c", "killall hostapd"]) |> print_cmd_result
    System.cmd("sh", ["-c", "killall dnsmasq"]) |> print_cmd_result
    File.rm(@dnsmasq_file)
    System.cmd("ip", ["link", "set", "wlan0", "down"]) |> print_cmd_result
    System.cmd("ip", ["addr", "del", "192.168.24.1/24", "dev", "wlan0"]) |> print_cmd_result
    System.cmd("ip", ["link", "set", "wlan0", "up"]) |> print_cmd_result
    start_ethernet
    {:noreply, {:ethernet, pid}}
  end

  def handle_cast({:connect, :ethernet, pid}, {nil, _}) do
    start_ethernet
    {:noreply, {:ethernet, pid}}
  end

  # When we get a valid connection
  # def handle_cast({:on_ip, "192.168.29.185"}, {:ethernet, BotState})
  def handle_cast({:on_ip, addr}, {c, pid} ) do
    send(pid, {:connected, c, addr})
    {:noreply, {c, pid}}
  end

  def handle_cast(:bad_key, {c, pid}) do
    send(pid, :bad_key)
    {:noreply, {c, pid}}
  end

  def handle_call(:scan, _from, {:dev, pid}) do
    {:reply, ["a","b","c",], {:dev, pid}}
  end

  def handle_call(:scan, _from, state ) do
    {hc, 0} = System.cmd("iw", ["wlan0", "scan", "ap-force"])
    {:reply, hc |> clean_ssid, state}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @doc """
    network should be one of
    {ssid, pass} for Wifi
    :ethernet for Ethernet
    nil for hostapd
  """
  def connect(network, pid) do
    GenServer.cast(__MODULE__, {:connect, network, pid})
  end

  # callback from the Nerves Interim Wifi Event Manager
  def on_ip(address) do
    Logger.debug("WE HAVE AN IP ADDRESS")
    Node.stop
    full_node_name = "farmbot@#{address}" |> String.to_atom
    {:ok, _pid} = Node.start(full_node_name)
    GenServer.cast(__MODULE__, {:on_ip, address})
  end


  def bad_key do
    Logger.error("Bad psk key!")
    GenServer.cast(__MODULE__, :bad_key)
  end

  @doc """
    returns a list of available ssids
  """
  def scan do
    GenServer.call(__MODULE__, :scan)
  end

  defp clean_ssid(hc) do
    hc
    |> String.replace("\t", "")
    |> String.replace("\\x00", "")
    |> String.split("\n")
    |> Enum.filter(fn(s) -> String.contains?(s, "SSID") end)
    |> Enum.map(fn(z) -> String.replace(z, "SSID: ", "") end)
    |> Enum.filter(fn(z) -> String.length(z) != 0 end)
  end

  defp print_cmd_result({message, 0}) do
    # IO.puts message
    message
  end

  defp print_cmd_result({message, err_no}) do
    Logger.error("Command failed! (#{inspect err_no}) #{inspect message}")
    raise "This is probably not recoverable. Bailing"
  end

  def terminate(reason, {:hostapd, _}) do
    Logger.error("Networking died.")
    IO.inspect reason
    System.cmd("sh", ["-c", "killall hostapd"]) |> print_cmd_result
    System.cmd("sh", ["-c", "killall dnsmasq"]) |> print_cmd_result
  end

  def terminate(reason, state) do
    Logger.error("Networking died")
    IO.inspect reason
    IO.inspect state
  end
end
