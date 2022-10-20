#！请先添加$uuid和$path环境变量后运行
#download
##diffuse
if [ ! -f "/home/runner/${REPL_SLUG}/build/index.html" ];then
    curl -L https://github.com/icidasset/diffuse/releases/download/3.2.0/diffuse-web.tar.gz -o diffuse-web.tar.gz
    tar -zxvf diffuse-web.tar.gz
    rm -f diffuse-web.tar.gz
fi

##caddy
if [ ! -f "caddy" ];then
    curl -L https://github.com/caddyserver/caddy/releases/download/v2.6.2/caddy_2.6.2_linux_amd64.tar.gz -o caddy.tar.gz
    tar -zxvf caddy.tar.gz
    rm -f LICENSE && rm -f README.md && rm -f caddy.tar.gz
    chmod +x caddy
fi

##verysimple
if [ ! -f "verysimple" ];then
    curl -L https://github.com/e1732a364fed/v2ray_simple/releases/download/v1.2.4-beta.3/verysimple_linux_amd64.tar.xz -o verysimple.tar.xz
    tar -xvf verysimple.tar.xz
    rm -f verysimple.tar.xz
    chmod +x verysimple
fi

##panindex
if [ ! -f "panindex" ];then
  curl -L https://github.com/libsgh/PanIndex/releases/latest/download/PanIndex-linux-amd64.tar.gz -o panindex.tar.gz
tar -zxvf panindex.tar.gz
mv PanIndex-linux-amd64 panindex
rm -f panindex.tar.gz & rm -f LICENSE
fi
chmod +x panindex

# configs

if [ $uuid ];then
    cat > server.toml <<EOF
[[listen]]
protocol = "vless"
uuid = "9831667d-e2fc-4022-a7ab-5fb9e0f1ee71"
host = "0.0.0.0"
port = 23333
insecure = true
fallback = ":80"
# cert = "cert.pem"
# key = "cert.key"
advancedLayer = "ws"
path = "$path"
fullcone = true
# early = true

[[dial]]
protocol = "direct"
fullcone = true
EOF
fi

if [ ! -f "caddyfile" ];then
    cat > caddyfile <<EOF
:80
root * /home/runner/${REPL_SLUG}/build
file_server browse

header {
    X-Robots-Tag none
    X-Content-Type-Options nosniff
    X-Frame-Options DENY
    Referrer-Policy no-referrer-when-downgrade
}

@websocket_verysimple {
        path $path
        header Connection *Upgrade*
        header Upgrade websocket
    }
reverse_proxy @websocket_verysimple unix//etc/caddy/vless
EOF
fi


# run
./verysimple -c server.toml &
./caddy run --config /home/runner/${REPL_SLUG}/caddyfile --adapter caddyfile
