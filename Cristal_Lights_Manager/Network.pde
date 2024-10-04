int lastMessageSent = 0;
void sendOSCMessage(OscMessage myMessage, NetAddress myRemoteLocation, boolean priority) {
    oscP5.send(myMessage, myRemoteLocation);
}