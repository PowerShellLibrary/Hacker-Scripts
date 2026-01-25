# list all the network interfaces and their current metrics
netsh interface ipv4 show interfaces

# set a higher metric value for that specific interface
netsh interface ipv4 set interface "InterfaceName" metric=Value

# example: set the metric for the "Wi-Fi" interface to 50
netsh interface ipv4 set interface "Wi-Fi" metric=50

# metric values can range from 1 to 9999, with lower values indicating higher priority