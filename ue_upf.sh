# ------------------------------------- #
#              Create UPF
# ------------------------------------- #

ifconfig
ip link add veth1 type veth peer name veth2
sleep 1
ip addr add 172.0.0.5/24 dev veth1
ip link set veth1 up
ip addr add 172.99.0.1/32 dev lo
sleep 1
gtp-link add upf1 &
sleep 2
gtp-tunnel add upf1 v1 200 100 172.99.0.2 172.0.0.6
gtp-tunnel add upf1 v1 400 300 172.99.0.3 172.0.0.6
sleep 2
ip route add 172.99.0.2/32 dev upf1
ip route add 172.99.0.3/32 dev upf1

ifconfig upf1 mtu 1400
ifconfig upf1 up

ip route
ifconfig

# ------------------------------------- #
#              Create UE1
# ------------------------------------- #
ip netns add ue1
ip link set veth2 netns ue1
ip netns exec ue1 ip addr add 172.0.0.6/24 dev veth2
ip netns exec ue1 ip link set veth2 up
ip netns exec ue1 ip addr add 172.99.0.2/32 dev lo
ip netns exec ue1 ip link set lo up

ip netns exec ue1 gtp-link add ue1 &
sleep 2
ip netns exec ue1 gtp-tunnel add ue1 v1 100 200 172.99.0.1 172.0.0.5
sleep 2
ip netns exec ue1 ip route add 172.99.0.1/32 dev ue1
sleep 2
ip netns exec ue1 ip route
ip netns exec ue1 ifconfig
ip netns exec ue1 ue1 mtu 1400
ip netns exec ue1 ifconfig ue1 mtu 1400
ip netns exec ue1 ifconfig ue1 up
ip netns exec ue1 ping 172.99.0.1 -c 2


# # ------------------------------------- #
# #              Create UE2
# # ------------------------------------- #
# ip netns add ue2
# ip link set veth2 netns ue2
# ip netns exec ue2 ip addr add 172.0.0.6/24 dev veth2
# ip netns exec ue2 ip link set veth2 up
# ip netns exec ue2 ip addr add 172.99.0.3/32 dev lo
# ip netns exec ue2 ip link set lo up

# ip netns exec ue2 gtp-link add ue2 &
# sleep 2
# ip netns exec ue2 gtp-tunnel add ue2 v1 300 400 172.99.0.1 172.0.0.5
# sleep 2
# ip netns exec ue2 ip route add 172.99.0.1/32 dev ue2
# sleep 2
# ip route
# ifconfig
# ifconfig upf1 mtu 1400
# ifconfig upf1 up
# ifconfig
# ip netns exec ue2 ip route
# ip netns exec ue2 ifconfig
# ip netns exec ue2 ue2 mtu 1400
# ip netns exec ue2 ifconfig ue2 mtu 1400
# ip netns exec ue2 ifconfig ue2 up
# ip netns exec ue2 ping 172.99.0.1 -c 2
