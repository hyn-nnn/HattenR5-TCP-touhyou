import processing.net.*;

Server server;
int clientCount = 0;
int[] vote = new int[3];

void setup() {
  server = new Server(this, 5204);
}

void draw() {
}

void clientEvent(Client client) {
  int selected = client.read();
  println(selected);
  vote[selected] += 1;
  int sum = 0;
  for (int i = 0; i < vote.length; ++i) {
    sum += vote[i];
  }
  if (sum == clientCount) {
    int max = 0;
    boolean dupplicate = false;
    for (int i = 1; i < vote.length; ++i) {
      if (vote[i] > vote[max]) {
        max = i;
        dupplicate = false;
      } else if (vote[i] == vote[max]) {
        dupplicate = true;
      }
    }
    if (dupplicate) {
      printArray(vote);
      max = vote.length;
    }
    server.write(max);
    for (int i = 0; i < vote.length; ++i) {
      vote[i] = 0;
    }
  }
}

void serverEvent(Server server, Client client) {
  clientCount += 1;
}

void disconnectEvent(Client client) {
  clientCount -= 1;
}
