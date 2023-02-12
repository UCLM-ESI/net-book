#!/usr/bin/env python3

import threading
from socket import socket, AF_INET, SOCK_DGRAM


QUIT = b"bye"
sock = socket(AF_INET, SOCK_DGRAM)
server = ('', 12345)


def send_message(sock, peer):
    """Send a message read from stdin using sock."""
    
    while True:
        message_out = input().encode()
        sock.sendto(message_out, peer)
        
        if message_out == QUIT:
            break



threading.Thread(target=send_message, args=(sock, server), daemon=True).start()

while True:
    message_in, peer = sock.recvfrom(1024)
    print(message_in.decode())

    if message_in == QUIT:
        break

sock.close()
