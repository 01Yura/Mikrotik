# nov/28/2023 00:34:04 by RouterOS 7.9.2
# software id = 
#
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no name=ether1-WAN
/interface wireguard
add comment=Basic listen-port=13231 mtu=1420 name=wireguard1
add comment=Extra_for_RUS listen-port=13234 mtu=1420 name=wireguard4
add comment=Connection_with_RUS listen-port=13235 mtu=1420 name=wireguard5
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/ip pool
add name=pool1-l2tp ranges=172.16.0.2-172.16.0.254
add name=pool2-pptp ranges=172.16.1.2-172.16.1.254
add name=pool3-sstp ranges=172.16.2.2-172.16.2.254
/ppp profile
add local-address=172.16.0.1 name=profile1-l2tp remote-address=pool1-l2tp
add local-address=172.16.1.1 name=profile2-pptp remote-address=pool2-pptp
add local-address=172.16.2.1 name=profile3-sstp remote-address=pool3-sstp
/routing table
add disabled=no fib name=rtab-for-RUS
/ipv6 settings
set disable-ipv6=yes
/interface detect-internet
set detect-interface-list=all
/interface l2tp-server server
set default-profile=profile1-l2tp enabled=yes
/interface ovpn-server server
set auth=sha1,md5
/interface pptp-server server
# PPTP connections are considered unsafe, it is suggested to use a more modern VPN protocol instead
set default-profile=profile2-pptp enabled=yes
/interface sstp-server server
set enabled=yes
/interface wireguard peers
add allowed-address=192.168.3.2/32 comment=Yura_Iphone interface=wireguard1 \
    public-key="swMmyeZZnpxk3beO/UJWdE1SCN4XCp+o8Pkm+TJRQgo="
add allowed-address=192.168.3.6/32 comment=Ilya_Iphone interface=wireguard1 \
    public-key="GphBAx5liRTuq+dDdngfEpRoMGEH66sMsWez0GiblRI="
add allowed-address=192.168.4.2/32 comment=RUS_Yura_Iphone interface=\
    wireguard4 public-key="axw2RIl08pCBE76takWyhElTRhb8mUIdJQtmhcFXcks="
add allowed-address=192.168.3.8/32 comment=Sweet_Pepper_Iphone interface=\
    wireguard1 public-key="He2RYLc+jWaVIjNFPcDGO7wgn7GHayIHQDLMW19xlD0="
add allowed-address=192.168.3.4/32 comment=Suslo_Ipad interface=wireguard1 \
    public-key="bluC8vV5A2MCSLvClsSZz76JvDFnqqa1xCH57nJT1SE="
add allowed-address=192.168.3.3/32 comment=Suslo_Iphone interface=wireguard1 \
    public-key="J0bdzaA689NooLnyeidW9Ie/z2p0yrovsabm3hwYPkU="
add allowed-address=192.168.4.3/32 comment=RUS_Suslo_Iphone interface=\
    wireguard4 public-key="RgX6zIZMy8uhjuTO1W2zoJ2fGLrIQ4I/vHZJV1WXvmo="
add allowed-address=192.168.3.222/32 comment="Router Turkey" interface=\
    wireguard1 public-key="AZOQkN6hGniJLG6B4jLJ/4gkAO1UY5VtmDW4rE8Usmo="
add allowed-address=192.168.5.2/32,0.0.0.0/0 comment=\
    Connection_with_RUS_router_Lipki interface=wireguard5 public-key=\
    "0oAqyGk1dRQW+rgchsXLGuLDMly7jMU3I+BuSu9sRwU="
add allowed-address=192.168.4.4/32 comment=RUS_Suslo_Asus_Notebook interface=\
    wireguard4 public-key="I205KW6WDDIa9d2VAGe2SOpiXl4MnKj64ZS1d2RXs3o="
add allowed-address=192.168.4.5/32 comment=RUS_Andzhei_PC interface=\
    wireguard4 public-key="t0oSehagXc09jsx8k+0bVYV1QqkyoR987dnQLFOdEEo="
add allowed-address=192.168.4.6/32 comment=RUS_Yura_PC interface=wireguard4 \
    public-key="ankvb7CSPFmHFN2zPs88yAQU/JGzbciclu4B51O/0z8="
/ip address
add address=192.168.3.1/24 interface=wireguard1 network=192.168.3.0
add address=192.168.5.1/24 interface=wireguard5 network=192.168.5.0
add address=192.168.4.1/24 interface=wireguard4 network=192.168.4.0
/ip dhcp-client
add interface=ether1-WAN
/ip firewall address-list
add address=212.232.37.207 list=ACCEPTORS
add address=194.87.199.75 list=ACCEPTORS
/ip firewall filter
add action=accept chain=input connection-state=established,related
add action=drop chain=input src-address-list=VPN-PEDIKI
add action=drop chain=input src-address-list="SIP-\?"
add action=drop chain=input src-address-list=DNS-REQUESTERS
add action=drop chain=input src-address-list=SSH-PEDIKI
add action=add-src-to-address-list address-list=SSH-PEDIKI \
    address-list-timeout=1w chain=input dst-port=22 in-interface=ether1-WAN \
    protocol=tcp src-address-list=!ACCEPTORS
add action=add-src-to-address-list address-list="SIP-\?" \
    address-list-timeout=5d chain=input dst-port=5060 in-interface=ether1-WAN \
    protocol=udp src-address-list=!ACCEPTORS
add action=add-src-to-address-list address-list=DNS-REQUESTERS \
    address-list-timeout=3d chain=input dst-port=53 in-interface=ether1-WAN \
    protocol=udp src-address-list=!ACCEPTORS
/ip firewall mangle
add action=mark-routing chain=prerouting dst-address=!192.168.4.0/24 \
    in-interface=wireguard4 new-routing-mark=rtab-for-RUS passthrough=yes
/ip firewall nat
add action=masquerade chain=srcnat out-interface=ether1-WAN
add action=masquerade chain=srcnat out-interface=wireguard5
/ip route
add disabled=no dst-address=0.0.0.0/0 gateway=192.168.5.2 routing-table=\
    rtab-for-RUS suppress-hw-offload=no
/ip service
set telnet disabled=yes
set ftp disabled=yes
set www disabled=yes
set ssh disabled=yes
set api disabled=yes
set api-ssl disabled=yes
/ppp secret
add name=kirill profile=profile1-l2tp
add name=kirill2 profile=profile2-pptp
add name=kirill3 profile=profile3-sstp
/system identity
set name=MikroTik_VPN_Germany
/system note
set show-at-login=no
/system ntp client
set enabled=yes
/system ntp client servers
add address=0.ru.pool.ntp.org
add address=1.ru.pool.ntp.org
